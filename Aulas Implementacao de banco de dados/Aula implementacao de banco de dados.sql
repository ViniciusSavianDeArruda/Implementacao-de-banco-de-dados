--AULA IMPLEMENTACAO DE DADOS - DIA 26/08/25
-- Consultas SQL banco de dados empresa
--DECLARE
--Declarando variaveis 
DECLARE @Valor INT,
        @texto VARCHAR (40),
        @data_nasc DATE,
        @dinheiro MONEY;

--SET
--Setando os valores das variaveis
SET @valor = 50;
SET @texto = 'Herryson R. Figueiredo';
SET @data_nasc = GETDATE();
SET @dinheiro = 50.50;

--Exibir os valores (consulta)

SELECT  @valor AS 'Idade', 
        @texto AS 'Nome', 
        @data_nasc AS 'U_Acesso',
        @dinheiro AS 'V.compra';

--PRINT
PRINT 'O valor contido na variavel @valor e:' + @texto;
PRINT 'O valor contido na variavel @valor e: ' +
        CAST (@valor AS VARCHAR (10));


--Recupere o nome do departamento com Dnumero = 4.
DECLARE @dtp_num INT;
SET @dtp_num = 4;

SELECT *
FROM DEPARTAMENTO AS D 
WHERE D. Dnumero = @dtp_num;


-- Calculando o novo sal�rio com um aumento de 10%, para a Jennifer
DECLARE @nome_funcionario VARCHAR (100),
        @salario DECIMAL(10,2),
        @aumento DECIMAL(10,2),
        @novo_salario DECIMAL(10,2);
SET @nome_funcionario = 'Jennifer';
SET @aumento = 10;
SELECT @salario = F.Salario
FROM FUNCIONARIO AS F 
WHERE F.Pnome = @nome_funcionario;
SET @novo_salario = @salario * (1 + @aumento/100);
SELECT @nome_funcionario AS 'Nome', @salario AS 'salario_c',
        @aumento AS '%', @novo_salario AS 'salario'; 



-- Calculando a idade de Jennifer
DECLARE @nome_funcionario VARCHAR(100),
        @ano_atual INT,
        @idade INT,
        @ano_nasc INT;

SET @ano_atual = YEAR(GETDATE());
SET @nome_funcionario = 'Jennifer';
SELECT @ano_nasc = YEAR(F.Datanasc)
FROM FUNCIONARIO AS F
WHERE F.Pnome = @nome_funcionario;
SET @idade = @ano_atual - @ano_nasc;
PRINT 'A ' + @nome_funcionario + ' tem ' + CAST(@idade AS VARCHAR(3)) + ' anos.';

-- Conversao de dados
-- CAST
-- CONVERT

SELECT CONVERT (NVARCHAR(10), F.Datanasc, 103) AS 'data_nasc'
FROM FUNCIONARIO AS F 
WHERE F.Pnome = 'Jennifer';

SELECT CONVERT (NVARCHAR(10), F.Datanasc, 112) AS 'data_nasc'
FROM FUNCIONARIO AS F 
WHERE F.Pnome = 'Jennifer';

-- CONCAT
SELECT CONCAT(F.Pnome, ' ', F.Minicial, ' ', F.Unome) AS 'Nome completo',
        F.endereco
FROM FUNCIONARIO AS F;

--IF, ELSE
-- Verificar se um Funcion�rio Recebe Abaixo da M�dia Salarial
DECLARE @nome_funcionario VARCHAR(100),
        @salario DECIMAL(10,2),
        @media_salarial DECIMAL(10,2);

SELECT @nome_funcionario = 'Jo�o';
SELECT @media_salarial = AVG(F.Salario)
FROM FUNCIONARIO AS F;
SELECT @salario = F.Salario
FROM FUNCIONARIO AS F
WHERE F.Pnome = @nome_funcionario;
IF @salario < @media_salarial
    PRINT 'O funcion�rio recebe abaixo da m�dia salarial';
ELSE
    PRINT 'O funcion�rio recebe na m�dia ou acima da m�dia salarial';



-- Verificar se um Funcion�rio Est� Pr�ximo da Aposentadoria (idade 60 anos) usando DECLARE
DECLARE @nome_func VARCHAR(100),
        @idade INT;

SELECT @nome_func = 'Jennifer';
SELECT @idade = DATEDIFF(YEAR, F.Datanasc, GETDATE())
FROM FUNCIONARIO AS F
WHERE F.Pnome = @nome_func;

IF @idade >= 55
    PRINT @nome_func + ' est� pr�ximo da aposentadoria.';
ELSE
    PRINT @nome_func + ' ainda n�o est� pr�ximo da aposentadoria.';

---
DECLARE @datanasc DATE,
        @nome_func VARCHAR(100),
        @idade INT;

SELECT @nome_func = 'Fernando';
SELECT @datanasc = F.Datanasc
FROM FUNCIONARIO AS F
WHERE F.Pnome = @nome_func;
SET @idade = DATEDIFF(YEAR, @datanasc, GETDATE());
IF (MONTH(GETDATE()) < MONTH(@datanasc)) 
   OR (MONTH(GETDATE()) = MONTH(@datanasc) AND DAY(GETDATE()) < DAY(@datanasc))
   SET @idade = @idade - 1;

SELECT 'Idade de ' + @nome_func + ': ' + CAST(@idade AS VARCHAR(3)) AS Resultado;


--WHILE
DECLARE @valor INT
SET @valor = 0
WHILE @valor < 10
BEGIN
    PRINT 'Numero: ' + CAST(@valor AS VARCHAR(3))
    SET @valor = @valor + 1
END


--Exercicios a fazer 

