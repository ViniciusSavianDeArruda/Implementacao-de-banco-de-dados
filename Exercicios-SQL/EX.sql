----- EXERCICIOS SQL

--Variaveis no sql server
-- 1.1 Declaração de Variáveis
DECLARE @NomeProduto VARCHAR(50);
DECLARE @QtdEstoque INT;
DECLARE @PrecoProduto DECIMAL(10,2);

-- 1.2 Atribuição de Valores
SET @NomeProduto = 'Notebook';
SET @QtdEstoque = 15;
SET @PrecoProduto = 2999.99;

-- 1.3 Exibição de Valores
PRINT 'Produto: ' + @NomeProduto;
PRINT 'Quantidade: ' + CAST(@QtdEstoque AS VARCHAR);
PRINT 'Preço: ' + CAST(@PrecoProduto AS VARCHAR);

SELECT @NomeProduto AS Produto,
       @QtdEstoque AS Quantidade,
       @PrecoProduto AS Preco;

-- 1.4 Cálculo utilizando Variáveis
DECLARE @SalarioBase DECIMAL(10,2) = 5000.00;
DECLARE @Bonus DECIMAL(10,2) = 800.00;
DECLARE @SalarioTotal DECIMAL(10,2);

SET @SalarioTotal = @SalarioBase + @Bonus;

PRINT 'Salário Total: ' + CAST(@SalarioTotal AS VARCHAR);
SELECT @SalarioTotal AS SalarioTotal;

--Conversao de dados
-- 2.1 CAST
SELECT CAST(GETDATE() AS VARCHAR(10)) AS DataCast;

-- 2.2 CONVERT
SELECT CONVERT(INT, 12345.67) AS NumeroConvertido;

-- 2.3 Exercício Prático
DECLARE @NumDecimal DECIMAL(10,2) = 123.45;
DECLARE @NumInteiro INT = 10;

SELECT CAST(@NumDecimal AS INT) AS DecimalParaInteiro,
       CONVERT(DECIMAL(10,2), @NumInteiro) AS InteiroParaDecimal;

-- 2.4 String para Data
DECLARE @DataNascimento VARCHAR(10) = '15/08/1990';
SELECT CONVERT(DATE, @DataNascimento, 103) AS DataConvertida;

--Estruturas condicionais
-- 3.1 IF / ELSE Básico
DECLARE @Idade INT = 20;
IF @Idade >= 18
    PRINT 'Maior de Idade';
ELSE
    PRINT 'Menor de Idade';

-- 3.2 IF / ELSE com múltiplas condições
DECLARE @NotaFinal INT = 85;

IF @NotaFinal >= 90
    PRINT 'Aprovado com Excelência';
ELSE IF @NotaFinal >= 70
    PRINT 'Aprovado';
ELSE IF @NotaFinal >= 50
    PRINT 'Em Recuperação';
ELSE
    PRINT 'Reprovado';

-- 3.3 Ano Bissexto
DECLARE @Ano INT = 2024;

IF ((@Ano % 4 = 0 AND @Ano % 100 <> 0) OR (@Ano % 400 = 0))
    PRINT 'Ano Bissexto';
ELSE
    PRINT 'Ano Comum';

--Loops SQL
-- 4.1 While Simples
DECLARE @Contador INT = 1;
WHILE @Contador <= 10
BEGIN
    PRINT CAST(@Contador AS VARCHAR);
    SET @Contador = @Contador + 1;
END;

-- 4.2 While com Condição Complexa
DECLARE @Valor INT = 100;
WHILE @Valor >= 50
BEGIN
    PRINT CAST(@Valor AS VARCHAR);
    SET @Valor = @Valor - 5;
END;

-- 4.3 Loop em tabela (Produtos > 100)

DECLARE @PrecoOriginal DECIMAL(10,2) = 100;
DECLARE @Quantidade INT = 12;
DECLARE @Desconto DECIMAL(5,2) = 0;
DECLARE @PrecoFinal DECIMAL(10,2);

IF @Quantidade > 10
    SET @Desconto = 0.10;
ELSE IF @Quantidade < 5
BEGIN
    DECLARE @i INT = 2;
    WHILE @i <= @Quantidade
    BEGIN
        SET @Desconto = @Desconto + 0.01;
        SET @i = @i + 1;
    END;
END;

SET @PrecoFinal = @PrecoOriginal * @Quantidade * (1 - @Desconto);

PRINT 'Preço Final: ' + CAST(@PrecoFinal AS VARCHAR);
SELECT @PrecoFinal AS PrecoFinal, @Desconto AS DescontoAplicado;


-- 4.4 Loop dobrando número
DECLARE @Numero INT = 2;
WHILE @Numero <= 1000
BEGIN
    PRINT CAST(@Numero AS VARCHAR);
    SET @Numero = @Numero * 2;
END;

-- Exercício de Integração - Procedimento
DECLARE @PrecoOriginal DECIMAL(10,2) = 100;
DECLARE @Quantidade INT = 12;
DECLARE @Desconto DECIMAL(5,2) = 0;
DECLARE @PrecoFinal DECIMAL(10,2);

IF @Quantidade > 10
    SET @Desconto = 0.10;
ELSE IF @Quantidade < 5
BEGIN
    DECLARE @i INT = 2;
    WHILE @i <= @Quantidade
    BEGIN
        SET @Desconto = @Desconto + 0.01;
        SET @i = @i + 1;
    END;
END;

SET @PrecoFinal = @PrecoOriginal * @Quantidade * (1 - @Desconto);

SELECT @PrecoFinal AS PrecoFinal, @Desconto AS DescontoAplicado;