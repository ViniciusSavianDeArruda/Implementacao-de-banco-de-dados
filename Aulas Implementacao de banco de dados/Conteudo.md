# Estudo: Banco de Dados Ativos no SQL Server

## 1. Introdução aos Bancos de Dados Ativos

### Conceito
Bancos de dados ativos são sistemas que **reagem automaticamente** a eventos ou condições específicas, diferindo dos bancos tradicionais que executam operações apenas quando explicitamente solicitadas.

### Características Principais
- **Gatilhos (Triggers)**: Ações automáticas disparadas por eventos (INSERT, UPDATE, DELETE)
- **Regras Ativas (ECA)**: Event-Condition-Action - estrutura que define quando e como reagir
- **Restrições e Validações**: Aplicação automática de regras de integridade

### Benefícios
- ✅ **Automação** de processos
- ✅ **Consistência** na aplicação de regras
- ✅ **Eficiência** na execução
- ✅ **Segurança** e integridade dos dados

### Exemplos de Aplicação
- Monitoramento de fraudes em tempo real
- Manutenção automática de inventário
- Gestão de processos de negócio

---

## 2. Variáveis no SQL Server

### 2.1 Declaração de Variáveis

```sql
-- Sintaxe básica
DECLARE @NomeVariavel TipoDeDado;

-- Exemplos
DECLARE @Nome VARCHAR(50);
DECLARE @Idade INT;
DECLARE @Salario DECIMAL(10,2);
```

### 2.2 Tabelas em Memória

```sql
-- Declarando tabela temporária
DECLARE @TabelaAlunos TABLE (
    Numero_aluno INT PRIMARY KEY,
    Nome NVARCHAR(50),
    Tipo_aluno INT,
    Curso NVARCHAR(2)
);

-- Inserindo dados
INSERT INTO @TabelaAlunos VALUES 
(1, 'Silva', 1, 'CC'),
(2, 'Braga', 2, 'CC');

-- Consultando
SELECT * FROM @TabelaAlunos;
```

### 2.3 Atribuição de Valores

```sql
-- Usando SET
SET @Nome = 'João';
SET @Idade = 30;

-- Usando SELECT
SELECT @Nome = 'Maria', @Idade = 25;

-- Atribuindo de uma consulta
SELECT @TotalFuncionarios = COUNT(*) FROM Funcionarios;
```

### 2.4 Exibição de Valores

```sql
-- Usando PRINT
PRINT @Nome;

-- Usando SELECT
SELECT @Nome AS Nome, @Idade AS Idade;
```

---

## 3. Conversão de Dados

### 3.1 CAST vs CONVERT

| Função | Uso | Flexibilidade |
|--------|-----|---------------|
| CAST | Conversão básica | Limitada |
| CONVERT | Conversão com formatação | Alta |

### 3.2 Exemplos Práticos

```sql
-- CAST - Conversão básica
SELECT 'Salário: R$ ' + CAST(Salario AS VARCHAR(20)) 
FROM Funcionarios;

-- CONVERT - Com formatação de data
SELECT CONVERT(VARCHAR(10), Data_Nasc, 103) AS 'DD/MM/YYYY'
FROM Funcionarios;

-- CONVERT - Diferentes formatos de data
DECLARE @Data DATETIME = GETDATE();
SELECT CONVERT(NVARCHAR(10), @Data, 103) AS 'DD/MM/YYYY';  -- 12/08/2024
SELECT CONVERT(NVARCHAR(10), @Data, 110) AS 'MM-DD-YYYY';  -- 08-12-2024
SELECT CONVERT(NVARCHAR(8), @Data, 112) AS 'YYYYMMDD';     -- 20240812
```

---

## 4. Estruturas Condicionais

### 4.1 IF/ELSE

```sql
DECLARE @Valor INT = 10;

IF @Valor > 5
    PRINT 'Valor maior que 5';
ELSE
    PRINT 'Valor menor ou igual a 5';
```

### 4.2 Verificações de Existência

```sql
-- Verificar se banco existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MeuBanco')
BEGIN
    CREATE DATABASE MeuBanco;
END;

-- Verificar se tabela existe
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID(N'MinhaTabela') 
               AND type in (N'U'))
BEGIN
    CREATE TABLE MinhaTabela (
        Id INT PRIMARY KEY,
        Nome VARCHAR(50)
    );
END;
```

### 4.3 CASE - Estrutura Condicional em Consultas

```sql
-- Sintaxe
CASE
    WHEN condição1 THEN valor1
    WHEN condição2 THEN valor2
    ELSE valor_default
END

-- Exemplo: Classificação de salários
SELECT nome, 
       salario,
       CASE 
           WHEN salario > 5000 THEN 'Alto'
           WHEN salario BETWEEN 2500 AND 5000 THEN 'Médio'
           ELSE 'Baixo'
       END AS Categoria_Salario
FROM Funcionarios;

-- Exemplo: Conversão de notas
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

## 5. Loops e Controle de Fluxo

### 5.1 WHILE Loop

```sql
-- Estrutura básica
WHILE condição
BEGIN
    -- Código a ser repetido
END

-- Exemplo prático
DECLARE @contador INT = 1;

WHILE @contador <= 10
BEGIN
    PRINT 'Contador: ' + CAST(@contador AS VARCHAR);
    SET @contador = @contador + 1;
END;
```

### 5.2 Controle de Fluxo

```sql
-- BREAK - Sair do loop
DECLARE @contador INT = 1;

WHILE @contador <= 10
BEGIN
    IF @contador = 5
        BREAK;  -- Sai do loop quando contador = 5
    
    PRINT 'Contador: ' + CAST(@contador AS VARCHAR);
    SET @contador = @contador + 1;
END;

-- CONTINUE - Pular iteração
DECLARE @contador INT = 0;

WHILE @contador < 10
BEGIN
    SET @contador = @contador + 1;
    
    IF @contador % 2 = 0
        CONTINUE;  -- Pula números pares
    
    PRINT 'Número ímpar: ' + CAST(@contador AS VARCHAR);
END;
```

### 5.3 Cursores (Para Processamento Linha a Linha)

```sql
DECLARE @nome NVARCHAR(50);

-- Declarar cursor
DECLARE cursorFuncionarios CURSOR FOR
SELECT nome FROM Funcionarios;

-- Abrir cursor
OPEN cursorFuncionarios;

-- Primeira leitura
FETCH NEXT FROM cursorFuncionarios INTO @nome;

-- Loop através do cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @nome;
    FETCH NEXT FROM cursorFuncionarios INTO @nome;
END;

-- Fechar e liberar cursor
CLOSE cursorFuncionarios;
DEALLOCATE cursorFuncionarios;
```

#### Status do Cursor (@@FETCH_STATUS)
- **0**: Operação bem-sucedida
- **-1**: Falha ou fim do conjunto de resultados
- **-2**: Linha excluída ou modificada externamente

---

## 6. Exemplo Prático Completo

### Procedimento para Calcular Média com Validação

```sql
CREATE PROCEDURE CalcularMedia
    @Nota1 INT,
    @Nota2 INT,
    @Nota3 INT,
    @MediaSaida FLOAT OUTPUT
AS
BEGIN
    DECLARE @Soma INT;
    
    -- Calcular soma
    SET @Soma = @Nota1 + @Nota2 + @Nota3;
    
    -- Validação e cálculo
    IF @Soma > 0
        SET @MediaSaida = CAST(@Soma AS FLOAT) / 3;
    ELSE
        SET @MediaSaida = 0;
    
    -- Exibir resultado
    PRINT 'A média das notas é: ' + CAST(@MediaSaida AS VARCHAR(10));
END;

-- Execução
DECLARE @Resultado FLOAT;
EXEC CalcularMedia 85, 90, 78, @MediaSaida = @Resultado OUTPUT;
SELECT @Resultado AS MediaCalculada;
```

### Cálculo de Idade com Validação

```sql
-- Declarando tabela e dados de exemplo
DECLARE @ALUNO TABLE(
    Id INT IDENTITY PRIMARY KEY,
    Nome VARCHAR(50),
    Data_Nasc DATE,
    Curso VARCHAR(2)
);

INSERT INTO @ALUNO VALUES ('João Silva', '1988-06-07', 'SI');

-- Calculando idade precisa
DECLARE @Nome_Aluno VARCHAR(50),
        @Data_Nasc DATE,
        @Idade INT;

-- Recuperando dados
SELECT @Nome_Aluno = Nome, @Data_Nasc = Data_Nasc
FROM @ALUNO
WHERE Id = 1;

-- Cálculo de idade considerando se já fez aniversário
SET @Idade = DATEDIFF(YEAR, @Data_Nasc, GETDATE()) - 
    CASE WHEN MONTH(@Data_Nasc) > MONTH(GETDATE()) OR 
              (MONTH(@Data_Nasc) = MONTH(GETDATE()) AND DAY(@Data_Nasc) > DAY(GETDATE())) 
         THEN 1 
         ELSE 0 
    END;

-- Resultado
SELECT @Nome_Aluno AS 'Nome do Aluno', 
       @Idade AS 'Idade';
```

---

## 7. Resumo das Funções Principais

### Funções de Sistema Importantes
- `GETDATE()`: Data e hora atual
- `DATEDIFF()`: Diferença entre datas
- `YEAR()`, `MONTH()`, `DAY()`: Extrair partes da data
- `OBJECT_ID()`: Verificar existência de objetos

### Melhores Práticas
1. **Sempre validar** existência antes de criar objetos
2. **Usar variáveis** para valores reutilizáveis
3. **Implementar tratamento de erro** adequado
4. **Documentar procedimentos** e funções
5. **Otimizar loops** para evitar performance ruim

### Considerações de Performance
- Cursores devem ser usados com parcimônia
- Loops WHILE podem impactar performance em grandes volumes
- Prefira operações baseadas em conjunto quando possível
- Use índices apropriados para consultas dentro de loops

---

## 🔹 O que são Funções?

**Funções** são rotinas reutilizáveis no banco de dados que **sempre retornam um valor ou uma tabela**. Elas diferem das *stored procedures* por:

- ✅ **Sempre retornam um resultado**
- ✅ **Podem ser usadas em consultas** (`SELECT`, `WHERE`, `JOIN`)
- ✅ **Facilitam o reuso de lógica**
- ✅ **Aceitam parâmetros de entrada**
- ❌ **Não podem modificar dados** (somente leitura)

---

## 🎯 Tipos de Funções

### 1️⃣ **Função Escalar (Scalar Function)**

**Retorna um único valor** (número, texto, data, etc.)

#### 📝 Sintaxe
```sql
CREATE FUNCTION NomeFuncao (@parametro TipoDado)
RETURNS TipoDado
AS
BEGIN
    RETURN expressao
END;
```

#### 💡 Exemplo Prático
```sql
-- Criação da função
CREATE FUNCTION dbo.CalcularIdade (@DataNasc DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @DataNasc, GETDATE()) - 
           CASE 
               WHEN MONTH(@DataNasc) > MONTH(GETDATE()) OR 
                    (MONTH(@DataNasc) = MONTH(GETDATE()) AND DAY(@DataNasc) > DAY(GETDATE()))
               THEN 1 
               ELSE 0 
           END;
END;

-- Uso da função
SELECT 
    Pnome,
    DataNasc,
    dbo.CalcularIdade(DataNasc) AS Idade
FROM FUNCIONARIO
WHERE dbo.CalcularIdade(DataNasc) >= 18;
```

#### ✨ Características
- Pode ser usada em `SELECT`, `WHERE`, `JOIN`, `ORDER BY`
- Retorna apenas um valor por linha
- Ideal para cálculos e transformações

---

### 2️⃣ **Função de Tabela (Table-Valued Function)**

**Retorna uma tabela completa** que pode ser usada como uma tabela normal.

#### 💡 Exemplo Prático
```sql
-- Criação da função
CREATE FUNCTION dbo.FuncionariosPorDepartamento (@DeptoID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        f.Pnome,
        f.Salario,
        d.Dnome AS Departamento
    FROM FUNCIONARIO f
    INNER JOIN DEPARTAMENTO d ON f.Dno = d.Dnumero
    WHERE f.Dno = @DeptoID
);

-- Uso da função
SELECT * FROM dbo.FuncionariosPorDepartamento(1);

-- Pode ser usada em JOINs
SELECT 
    f.Pnome,
    f.Salario,
    p.Nome_projeto
FROM dbo.FuncionariosPorDepartamento(1) f
INNER JOIN TRABALHA_EM te ON f.Cpf = te.Fcpf
INNER JOIN PROJETO p ON te.Pnr = p.Projnumero;
```

---

### 3️⃣ **Função de Tabela Multi-Statement**

**Permite lógica complexa** com múltiplas instruções antes de retornar a tabela.

#### 💡 Exemplo Prático
```sql
CREATE FUNCTION dbo.RelatorioSalarial (@SalarioMinimo DECIMAL(10,2))
RETURNS @TabelaRetorno TABLE
(
    Nome VARCHAR(50),
    Salario DECIMAL(10,2),
    Categoria VARCHAR(20),
    Bonus DECIMAL(10,2)
)
AS
BEGIN
    -- Inserir funcionários com salário baixo
    INSERT INTO @TabelaRetorno
    SELECT 
        Pnome, 
        Salario, 
        'Baixo',
        Salario * 0.15  -- 15% de bônus
    FROM FUNCIONARIO
    WHERE Salario < @SalarioMinimo;
    
    -- Inserir funcionários com salário alto
    INSERT INTO @TabelaRetorno
    SELECT 
        Pnome, 
        Salario, 
        'Alto',
        Salario * 0.10  -- 10% de bônus
    FROM FUNCIONARIO
    WHERE Salario >= @SalarioMinimo;
    
    RETURN;
END;

-- Uso
SELECT * FROM dbo.RelatorioSalarial(5000)
ORDER BY Categoria, Salario DESC;
```

---

### 4️⃣ **Função Inline Table-Valued**

**Mais eficiente** que multi-statement - retorna tabela com uma única instrução SELECT.

#### 💡 Exemplo Prático
```sql
CREATE FUNCTION dbo.FuncionariosComBonus (@Percentual DECIMAL(5,2))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        Pnome,
        Salario,
        Salario * (@Percentual / 100) AS Bonus,
        Salario + (Salario * (@Percentual / 100)) AS SalarioTotal
    FROM FUNCIONARIO
    WHERE Salario > 0
);

-- Uso
SELECT * FROM dbo.FuncionariosComBonus(12.5)
WHERE SalarioTotal > 6000;
```

---

### 5️⃣ **Funções com Múltiplos Parâmetros**

**Maior flexibilidade** com vários parâmetros de entrada.

#### 💡 Exemplo Prático
```sql
-- Função escalar com múltiplos parâmetros
CREATE FUNCTION dbo.CalcularSalarioLiquido 
(
    @SalarioBruto DECIMAL(10,2),
    @PercentualINSS DECIMAL(5,2) = 11.0,
    @PercentualIR DECIMAL(5,2) = 15.0
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @INSS DECIMAL(10,2) = @SalarioBruto * (@PercentualINSS / 100);
    DECLARE @IR DECIMAL(10,2) = (@SalarioBruto - @INSS) * (@PercentualIR / 100);
    
    RETURN @SalarioBruto - @INSS - @IR;
END;

-- Uso
SELECT 
    Pnome,
    Salario AS SalarioBruto,
    dbo.CalcularSalarioLiquido(Salario, DEFAULT, DEFAULT) AS SalarioLiquido,
    dbo.CalcularSalarioLiquido(Salario, 8.0, 12.0) AS SalarioLiquidoPersonalizado
FROM FUNCIONARIO;
```

---

## 📊 Comparativo dos Tipos

| Tipo de Função | Retorno | Performance | Uso Principal | Complexidade |
|---|---|---|---|---|
| **Escalar** | Valor único | ⚠️ Moderada | Cálculos linha a linha | 🟢 Baixa |
| **Table-Valued** | Tabela | ⚠️ Moderada | Consultas parametrizadas | 🟢 Baixa |
| **Multi-Statement** | Tabela | 🔴 Baixa | Lógica complexa | 🔴 Alta |
| **Inline Table-Valued** | Tabela | 🟢 Alta | Consultas rápidas | 🟢 Baixa |

---

## 📋 Boas Práticas

### ✅ **Recomendações**

1. **Nomenclatura Clara**
   ```sql
   -- ✅ Bom
   CREATE FUNCTION dbo.CalcularIdadeFuncionario(@DataNasc DATE)
   
   -- ❌ Evitar
   CREATE FUNCTION CalcId(@d DATE)
   ```

2. **Use Inline quando possível**
   ```sql
   -- ✅ Preferível (mais rápida)
   CREATE FUNCTION dbo.FuncionariosAtivos()
   RETURNS TABLE
   AS RETURN (SELECT * FROM FUNCIONARIO WHERE Status = 'Ativo');
   ```

3. **Validação de Parâmetros**
   ```sql
   CREATE FUNCTION dbo.CalcularDesconto(@Valor DECIMAL(10,2), @Percentual DECIMAL(5,2))
   RETURNS DECIMAL(10,2)
   AS
   BEGIN
       IF @Valor IS NULL OR @Valor <= 0 OR @Percentual IS NULL
           RETURN 0;
           
       RETURN @Valor * (@Percentual / 100);
   END;
   ```

4. **Documentação**
   ```sql
   /*
   Função: dbo.CalcularIdade
   Descrição: Calcula a idade precisa em anos considerando mês e dia
   Parâmetros: @DataNasc - Data de nascimento
   Retorno: Idade em anos (INT)
   Autor: Vinicius Arruda
   Data: 2025-01-XX
   */
   CREATE FUNCTION dbo.CalcularIdade(@DataNasc DATE)...
   ```

### ❌ **O que Evitar**

- Funções escalares em grandes volumes de dados
- Lógica muito complexa em funções inline
- Funções que não retornam valores consistentes
- Uso excessivo de multi-statement quando inline resolve

---

## 🔧 Exemplos Práticos

### **Gerenciamento de Funções**

```sql
-- Listar todas as funções do usuário
SELECT 
    name AS NomeFuncao,
    type_desc AS TipoFuncao,
    create_date AS DataCriacao
FROM sys.objects 
WHERE type IN ('FN', 'IF', 'TF')
ORDER BY name;

-- Excluir uma função
DROP FUNCTION IF EXISTS dbo.CalcularIdade;

-- Alterar uma função existente
ALTER FUNCTION dbo.CalcularIdade(@DataNasc DATE)
RETURNS INT
AS
BEGIN
    -- Nova implementação
    RETURN DATEDIFF(YEAR, @DataNasc, GETDATE());
END;
```

---

## ⚡ Considerações de Performance

### **Melhores Práticas de Performance**

1. **Evite funções escalares em WHERE com grandes tabelas**
   ```sql
   -- ❌ Pode ser lento
   SELECT * FROM FUNCIONARIO 
   WHERE dbo.CalcularIdade(DataNasc) > 30;
   
   -- ✅ Melhor alternativa
   SELECT * FROM FUNCIONARIO 
   WHERE DATEDIFF(YEAR, DataNasc, GETDATE()) > 30;
   ```

2. **Prefira funções inline para consultas de tabela**
   ```sql
   -- ✅ Mais eficiente
   CREATE FUNCTION dbo.FuncionariosVendas()
   RETURNS TABLE
   AS RETURN (
       SELECT * FROM FUNCIONARIO WHERE Departamento = 'Vendas'
   );
   ```

*Este estudo cobre os conceitos fundamentais para implementação de bancos de dados ativos no SQL Server, fornecendo base sólida para desenvolvimento de soluções robustas e eficientes.*