-- Aula dia 30-09-2025
-- Correcao Prova e transacoes

-- 7) 
SELECT 
	A.Nome AS 'Alunos',
	D.Nome_disciplina AS 'Disciplina',
	HE.Nota AS 'Nota'
FROM ALUNO AS A
INNER JOIN HISTORICO_ESCOLAR AS HE ON A.Numero_aluno = HE.Numero_aluno
INNER JOIN TURMA AS T ON T.Identificacao_turma = HE.Identificacao_turma
INNER JOIN DISCIPLINA AS D ON D.Numero_disciplina = T.Numero_disciplina
WHERE D.Nome_disciplina = 'Banco de dados';


-- 8)
SELECT 
	D.Nome_disciplina,
	DPR.Nome_disciplina
FROM DISCIPLINA AS D
INNER JOIN PRE_REQUISITO AS PR 
	ON D.Numero_disciplina = PR.Numero_disciplina
INNER JOIN DISCIPLINA AS DPR
	ON DPR.Numero_disciplina = PR.Numero_pre_requisito

-- 9)
SELECT 
	D.Nome_disciplina,
	T.Semestre,
	T.Ano,
	HE.Nota
FROM ALUNO AS A
INNER JOIN HISTORICO_ESCOLAR AS HE ON A.Numero_aluno = HE.Numero_aluno
INNER JOIN TURMA AS T ON T.Identificacao_turma = HE.Identificacao_turma
INNER JOIN DISCIPLINA AS D ON D.Numero_disciplina = T.Numero_disciplina
WHERE A.Nome = 'Silva';

GO

-- 10)
CREATE OR ALTER FUNCTION fn_statusAprvacaoAluno
(
	@NomeAluno VARCHAR(50),
	@NomeDisciplina VARCHAR(50)
)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @nota CHAR(1);
	DECLARE @status VARCHAR(20)

	SELECT @nota = HE.Nota
FROM ALUNO AS A
INNER JOIN HISTORICO_ESCOLAR AS HE ON A.Numero_aluno = HE.Numero_aluno
INNER JOIN TURMA AS T ON T.Identificacao_turma = HE.Identificacao_turma
INNER JOIN DISCIPLINA AS D ON D.Numero_disciplina = T.Numero_disciplina
WHERE A.Nome = @NomeAluno AND D.Nome_disciplina = @NomeDisciplina

IF @nota = 'A' OR @nota = 'B'
	SET @status = 'Aprovado'
ELSE IF @nota = 'C'
	SET @status = 'Em Recuperacao'
ELSE IF @nota = 'F'
	SET @status = 'Reprovado'
ELSE 
	SET @status = 'Sem registro'
RETURN @status;
END;
GO
SELECT dbo.fn_statusAprvacaoAluno ('Silva', 'Matematica discreta') AS 'StatusAprovacao';


-- 11)



--12)
GO
CREATE OR ALTER FUNCTION fn_statusLocacao(@IdTurma INT)
RETURNS VARCHAR (30);
AS
BEGIN
	DECLARE @qtd INT;
	DECLARE @status VARCHAR(30);

	SELECT @qtd = COUNT(*)
	FROM HISTORICO_ESCOLAR
	WHERE Identificacao_turma = @IdTurma;

	IF(@qtd > = 5)
		SET @status = 'Completamente Lotada'
	ELSE IF( @qtd BETWEEN 3 AND 4)
		SET @status = 'Quase cheio'
	ELSE 
		SET @status = 'Com vagas'
	RETURN @status;
END;
GO
SELECT DISTINCT
	T.Identificacao_turma,
	D.Nome_disciplina,
	dbo.fn_statusLotacao(T.identificacao_turma) AS 'Status'
FROM HISTORICO_ESCOLAR AS HE
JOIN TURMA AS T ON HE.Identificacao_turma = T.Identificacao_turma
JOIN DISCIPLINA AS D ON T.Numero_disciplina = D.Numero_disciplina

-- 13)
GO
CREATE OR ALTER PROCEDURE usp_CalcularIdade
	@NumeroAluno INT
AS 
BEGIN
	DECLARE @dataAtual DATE;
	DECLARE @dataNasc DATE;
	DECLARE @Idade INT;

	SET @dataAtual = GETDATE();

	SELECT @dataNasc = A.Data_Nascimento
	FROM ALUNO AS A
	WHERE A.Numero_aluno = @NumeroAluno;

	SET @Idade = DATEDIFF(YEAR @dataNasc, @dataAtual)

	IF(MONTH(@dataNasc) > MONTH(@dataAtual)
		OR (MONTH(@dataNasc) = MONTH(@dataAtual) AND DAY(@dataNasc) > DAY (@dataAtual)))
		SET @Idade = @Idade -1;


-- CONTINUACAO AULA, TRANSACOES
/* 
O que s�o Transa��es no Banco de Dados?

Uma transa��o � um conjunto de opera��es SQL (como INSERT, UPDATE, DELETE) que s�o executadas como uma �nica unidade l�gica. 
Ou tudo � feito com sucesso, ou nada � feito.
======================================================
Conceito ACID (quatro pilares das transa��es)
ACID garante que as transa��es sejam seguras e confi�veis:

Atomicidade
Tudo ou nada.
Se uma parte da transa��o falha, tudo � desfeito (rollback).
Garante que n�o fiquem altera��es parciais no banco.
=================================================
Consist�ncia
Os dados devem sempre seguir as regras e restri��es do banco (como chaves estrangeiras, tipos de dados, etc).
Ap�s a transa��o, os dados ainda devem estar v�lidos e coerentes.
===================================================
Isolamento
Transa��es que ocorrem ao mesmo tempo n�o interferem umas nas outras.
O que uma transa��o faz n�o pode ser visto por outra at� ser finalizada.
====================================================
Durabilidade
Depois de um COMMIT, os dados ficam salvos permanentemente, mesmo se o sistema cair logo em seguida.
O banco garante que as altera��es foram gravadas no disco.
=========================================================
TRANSACTION = � utilizado para gerenciar uma sequ�ncia de opera��es (transa��es)no banco de dados, garantindo que essas opera��es sejam
executadas de maneira segura e consistente.
===========================================================
Comandos Relacionados a Transa��es:
BEGIN TRANSACTION: Inicia uma nova transa��o.
=====================================================
COMMIT TRANSACTION: Confirma a transa��o, aplicando permanentemente todas as opera��es feitas no banco de dados.
=================================================================
ROLLBACK TRANSACTION: Desfaz todas as opera��es realizadas desde o in�cio da transa��o.
===================================================================
SAVEPOINT: Define um ponto dentro de uma transa��o para permitir um rollback parcial, at� esse ponto
*/

--Exemplo
BEGIN TRANSACTION;

DECLARE @Erro INT;

-- Insira um novo funcion�rio
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
    PRINT 'Erro detectado. Transa��o revertida.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transa��o conclu�da com sucesso.';
END;

--Crie uma transa��o que atualize o sal�rio de todos os funcion�rios de um determinado departamento.
--Se a atualiza��o de qualquer funcion�rio falhar, reverta todas as altera��es.
DECLARE @qtdF INT;
DECLARE @opt INT = 5;
DECLARE @erro INT;

BEGIN TRANSACTION;

SELECT @qtdF = COUNT(F.cpf)
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D ON D.Dnumero = F.Dnr
WHERE D.Dnumero = @opt;

PRINT 'Funcion�rios encontrados: ' + CAST(@qtdF AS VARCHAR);

SET Salario = Salario * 2
WHERE Dnr = @opt;

SET @erro = @@ERROR;

IF @erro <> 0
BEGIN
    ROLLBACK;
    PRINT 'Erro na atualiza��o. Transa��o revertida.';
END
ELSE
BEGIN
    COMMIT;
    PRINT 'Sal�rios atualizados com sucesso.';
END;
