-- Aula IMPLEMENTACAO BANCO DE DADOS 30- 09- 2025 e continuacao TRANSACTION Dia 07-10-2025
---CASE
SELECT
	F.Pnome,
	F.Salario,
	CASE 
		WHEN F.Salario < 20000 THEN 'Baixo'
		WHEN F.Salario BETWEEN 20000 AND 40000 THEN 'Medio'
		WHEN F.Salario > 40000 THEN 'Alto'
		ELSE 'Invalido'
	END AS 'Status'
FROM FUNCIONARIO AS F;

--TRANSACTION
BEGIN TRANSACTION;

DECLARE @Erro INT;

-- Insira um novo funcionário
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Carlos', 'M', 'Almeida', '98765432100', '1991-07-23', 'Av. Brasil, 500', 'M', 4500, NULL, 2);

SET @Erro = @@ERROR;

-- Insira um novo departamento
INSERT INTO DEPARTAMENTO (Dnumero, Dnome, Cpf_gerente, Data_inicio_gerente)
VALUES (10, 'Marketing', '98765432100', '2023-09-29');

SET @Erro = @Erro + @@ERROR;

-- Verifique se houve erro
IF @@ERROR <> 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Erro detectado. Transação revertida.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transação concluída com sucesso.';
END;

--Crie uma transação que atualize o salário de todos os funcionários de um determinado departamento.
--Se a atualização de qualquer funcionário falhar, reverta todas as alterações.
DECLARE @qtdF INT;
DECLARE @opt INT = 5;
DECLARE @erro INT;

BEGIN TRANSACTION;

SELECT @qtdF = COUNT(F.cpf)
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D ON D.Dnumero = F.Dnr
WHERE D.Dnumero = @opt;

PRINT 'Funcionários encontrados: ' + CAST(@qtdF AS VARCHAR);

SET Salario = Salario * 2
WHERE Dnr = @opt;

SET @erro = @@ERROR;

IF @erro <> 0
BEGIN
    ROLLBACK;
    PRINT 'Erro na atualização. Transação revertida.';
END
ELSE
BEGIN
    COMMIT;
    PRINT 'Salários atualizados com sucesso.';
END;


BEGIN TRAN
DECLARE @e INT = 0;


INSERT INTO FUNCIONARIO(Pnome, Unome, Minicial, Cpf)
VALUES('Juca', 'Rodrigues', 'F', '0800');
SET @e = @@ERROR + @e;

SELECT * FROM FUNCIONARIO;

INSERT INTO DEPARTAMENTO(Dnumero, Dnome)
VALUES(1, 'Marketing');
SET @e = @@ERROR + @e;

IF @e <> 0 
	ROLLBACK TRANSACTION; 
ELSE
	COMMIT TRANSACTION;
--------------------------------------
BEGIN TRANSACTION

DECLARE @r INT = 0;

UPDATE FUNCIONARIO 
SET Datanasc = '1988-01-19'
WHERE cpf = '99988777767'
SET @r = @@ROWCOUNT;

SELECT *FROM FUNCIONARIO;

IF @r <> 1
BEGIN 
	ROLLBACK TRANSACTION;
	PRINT 'Foram alterados mais registros que o esperado' + @r
END
ELSE 
	COMMIT TRANSACTION;

	select *from FUNCIONARIO;
----------------------------------------------
--Transacao 1: Definido nivel de isolamento para serializable
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN;
SELECT *FROM FUNCIONARIO
PRINT 'SELECT concluido em: '+ CONVERT(VARCHAR(30), SYSDATETIME(), 121);


--- Mantem a transacao aberta por 20 segundos
WAITFOR DELAY '00:00:20'
PRINT 'TRANSACTION finalizada em: '+ CONVERT(VARCHAR(30), SYSDATETIME(), 121);

COMMIT TRAN;

---TRANSACTION 2
BEGIN TRAN;

INSERT INTO FUNCIONARIO(Pnome, Unome, Minicial, Cpf)
VALUES('Genoveva', 'Rodrigues', 'F', '98765400');
PRINT 'INSERT concluido em: '+ CONVERT(VARCHAR(30), SYSDATETIME(), 121);

COMMIT TRAN;

---------------------------------
--transaction + SAVE POINT
BEGIN TRAN;

INSERT INTO DEPARTAMENTO(Dnumero, Dnome)
VALUES (81, 'TesteA');

--Marca um ponto de retorno
SAVE TRAN P1;
-- segundo insert(que sera desfeito)
INSERT INTO DEPARTAMENTO(Dnumero, Dnome)
VALUES (81, 'TesteB');

--Confirmacao na transacao
SELECT *FROM DEPARTAMENTO;

ROLLBACK TRAN P1

COMMIT;

--Confirmacao estado final
SELECT *FROM DEPARTAMENTO;
------------------------------------------

--TRAY CATHC
BEGIN TRY 
	SELECT 1/0;
	PRINT 'Nao cheguei aqui'
END TRY
BEGIN CATCH 
	PRINT 'Deu erro!';
	PRINT 'Numero:' + CAST(ERROR_NUMBER() AS VARCHAR(20));
	PRINT 'Mensagem:' + ERROR_MESSAGE();
END CATCH
--------------------------------------------

---TRIGGER 
CREATE TRIGGER trg_Insert_Trigger
ON FUNCIONARIO
INSTEAD OF INSERT 
AS
BEGIN
	PRINT 'Ola mundo';
	PRINT 'FUNCIONARIO NAO INSERIDO!' 
END
GO

ALTER TABLE FUNCIONARIO
DISABLE TRIGGER trg_Insert_Trigger

INSERT INTO FUNCIONARIO(Pnome, Minicial,Unome,Cpf)
VALUES('Vinicius', 'A', 'Arruda', '1223457876');

EXEC 
------------------------------------------
CREATE OR ALTER TRIGGER tgr_AlteracaoSalario
ON FUNCIONARIO
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @salarioAntigo VARCHAR(20);
	DECLARE @salarioNovo VARCHAR(20);

	SELECT @salarioNovo = i.Salario
	FROM inserted i;

	SELECT @salarioAntigo =d.Salario
	FROM deleted d;

	IF UPDATE(Salario) 
		PRINT'O Salario anterior' + @salarioAntigo
	ELSE 
		PRINT 'Salario novo' + @salarioNovo
END
GO

INSERT INTO FUNCIONARIO(Pnome, Minicial,Unome,Cpf)
VALUES('Marcos', 'M', 'silva', '15623453465');

UPDATE FUNCIONARIO
SET Salario = 10000
WHERE CPF = '1231231'


UPDATE FUNCIONARIO
SET Dnr = 1
WHERE CPF = '1231231'
----------------------------------------------------------

--Exercicio SQL TRANSCTION
-- 1.Autocommit × Transação Explícita Tarefa: Insira dois departamentos: um em modo autocommit e outro dentro de uma transação explícita. 
-- Em seguida, desfaça o segundo (Rollback) e confirme o primeiro. Entregável: Demonstre, por consulta, qual linha permaneceu e explique por quê.

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Compras', 9);

BEGIN TRANSACTION;

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Marketing', 10);

SELECT * FROM DEPARTAMENTO;

ROLLBACK TRANSACTION;

SELECT * FROM DEPARTAMENTO;
GO
--------------------------------------------------
BEGIN TRANSACTION;

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Recursos Humanos',10);

SELECT * 
FROM DEPARTAMENTO WHERE Dnumero = 10;

ROLLBACK TRANSACTION;

SELECT * FROM DEPARTAMENTO WHERE Dnumero = 10;
-- O primeiro INSERT compras foi gravado imediatamente.
-- O segundo INSERT (Marketing) estava dentro da transação. Depois do ROLLBACK TRANSACTION, foi desfeito.
-- So o departamento compras permanece
-------------------------------------------------------------------------------
BEGIN TRANSACTION;

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Recursos Humanos', 100);

SAVE TRANSACTION primeiro_insert;

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Marketing', 101);

ROLLBACK TRANSACTION primeiro_insert;

COMMIT TRANSACTION;

SELECT * FROM DEPARTAMENTO;


