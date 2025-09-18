# Implementação de Banco de Dados - SQL Server

Guia completo sobre **SQL Server** com foco em bancos de dados ativos, variáveis, estruturas de controle, funções e stored procedures.

---

## 🔄 Bancos de Dados Ativos

**O que são:** Sistemas que reagem automaticamente a eventos (INSERT, UPDATE, DELETE) sem intervenção manual.

**Como funcionam:**
- **Triggers (Gatilhos):** Código que executa automaticamente quando algo acontece
- **Regras ECA:** Event-Condition-Action (Evento-Condição-Ação)
- **Validações:** Verificações automáticas de integridade

**Por que usar:**
- ✅ Automatiza processos
- ✅ Garante consistência dos dados
- ✅ Melhora segurança

---

## 📊 Variáveis

**O que são:** Espaços na memória para armazenar dados temporariamente durante a execução.

### Declaração
```sql
DECLARE @Nome VARCHAR(50);      -- Texto de até 50 caracteres
DECLARE @Idade INT;             -- Número inteiro
DECLARE @Salario DECIMAL(10,2); -- Número decimal (10 dígitos, 2 casas decimais)
```

### Tabelas Temporárias
```sql
-- Criar tabela só na memória (desaparece quando termina)
DECLARE @Funcionarios TABLE (
    Id INT,
    Nome VARCHAR(50),
    Cargo VARCHAR(30)
);

INSERT INTO @Funcionarios VALUES (1, 'João', 'Analista');
SELECT * FROM @Funcionarios;
```

### Atribuir Valores
```sql
SET @Nome = 'Maria';                    -- Um valor por vez
SELECT @Nome = 'Pedro', @Idade = 30;    -- Vários valores juntos
SELECT @Total = COUNT(*) FROM Tabela;   -- Valor de uma consulta
```

---

## 🔄 Conversão de Dados

**Por que usar:** Transformar dados de um tipo para outro (ex: número para texto).

### CAST vs CONVERT
```sql
-- CAST: Conversão simples
SELECT 'Idade: ' + CAST(@Idade AS VARCHAR);

-- CONVERT: Conversão com formatação especial
SELECT CONVERT(VARCHAR(10), GETDATE(), 103);  -- Data no formato DD/MM/AAAA
```

---

## 🔀 Estruturas de Controle

**O que são:** Comandos que controlam o fluxo de execução do código.

### IF/ELSE (Se/Senão)
```sql
IF @Idade >= 18
    PRINT 'Maior de idade';
ELSE
    PRINT 'Menor de idade';
```

### CASE (Múltiplas Condições)
```sql
-- Funciona como um "se" com várias opções
SELECT nome,
       CASE 
           WHEN salario > 5000 THEN 'Salário Alto'
           WHEN salario > 2000 THEN 'Salário Médio'
           ELSE 'Salário Baixo'
       END AS Categoria
FROM Funcionarios;
```

### WHILE (Repetição)
```sql
DECLARE @contador INT = 1;

WHILE @contador <= 5  -- Enquanto contador for menor/igual a 5
BEGIN
    PRINT 'Número: ' + CAST(@contador AS VARCHAR);
    SET @contador = @contador + 1;  -- Incrementa contador
END;
```

### Controles de Loop
```sql
BREAK;     -- Para o loop imediatamente
CONTINUE;  -- Pula para a próxima iteração
```

---

## ⚙️ Funções

**O que são:** Códigos reutilizáveis que sempre retornam um resultado (valor ou tabela).

**Diferença de Procedure:** Funções sempre retornam algo e podem ser usadas em consultas.

### Tipos de Funções

| Tipo | Retorna | Quando Usar |
|------|---------|-------------|
| **Escalar** | Um valor único | Cálculos simples |
| **Tabela Inline** | Uma tabela | Consultas parametrizadas rápidas |
| **Tabela Multi-Statement** | Uma tabela | Lógica complexa |

### Função Escalar (Retorna 1 Valor)
```sql
-- Calcula idade precisa
CREATE FUNCTION CalcularIdade (@DataNasc DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @DataNasc, GETDATE()) - 
           CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @DataNasc, GETDATE()), @DataNasc) > GETDATE() 
                THEN 1 ELSE 0 END;
END;

-- Usar a função
SELECT Nome, CalcularIdade(DataNascimento) AS Idade FROM Pessoas;
```

### Função de Tabela (Retorna Tabela)
```sql
-- Busca funcionários por departamento
CREATE FUNCTION FuncionariosPorSetor (@SetorID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT Nome, Cargo, Salario 
    FROM Funcionarios 
    WHERE SetorID = @SetorID
);

-- Usar como uma tabela normal
SELECT * FROM FuncionariosPorSetor(1);
```

---

## 📦 Stored Procedures

**O que são:** Conjuntos de comandos SQL salvos no banco que podem ser executados quando necessário.

**Diferença de Função:** Procedures podem modificar dados e não precisam retornar nada.

### Procedure Simples
```sql
CREATE PROCEDURE ListarTodosFuncionarios
AS
BEGIN
    SELECT * FROM Funcionarios ORDER BY Nome;
END;

-- Executar
EXEC ListarTodosFuncionarios;
```

### Procedure com Parâmetros de Entrada
```sql
CREATE PROCEDURE BuscarFuncionarioPorCPF 
    @CPF VARCHAR(11)
AS
BEGIN
    SELECT * FROM Funcionarios WHERE CPF = @CPF;
END;

-- Executar passando valor
EXEC BuscarFuncionarioPorCPF '12345678900';
```

### Procedure com Parâmetros de Saída
```sql
CREATE PROCEDURE ContarFuncionarios
    @SetorID INT,
    @Quantidade INT OUTPUT  -- Este valor "sai" da procedure
AS
BEGIN
    SELECT @Quantidade = COUNT(*) FROM Funcionarios WHERE SetorID = @SetorID;
END;

-- Executar e capturar resultado
DECLARE @Total INT;
EXEC ContarFuncionarios @SetorID = 1, @Quantidade = @Total OUTPUT;
PRINT 'Total de funcionários: ' + CAST(@Total AS VARCHAR);
```

### Procedure com Validações
```sql
CREATE PROCEDURE CadastrarFuncionario
    @Nome VARCHAR(50),
    @CPF VARCHAR(11),
    @Salario DECIMAL(10,2)
AS
BEGIN
    -- Validar dados
    IF @Nome IS NULL OR LEN(TRIM(@Nome)) = 0
    BEGIN
        PRINT 'ERRO: Nome é obrigatório';
        RETURN;  -- Para a execução aqui
    END;
    
    IF @Salario <= 0
    BEGIN
        PRINT 'ERRO: Salário deve ser maior que zero';
        RETURN;
    END;
    
    -- Se chegou aqui, dados estão OK
    INSERT INTO Funcionarios (Nome, CPF, Salario) 
    VALUES (@Nome, @CPF, @Salario);
    
    PRINT 'Funcionário cadastrado com sucesso!';
END;
```

---

## 💡 Resumo das Diferenças

| Conceito | O que faz | Retorna algo? | Pode modificar dados? |
|----------|-----------|---------------|----------------------|
| **Variável** | Armazena dados temporários | Não se aplica | Não se aplica |
| **Função** | Executa cálculos/consultas | ✅ Sempre | ❌ Não |
| **Procedure** | Executa conjunto de comandos | ⚠️ Opcional | ✅ Sim |
| **Trigger** | Executa automaticamente | ❌ Não | ✅ Sim |

---

## 🎯 Exemplo Prático Completo

### Sistema de Controle de Salários
```sql
-- 1. FUNÇÃO: Calcular desconto do INSS
CREATE FUNCTION CalcularINSS(@Salario DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Desconto DECIMAL(10,2);
    
    IF @Salario <= 1320
        SET @Desconto = @Salario * 0.075;      -- 7.5%
    ELSE IF @Salario <= 2571
        SET @Desconto = @Salario * 0.09;       -- 9%
    ELSE IF @Salario <= 3856
        SET @Desconto = @Salario * 0.12;       -- 12%
    ELSE
        SET @Desconto = @Salario * 0.14;       -- 14%
    
    RETURN @Desconto;
END;

-- 2. PROCEDURE: Processar folha de pagamento
CREATE PROCEDURE ProcessarFolha
    @SetorID INT,
    @TotalLiquido DECIMAL(15,2) OUTPUT
AS
BEGIN
    DECLARE @TotalBruto DECIMAL(15,2);
    DECLARE @TotalDescontos DECIMAL(15,2);
    
    -- Calcular totais
    SELECT 
        @TotalBruto = SUM(Salario),
        @TotalDescontos = SUM(CalcularINSS(Salario))
    FROM Funcionarios 
    WHERE SetorID = @SetorID;
    
    SET @TotalLiquido = @TotalBruto - @TotalDescontos;
    
    -- Mostrar resultado
    PRINT 'Folha processada!';
    PRINT 'Total Bruto: R$ ' + CAST(@TotalBruto AS VARCHAR);
    PRINT 'Total Descontos: R$ ' + CAST(@TotalDescontos AS VARCHAR);
    PRINT 'Total Líquido: R$ ' + CAST(@TotalLiquido AS VARCHAR);
END;

-- 3. EXECUTAR
DECLARE @Resultado DECIMAL(15,2);
EXEC ProcessarFolha @SetorID = 1, @TotalLiquido = @Resultado OUTPUT;
```

---

## 🚨 Dicas Importantes

### Segurança
```sql
-- ✅ CERTO: Use parâmetros
CREATE PROCEDURE BuscarUsuario @Nome VARCHAR(50)
AS
BEGIN
    SELECT * FROM Usuarios WHERE Nome = @Nome;
END;

-- ❌ ERRADO: Concatenação (vulnerável a SQL Injection)
-- 'SELECT * FROM Usuarios WHERE Nome = ''' + @Nome + ''''
```

### Performance
- **Funções escalares:** Evite em consultas grandes (pode ser lento)
- **Procedures:** Mais rápidas que código repetido
- **Índices:** Sempre use em colunas de busca frequente

### Manutenção
```sql
-- Alterar procedure existente
ALTER PROCEDURE NomeProcedure AS BEGIN ... END;

-- Excluir
DROP PROCEDURE NomeProcedure;
DROP FUNCTION NomeFuncao;
```

---

## 🛠️ Funções de Sistema Úteis

```sql
GETDATE()           -- Data/hora atual
DATEDIFF(YEAR, data1, data2)  -- Diferença em anos
YEAR(data)          -- Extrair ano
MONTH(data)         -- Extrair mês
CAST(valor AS tipo) -- Converter tipo
LEN(texto)          -- Tamanho do texto
UPPER(texto)        -- Maiúsculo
LOWER(texto)        -- Minúsculo
```

---

*Disciplina: Implementação de Banco de Dados*  
*Autor: Vinicius Savian De Arruda*  
*SQL Server - T-SQL*
