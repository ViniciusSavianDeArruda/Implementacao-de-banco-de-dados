-- AULA IMPLEMENTACAO DE BANCO DE DADOS - 02/08

--Criar uma função que calcula a idade de um funcionário com base na data de nascimento
CREATE FUNCTION fn_CalcularIdade(@Datanasc DATE)
RETURNS INT
AS 
BEGIN
    DECLARE @Idade INT;
    
    SET @Idade = DATEDIFF(YEAR, @Datanasc, GETDATE());
  
    IF (MONTH(@Datanasc) > MONTH(GETDATE())
        OR (MONTH(@Datanasc) = MONTH(GETDATE()) AND DAY(@Datanasc) > DAY(GETDATE())))
    BEGIN
        SET @Idade = @Idade - 1;
    END
    
    RETURN @Idade;
END;
GO

SELECT F.Pnome, F.Datanasc, fn_CalcularIdade(F.Datanasc) AS 'Idade'
FROM FUNCIONARIO AS F;


-- Função para retornar todos os funcionários de um determinado departamento
CREATE FUNCTION fn_Funcionario(@NomeDpt VARCHAR(15))
RETURNS TABLE 
AS
RETURN
(
    SELECT F.Pnome, F.Unome, D.Dnome
    FROM FUNCIONARIO AS F 
    INNER JOIN DEPARTAMENTO AS D 
    ON F.Dnr = D.Dnumero
    WHERE D.Dnome = @NomeDpt
);
GO


--Criar uma função que retorna nome completo dos funcionários e o valor do salário anual, com férias e décimo terceiro

CREATE FUNCTION fn_SalarioAnul(@Cpf AS VARCHAR(11))
RETURNS @tabela TABLE
(
    NomeCompleto VARCHAR(150),
    SalarioMensal DECIMAL(10,2),
    SalarioAnual DECIMAL(10,2)
)
AS 
BEGIN 
    
    INSERT INTO @tabela
    SELECT 
        CONCAT(F.Pnome, ' ', F.Minicial, '. ', F.Unome), 
        F.Salario, 
        (F.Salario * 12) + (F.Salario * 0.3) + F.Salario 
    FROM FUNCIONARIO AS F 
    WHERE F.Cpf = @Cpf;

    RETURN;
END
GO

SELECT * FROM dbo.fn_SalarioAnul('98765432100');



-- Queremos calcular o salário anual de um funcionário (12 meses), mas também considerar um bônus variável (%), passado como parâmetro.
CREATE FUNCTION fn_SalarioAnualComBonus(
    @Salario DECIMAL(10,2),
    @BonusPercentual DECIMAL(5,2)  
)
RETURNS DECIMAL(10,2)
AS 
BEGIN 
	DECLARE @SalarioAnul DECIMAL(10,2);

	SET @Salario = (@Salario *12) * (1 + @Bonus/100);

	RETURN @SalarioAnul;

END;

SELECT dbo.fn.salarioAnualComBonus('123144234', 10.00 AS Salario_Anual_Com_Bonus);