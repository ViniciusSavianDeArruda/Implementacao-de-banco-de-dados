# ⚙️ Implementação de Banco de Dados

> Guia completo de implementação com SQL Server: bancos de dados ativos, procedures, funções, triggers, transações, views, índices, integridade e segurança.

---

## 📚 Sumário

1. [Bancos de Dados Ativos](#1--bancos-de-dados-ativos)
2. [Variáveis e Conversão de Dados](#2--variáveis-e-conversão-de-dados)
3. [Estruturas Condicionais](#3--estruturas-condicionais)
4. [Loops e Cursores](#4--loops-e-cursores)
5. [Functions (UDF)](#5--functions-udf)
6. [Stored Procedures](#6--stored-procedures)
7. [Transações e ACID](#7--transações-e-acid)
8. [TRY…CATCH](#8--trycatch)
9. [Triggers (Gatilhos)](#9--triggers-gatilhos)
10. [Views e Subconsultas](#10--views-e-subconsultas)
11. [Tabelas Temporais](#11--tabelas-temporais)
12. [Índices](#12--índices)
13. [Integridade de Dados](#13--integridade-de-dados)
14. [Gerenciamento de Usuários e Permissões](#14--gerenciamento-de-usuários-e-permissões)

---

## 1. 🔁 Bancos de Dados Ativos

Um **banco de dados ativo** é capaz de reagir automaticamente a eventos ou condições definidas, sem necessidade de intervenção manual. A lógica de negócios é incorporada diretamente no SGBD.

### Mecanismos de reatividade

| Mecanismo | Descrição |
|---|---|
| **Triggers** | Disparam ações automáticas em INSERT, UPDATE ou DELETE |
| **Regras ECA** | Event → Condition → Action |
| **Restrições** | Chaves estrangeiras, CHECKs, integridade referencial |

### Benefícios

- **Automação** — reduz intervenção manual
- **Consistência** — regras de negócio aplicadas uniformemente
- **Eficiência** — lógica no banco evita consultas extras na aplicação
- **Segurança** — políticas de integridade garantidas no nível do SGBD

---

## 2. 📦 Variáveis e Conversão de Dados

### 2.1 Declaração e Atribuição

```sql
-- Declaração
DECLARE @Nome    VARCHAR(50);
DECLARE @Idade   INT;
DECLARE @Salario DECIMAL(10,2);

-- Atribuição com SET
SET @Nome = 'João';
SET @Idade = 30;

-- Atribuição com SELECT
SELECT @Nome = 'Maria', @Idade = 25;

-- Exibindo valores
PRINT @Nome;
SELECT @Nome AS Nome, @Idade AS Idade;
```

### 2.2 Variável do tipo TABLE

Útil para armazenar resultados intermediários temporariamente:

```sql
DECLARE @TabelaAlunos TABLE (
    Numero_aluno INT PRIMARY KEY,
    Nome         NVARCHAR(50),
    Tipo_aluno   INT,
    Curso        NVARCHAR(2)
);

INSERT INTO @TabelaAlunos VALUES (1, 'Silva', 1, 'CC'), (2, 'Braga', 2, 'CC');
SELECT * FROM @TabelaAlunos;
```

> ⚠️ Tabelas declaradas existem apenas na sessão atual e são descartadas automaticamente ao término do bloco.

### 2.3 CAST e CONVERT

| Função | Uso principal |
|---|---|
| `CAST(valor AS tipo)` | Conversão direta e portável |
| `CONVERT(tipo, valor, estilo)` | Conversão com controle de formato (datas) |

```sql
-- Converter decimal em string
SELECT 'Salário: R$ ' + CAST(Salario AS VARCHAR(20)) AS Info
FROM Funcionarios;

-- Formatar data DD/MM/YYYY
SELECT CONVERT(VARCHAR(10), Data_Nasc, 103) AS DataFormatada
FROM Funcionarios;

-- Calcular e converter idade
DECLARE @Ano_Atual INT = 2024;
SELECT Nome,
       CAST(@Ano_Atual - YEAR(Data_Nasc) AS VARCHAR(3)) + ' anos' AS Idade
FROM Funcionarios;
```

**Estilos de data mais usados no CONVERT:**

| Estilo | Formato |
|---|---|
| 103 | DD/MM/YYYY |
| 110 | MM-DD-YYYY |
| 112 | YYYYMMDD |

---

## 3. 🔀 Estruturas Condicionais

### 3.1 IF / ELSE

```sql
DECLARE @Valor INT = 10;

IF @Valor > 5
    PRINT 'O valor é maior que 5';
ELSE
    PRINT 'O valor é 5 ou menor';
```

### Verificar se banco ou tabela existem antes de criar

```sql
-- Verificar banco de dados
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MinhaEscola')
BEGIN
    CREATE DATABASE MinhaEscola;
END;

-- Verificar tabela
USE MinhaEscola;
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Aluno') AND type = N'U'
)
BEGIN
    CREATE TABLE Aluno (
        Numero_aluno INT PRIMARY KEY,
        Nome         NVARCHAR(50),
        Tipo_aluno   INT,
        Curso        NVARCHAR(2)
    );
END;
```

### 3.2 CASE

Avalia condições e retorna valores diferentes — equivalente ao IF/ELSE dentro de consultas SQL.

```sql
-- Classificação de salários
SELECT Nome,
       Salario,
       CASE
           WHEN Salario > 5000              THEN 'Alto'
           WHEN Salario BETWEEN 2500 AND 5000 THEN 'Médio'
           ELSE                                  'Baixo'
       END AS Categoria_Salario
FROM Funcionarios;

-- Converter notas de letras para números
UPDATE HISTORICO_ESCOLAR
SET Nota = CASE
               WHEN Nota = 'A' THEN 90
               WHEN Nota = 'B' THEN 85
               WHEN Nota = 'C' THEN 75
               WHEN Nota = 'D' THEN 65
               ELSE 0
           END;
```

---

## 4. 🔄 Loops e Cursores

### 4.1 WHILE

```sql
DECLARE @contador INT = 1;

WHILE @contador <= 10
BEGIN
    PRINT 'Contador: ' + CAST(@contador AS VARCHAR);
    SET @contador = @contador + 1;
END
```

### BREAK e CONTINUE

```sql
-- BREAK: interrompe o laço ao atingir a condição
WHILE @contador <= 10
BEGIN
    IF @contador = 5 BREAK;
    PRINT 'Valor: ' + CAST(@contador AS VARCHAR);
    SET @contador = @contador + 1;
END

-- CONTINUE: pula a iteração atual (imprime apenas ímpares)
WHILE @contador <= 10
BEGIN
    SET @contador = @contador + 1;
    IF @contador % 2 = 0 CONTINUE;
    PRINT 'Ímpar: ' + CAST(@contador AS VARCHAR);
END
```

### 4.2 Cursores

Permitem iterar linha a linha sobre um conjunto de resultados:

```sql
DECLARE @nome NVARCHAR(50);

DECLARE cursorFunc CURSOR FOR
    SELECT nome FROM Funcionarios;

OPEN cursorFunc;
FETCH NEXT FROM cursorFunc INTO @nome;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @nome;
    FETCH NEXT FROM cursorFunc INTO @nome;
END;

CLOSE    cursorFunc;
DEALLOCATE cursorFunc;
```

**Valores de `@@FETCH_STATUS`:**

| Valor | Significado |
|---|---|
| `0` | FETCH bem-sucedido |
| `-1` | Sem mais linhas (fim do cursor) |
| `-2` | Linha excluída ou fora de alcance |

---

## 5. 🧩 Functions (UDF)

Funções encapsulam lógica reutilizável e podem ser usadas dentro de consultas (SELECT, WHERE, JOIN).

> ⚠️ UDFs **não devem alterar estado** do banco (sem DML em tabelas reais).

### 5.1 Funções Escalares

Retornam um único valor:

```sql
-- Calcular dobro
CREATE OR ALTER FUNCTION dbo.fn_Dobro (@Numero INT)
RETURNS INT
AS
BEGIN
    RETURN @Numero * 2;
END;
GO

SELECT dbo.fn_Dobro(5) AS Resultado;  -- Retorna 10
```

```sql
-- Calcular idade corretamente
CREATE OR ALTER FUNCTION dbo.fn_Idade (@DataNasc DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @DataNasc, CAST(GETDATE() AS DATE))
         - CASE
               WHEN FORMAT(@DataNasc, 'MMdd') > FORMAT(GETDATE(), 'MMdd') THEN 1
               ELSE 0
           END;
END;
GO
```

```sql
-- Salário anual com bônus
CREATE OR ALTER FUNCTION dbo.fn_SalarioAnual
    (@SalarioMensal DECIMAL(12,2), @BonusPercent DECIMAL(5,2))
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN (12 * @SalarioMensal) * (1 + (@BonusPercent / 100.0));
END;
GO
```

### 5.2 Inline Table-Valued Function (ITVF)

Retorna uma tabela com uma única consulta — geralmente a opção mais rápida:

```sql
CREATE OR ALTER FUNCTION dbo.fn_FuncionariosPorDepartamento
    (@NomeDepartamento NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT f.Cpf,
           CONCAT(f.Pnome, ' ', f.Unome) AS NomeCompleto,
           f.Salario,
           d.Dnome AS Departamento
    FROM dbo.FUNCIONARIO  AS f
    JOIN dbo.DEPARTAMENTO AS d ON d.Dnumero = f.Dnr
    WHERE d.Dnome = @NomeDepartamento
);
GO

-- Uso
SELECT * FROM dbo.fn_FuncionariosPorDepartamento(N'Pesquisa');
```

### 5.3 Multi-Statement Table-Valued Function (MSTVF)

Permite múltiplos passos com uma variável de tabela interna:

```sql
CREATE OR ALTER FUNCTION dbo.fn_FuncionarioRendaAnual ()
RETURNS @T TABLE
(
    Cpf           CHAR(11),
    NomeCompleto  NVARCHAR(121),
    SalarioMensal DECIMAL(12,2),
    SalarioAnual  DECIMAL(12,2)
)
AS
BEGIN
    INSERT INTO @T
    SELECT f.Cpf,
           CONCAT(f.Pnome, ' ', f.Unome),
           f.Salario,
           (12 * f.Salario) + f.Salario + (f.Salario / 3.0)  -- 13º + 1/3 férias
    FROM dbo.FUNCIONARIO AS f;
    RETURN;
END;
GO

SELECT * FROM dbo.fn_FuncionarioRendaAnual();
```

---

## 6. 🗂️ Stored Procedures

Blocos T-SQL pré-compilados executados via `EXEC`. Suportam DML, transações e lógica de negócio completa.

### 6.1 Procedure Simples

```sql
CREATE OR ALTER PROCEDURE dbo.pr_ListarFuncionarios
AS
BEGIN
    SET NOCOUNT ON;
    SELECT f.Cpf, f.Pnome, f.Unome, f.Salario, f.Dnr
    FROM dbo.FUNCIONARIO AS f;
END;
GO

EXEC dbo.pr_ListarFuncionarios;
```

### 6.2 Parâmetros de Entrada

```sql
CREATE OR ALTER PROCEDURE dbo.pr_FuncionariosPorDepto
    @DepartamentoNumero INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT f.Cpf, f.Pnome, f.Unome, f.Salario
    FROM dbo.FUNCIONARIO AS f
    WHERE f.Dnr = @DepartamentoNumero;
END;
GO

EXEC dbo.pr_FuncionariosPorDepto @DepartamentoNumero = 5;
```

### 6.3 Parâmetros de Saída (OUTPUT)

```sql
CREATE OR ALTER PROCEDURE dbo.pr_ObterSalario
    @Cpf    CHAR(11),
    @Salario DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Salario = f.Salario
    FROM dbo.FUNCIONARIO AS f
    WHERE f.Cpf = @Cpf;
END;
GO

DECLARE @SalarioFuncionario DECIMAL(12,2);
EXEC dbo.pr_ObterSalario @Cpf = '12345678901', @Salario = @SalarioFuncionario OUTPUT;
PRINT @SalarioFuncionario;
```

### 6.4 Exemplo com Lógica Completa

```sql
CREATE PROCEDURE dbo.CalcularMedia
    @Nota1     INT,
    @Nota2     INT,
    @Nota3     INT,
    @MediaSaida FLOAT OUTPUT
AS
BEGIN
    DECLARE @Soma INT = @Nota1 + @Nota2 + @Nota3;

    IF @Soma > 0
        SET @MediaSaida = CAST(@Soma AS FLOAT) / 3;
    ELSE
        SET @MediaSaida = 0;

    PRINT 'Média: ' + CAST(@MediaSaida AS VARCHAR(10));
END;
GO

DECLARE @Resultado FLOAT;
EXEC dbo.CalcularMedia 85, 90, 78, @MediaSaida = @Resultado OUTPUT;
SELECT @Resultado AS MediaCalculada;
```

### Diferenças: Functions vs Stored Procedures

| Característica | Function (UDF) | Stored Procedure |
|---|---|---|
| Retorno | Valor ou tabela | Nenhum, OUTPUT ou result set |
| Uso em SELECT | ✅ Sim | ❌ Não |
| DML (INSERT/UPDATE) | ❌ Não (em tabelas reais) | ✅ Sim |
| Transações | ❌ Limitado | ✅ Completo |
| Execução | Chamada inline | `EXEC` |

---

## 7. 🔐 Transações e ACID

Uma **transação** é um conjunto de operações tratadas como uma unidade indivisível: ou todas são confirmadas, ou nenhuma é aplicada.

### Comandos principais

```sql
BEGIN TRANSACTION;   -- inicia a transação
COMMIT TRANSACTION;  -- confirma permanentemente
ROLLBACK TRANSACTION; -- desfaz todas as operações
SAVE TRANSACTION ponto; -- cria ponto de salvamento parcial
```

### 7.1 Propriedades ACID

#### Atomicidade — tudo ou nada

```sql
BEGIN TRANSACTION;

INSERT INTO FUNCIONARIO (...) VALUES (...);
INSERT INTO DEPARTAMENTO (...) VALUES (...);  -- pode falhar (PK duplicada)

IF @@ERROR <> 0
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Erro detectado. Transação revertida.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transação concluída com sucesso.';
END
```

#### Consistência — estado válido para estado válido

O banco rejeita automaticamente inserções que violem FK, PK ou restrições, garantindo que os dados permaneçam coerentes.

#### Isolamento — transações independentes

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN;
    SELECT * FROM dbo.FUNCIONARIO;
    WAITFOR DELAY '00:00:20';  -- mantém locks por 20s
COMMIT TRAN;
```

#### Durabilidade — persistência após COMMIT

Após o `COMMIT`, os dados permanecem salvos mesmo após falhas ou reinicializações do servidor.

### 7.2 SAVEPOINT — rollback parcial

```sql
BEGIN TRANSACTION;

-- Primeira operação: criar departamento
INSERT INTO DEPARTAMENTO (Dnome, Dnumero, ...) VALUES ('Marketing', 9, ...);

-- Ponto de salvamento
SAVE TRANSACTION PontoDeSalvamento;

-- Segunda operação: inserir funcionário (experimental)
INSERT INTO FUNCIONARIO (...) VALUES (...);

-- Decidimos não manter o funcionário, mas manter o departamento
ROLLBACK TRANSACTION PontoDeSalvamento;

COMMIT TRANSACTION;  -- confirma apenas o departamento
```

---

## 8. 🛡️ TRY…CATCH

Estrutura de tratamento de erros — o "cinto de segurança" do SQL Server.

### Estrutura básica

```sql
BEGIN TRY
    -- código que pode gerar erros
END TRY
BEGIN CATCH
    -- o que fazer se houver erro
    PRINT ERROR_NUMBER();
    PRINT ERROR_MESSAGE();
    PRINT ERROR_LINE();
END CATCH
```

### Fluxo de execução

```
TRY executa o bloco
  ├── Sem erro → CATCH ignorado, continua normalmente
  └── Com erro → pula para o CATCH imediatamente
```

### Com transação (padrão recomendado)

```sql
BEGIN TRY
    BEGIN TRAN;

    UPDATE dbo.FUNCIONARIO
    SET Salario = Salario * 1.02
    WHERE Dnr = 1;

    SELECT 1/0;  -- erro proposital para demonstração

    COMMIT;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK;

    DECLARE @msg NVARCHAR(4000) =
        CONCAT('Erro ', ERROR_NUMBER(),
               ' na linha ',  ERROR_LINE(),
               ': ',           ERROR_MESSAGE());
    PRINT @msg;

    -- THROW;  -- opcional: relançar o erro para a aplicação
END CATCH;
```

### XACT_STATE()

| Valor | Significado |
|---|---|
| `1` | Transação ativa e "comitável" |
| `-1` | Transação incomitável — só aceita ROLLBACK |
| `0` | Nenhuma transação ativa |

### Boas práticas

- Sempre use `TRY…CATCH` + transação em operações DML críticas
- No `CATCH`, sempre verifique `XACT_STATE()` antes de fazer ROLLBACK
- Registre `ERROR_NUMBER()`, `ERROR_MESSAGE()` e `ERROR_LINE()` para auditoria
- Use `THROW` para não "engolir" o erro e dificultar a depuração

---

## 9. ⚡ Triggers (Gatilhos)

Triggers são objetos de banco de dados associados a tabelas, que **executam automaticamente** em resposta a eventos (INSERT, UPDATE, DELETE). Diferente de procedures, **não são chamados manualmente**.

### Tipos de Triggers

| Tipo | Quando dispara | Uso típico |
|---|---|---|
| `AFTER` | Depois que a operação é concluída | Validação, auditoria pós-operação |
| `INSTEAD OF` | Substitui a operação original | Controle total sobre o que ocorre |

### 9.1 AFTER Trigger

```sql
-- Impedir salários abaixo do mínimo
CREATE TRIGGER trg_check_salary
ON FUNCIONARIO
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @Salario DECIMAL(10,2);
    SELECT @Salario = i.Salario FROM inserted i;

    IF @Salario < 1000.00
    BEGIN
        RAISERROR('O salário não pode ser menor que R$ 1.000,00.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
```

### 9.2 INSTEAD OF Trigger

```sql
-- Substituir o INSERT padrão por um com validação
CREATE TRIGGER trg_instead_insert_funcionario
ON FUNCIONARIO
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Salario DECIMAL(10,2);
    SELECT @Salario = i.Salario FROM inserted i;

    IF @Salario >= 1000.00
        INSERT INTO FUNCIONARIO SELECT * FROM inserted;
    ELSE
        RAISERROR('Salário inválido. Inserção cancelada.', 16, 1);
END;
GO
```

### 9.3 Trigger de Auditoria

```sql
-- Tabela de histórico de alterações salariais
CREATE TABLE Historico_Salario (
    Cpf           CHAR(11),
    Data_Mudanca  DATE,
    Salario_Antigo DECIMAL(10,2),
    Salario_Novo  DECIMAL(10,2)
);
GO

-- Trigger que registra cada alteração de salário
CREATE TRIGGER trg_salario_update
ON FUNCIONARIO
FOR UPDATE
AS
BEGIN
    IF UPDATE(Salario)
    BEGIN
        INSERT INTO Historico_Salario
        SELECT i.Cpf, GETDATE(), d.Salario, i.Salario
        FROM inserted i
        INNER JOIN deleted d ON i.Cpf = d.Cpf;
    END
END;
GO
```

### 9.4 Trigger de Proteção

```sql
-- Impedir exclusão de gerentes ativos
CREATE TRIGGER trg_prevent_delete_gerente
ON FUNCIONARIO
FOR DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM deleted del
        INNER JOIN DEPARTAMENTO d ON del.Cpf = d.Cpf_gerente
    )
    BEGIN
        RAISERROR('O gerente não pode ser excluído enquanto gerenciar um departamento.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
```

### Tabelas Virtuais: `inserted` e `deleted`

| Tabela | Disponível em | Conteúdo |
|---|---|---|
| `inserted` | INSERT, UPDATE | Linhas novas / após atualização |
| `deleted` | DELETE, UPDATE | Linhas removidas / antes da atualização |

### RAISERROR

```sql
RAISERROR('Mensagem de erro', Severidade, Estado);
-- Severidade 0-10: informativo
-- Severidade 11-16: erros de aplicação (mais comum: 16)
-- Severidade 17-25: erros críticos de servidor
```

---

## 10. 👁️ Views e Subconsultas

### 10.1 Views

Uma **view** é uma tabela virtual gerada a partir de uma consulta SQL. Não armazena dados — executa a consulta a cada acesso.

**Vantagens:** reutilização, segurança (ocultar colunas), simplicidade, mascaramento de complexidade.

```sql
-- Criar view
CREATE VIEW FuncionariosVendas AS
SELECT Pnome, Unome, Salario
FROM Funcionarios
WHERE Dnr = 3;

-- Alterar view
ALTER VIEW FuncionariosVendas AS
SELECT Pnome, Unome, Salario, Datanasc
FROM Funcionarios
WHERE Dnr = 3;

-- Remover view
DROP VIEW FuncionariosVendas;

-- Consultar view como uma tabela comum
SELECT * FROM FuncionariosVendas;
```

### 10.2 Subconsultas (Subqueries)

Uma **subconsulta** é uma consulta dentro de outra consulta, usada para fornecer dados à consulta principal.

```sql
-- Funcionários que ganham acima da média geral
SELECT Pnome, Unome, Salario
FROM Funcionarios
WHERE Salario > (SELECT AVG(Salario) FROM Funcionarios);

-- Projetos com mais de 3 funcionários alocados
SELECT Pnome_projeto
FROM Projeto
WHERE Pnumero IN (
    SELECT Pno
    FROM Trabalha_em
    GROUP BY Pno
    HAVING COUNT(*) > 3
);

-- Departamentos com média salarial acima da média geral
SELECT Dnome, AVG(Salario) AS MediaDepto
FROM Funcionarios
JOIN Departamento ON Dnr = Dnumero
GROUP BY Dnome
HAVING AVG(Salario) > (SELECT AVG(Salario) FROM Funcionarios);
```

---

## 11. ⏱️ Tabelas Temporais

Tabelas temporais (Temporal Tables) rastreiam **automaticamente** todo o histórico de alterações, armazenando versões anteriores de cada linha com timestamps.

```sql
-- Criar tabela temporal
CREATE TABLE InventarioCarros
(
    CarroId       INT IDENTITY PRIMARY KEY,
    Marca         VARCHAR(40),
    Modelo        VARCHAR(40),
    Disponivel    BIT NOT NULL DEFAULT 1,
    SysStartTime  datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    SysEndTime    datetime2 GENERATED ALWAYS AS ROW END   NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.HistoricoInventarioCarros));
```

### Consultas temporais

```sql
-- Estado da tabela em um momento específico do passado
SELECT * FROM InventarioCarros
FOR SYSTEM_TIME AS OF '2024-08-16 17:46:00';

-- Todo o histórico de um carro específico
SELECT * FROM InventarioCarros
FOR SYSTEM_TIME ALL
WHERE CarroId = 1;
```

### Como desativar e excluir

```sql
ALTER TABLE InventarioCarros SET (SYSTEM_VERSIONING = OFF);
DROP TABLE InventarioCarros;
DROP TABLE HistoricoInventarioCarros;
```

> 💡 Para excluir uma tabela temporal, é **obrigatório** desativar o `SYSTEM_VERSIONING` primeiro.

---

## 12. 📈 Índices

Índices otimizam o acesso a dados em tabelas, funcionando como o índice de um livro.

### 12.1 Tipos de Índices

| Tipo | Características |
|---|---|
| **Clustered** | Organiza fisicamente os dados; apenas 1 por tabela (criado automaticamente na PK) |
| **Non-Clustered** | Estrutura separada que aponta para as linhas; múltiplos por tabela |
| **Único** | Garante que não haja valores duplicados na coluna indexada |
| **Composto** | Cobre múltiplas colunas em uma única entrada de índice |

### 12.2 Criação

```sql
-- Índice não clusterizado simples
CREATE NONCLUSTERED INDEX IX_Funcionarios_Nome
ON Funcionarios (Nome);

-- Índice composto (múltiplas colunas)
CREATE NONCLUSTERED INDEX IX_Funcionarios_Cargo_Salario
ON Funcionarios (Cargo, Salario);

-- Índice único
CREATE UNIQUE INDEX IX_Funcionarios_CPF
ON Funcionarios (CPF);

-- Índice com colunas incluídas (cobertura)
CREATE NONCLUSTERED INDEX IX_Pessoas_Estado_Nome
ON Pessoa (Estado, Nome)
INCLUDE (Cidade, CPF);
```

### 12.3 Quando usar (e quando não usar)

✅ **Use índices quando:**
- Consultas frequentes com `WHERE`, `JOIN`, `ORDER BY`, `GROUP BY`
- Tabelas grandes com muitas leituras
- Colunas com alta seletividade (muitos valores distintos)

❌ **Evite índices quando:**
- Tabelas muito pequenas
- Operações de escrita (`INSERT`, `UPDATE`, `DELETE`) são muito frequentes
- Colunas com baixa seletividade (ex.: coluna booleana)

### 12.4 Analisar performance

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Nome, Cidade, Estado
FROM Pessoa
WHERE Estado = 'RS'
ORDER BY Nome;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

> Observe **logical reads** e **elapsed time** nas mensagens do SSMS antes e depois de criar o índice.

---

## 13. 🔒 Integridade de Dados

A **integridade de dados** garante que os dados sejam consistentes, precisos e confiáveis ao longo do tempo, por meio de restrições aplicadas diretamente no banco.

### 13.1 Integridade de Domínio

Define que os valores de uma coluna devem pertencer a um conjunto ou intervalo válido:

```sql
CREATE TABLE Produtos (
    id_produto   INT PRIMARY KEY,
    nome_produto VARCHAR(100),
    preco        DECIMAL(10,2) CHECK (preco > 0)  -- apenas valores positivos
);
```

### 13.2 Integridade Referencial (FK)

Garante que relacionamentos entre tabelas permaneçam consistentes:

```sql
CREATE TABLE Vendas (
    id_venda   INT PRIMARY KEY,
    id_produto INT,
    CONSTRAINT fk_produto FOREIGN KEY (id_produto)
        REFERENCES Produtos(id_produto)
        ON DELETE CASCADE    -- exclui vendas se produto for excluído
        ON UPDATE CASCADE    -- atualiza FK se PK mudar
);
```

### 13.3 Integridade de Vazio (NOT NULL)

Define se uma coluna pode aceitar valores nulos:

```sql
CREATE TABLE Funcionarios (
    id_funcionario   INT PRIMARY KEY,
    nome_funcionario VARCHAR(100) NOT NULL,  -- obrigatório
    salario          DECIMAL(10,2) NOT NULL, -- obrigatório
    email            VARCHAR(150)            -- opcional (aceita NULL)
);
```

### 13.4 Integridade de Chave (PRIMARY KEY / UNIQUE)

Garante unicidade e não-nulidade dos identificadores:

```sql
CREATE TABLE Departamentos (
    id_departamento  INT PRIMARY KEY,            -- único e não nulo
    nome_departamento VARCHAR(100) NOT NULL,
    codigo_externo   VARCHAR(10) UNIQUE          -- único, mas pode ser nulo
);
```

### 13.5 Integridade Definida pelo Usuário

Restrições personalizadas para regras específicas do negócio:

```sql
CREATE TABLE Funcionarios (
    id_funcionario INT PRIMARY KEY,
    nome           VARCHAR(100),
    cargo          VARCHAR(50) CHECK (cargo IN ('Gerente', 'Analista', 'Desenvolvedor')),
    nivel_acesso   INT         CHECK (nivel_acesso BETWEEN 1 AND 5),
    data_admissao  DATE        DEFAULT GETDATE()
);
```

### Resumo das Restrições

| Restrição | Propósito |
|---|---|
| `PRIMARY KEY` | Unicidade + NOT NULL do identificador |
| `FOREIGN KEY` | Integridade referencial entre tabelas |
| `UNIQUE` | Unicidade de valor em uma coluna |
| `NOT NULL` | Proíbe valores nulos |
| `CHECK` | Valida condição lógica no valor |
| `DEFAULT` | Valor padrão quando não informado |

---

## 14. 👤 Gerenciamento de Usuários e Permissões

O controle de acesso garante que cada usuário possa realizar apenas as operações autorizadas.

### 14.1 Criar Login e Usuário

```sql
-- Passo 1: criar login no servidor
CREATE LOGIN MeuLogin WITH PASSWORD = 'MinhaSenhaForte@2024';

-- Passo 2: criar usuário no banco de dados
USE MeuBancoDeDados;
CREATE USER MeuUsuario FOR LOGIN MeuLogin;
```

### 14.2 GRANT — conceder permissões

```sql
-- Permissão de leitura em uma tabela
GRANT SELECT ON dbo.MinhaTabela TO MeuUsuario;

-- Múltiplas permissões
GRANT SELECT, INSERT ON dbo.MinhaTabela TO MeuUsuario;

-- Permissão de executar uma procedure
GRANT EXECUTE ON dbo.pr_ListarFuncionarios TO MeuUsuario;
```

### 14.3 DENY — negar permissões

```sql
-- Negar exclusão (tem precedência mesmo sobre permissões de roles)
DENY DELETE ON dbo.MinhaTabela TO MeuUsuario;

-- Negar atualização de coluna salarial
DENY UPDATE ON dbo.Funcionarios(Salario) TO MeuUsuario;
```

### 14.4 REVOKE — remover permissões

```sql
-- Remover permissão concedida ou negada anteriormente
REVOKE INSERT ON dbo.MinhaTabela FROM MeuUsuario;
REVOKE SELECT ON dbo.MinhaTabela FROM MeuUsuario;
```

### Diferença entre DENY e REVOKE

| Comando | Efeito |
|---|---|
| `GRANT` | Concede explicitamente a permissão |
| `DENY` | Nega explicitamente — tem **precedência** sobre qualquer GRANT (inclusive de roles) |
| `REVOKE` | Remove o GRANT ou DENY — o acesso volta ao estado neutro (herda da role) |

### 14.5 Exemplo completo de controle de acesso

```sql
-- Criar usuário
CREATE LOGIN AnalistaLogin WITH PASSWORD = 'Analista@2024';
USE EmpresaDB;
CREATE USER AnalistaUser FOR LOGIN AnalistaLogin;

-- Conceder leitura nas tabelas de dados
GRANT SELECT ON dbo.FUNCIONARIO   TO AnalistaUser;
GRANT SELECT ON dbo.DEPARTAMENTO  TO AnalistaUser;
GRANT SELECT ON dbo.PROJETO       TO AnalistaUser;

-- Conceder execução de procedures de leitura
GRANT EXECUTE ON dbo.pr_ListarFuncionarios TO AnalistaUser;

-- Negar qualquer alteração ou exclusão
DENY INSERT, UPDATE, DELETE ON dbo.FUNCIONARIO TO AnalistaUser;
```

---

## 📖 Referências

- HEUSER, Carlos Alberto. **Projeto de Banco de Dados**. 6ª ed. Porto Alegre: Bookman, 2009.
- ELMASRI, R.; NAVATHE, S. **Sistemas de Banco de Dados**. 6ª ed. São Paulo: Pearson, 2011.
- Microsoft Docs — [Transact-SQL Reference (SQL Server)](https://docs.microsoft.com/pt-br/sql/t-sql/language-reference)
- Microsoft Docs — [Temporal Tables](https://docs.microsoft.com/pt-br/sql/relational-databases/tables/temporal-tables)
- Microsoft Docs — [Índices do SQL Server](https://docs.microsoft.com/pt-br/sql/relational-databases/indexes/indexes)
- Microsoft Docs — [TRY...CATCH (T-SQL)](https://docs.microsoft.com/pt-br/sql/t-sql/language-elements/try-catch-transact-sql)

---

<div align="center">

Feito com ❤️ para estudantes e desenvolvedores de banco de dados SQL Server.

</div>
