-- AULA IMPLEMENTACAO BANCO DE DADOS DIA - 09/09/25 
-- CONTEUDO PROCEDURE 

--stored Procedure 
/*São lotes (batches) de declarações SQL que podem ser executados como uma subrotina.
Permitem centralizar a lógica de acesso aos dados em único local, facilitando a manutenção e otimização de código.
Também é possível ajustar permissões de acesso aos usuários, definindo quem pode ou não executá-las
*/

-- Crie um procedimento que exiba seu nome.
CREATE PROCEDURE sp_ExibirMeuNome 
AS 
BEGIN 
    PRINT 'Vinicius Arruda';
END
GO

EXEC sp_ExibirMeuNome; -- Comando de execucao para executar o PROCEDURE


-- Crie um procedure que liste o nome completo dos funcionários e o nome dos seus respectivos departamentos.
ALTER PROCEDURE sp_ListarNomes
AS 
BEGIN 
	SELECT 
		F.Pnome + ' ' + F.Minicial + ' ' + F.Unome AS NomeCompleto,
		D.Dnome AS NomeDepartamento
	FROM FUNCIONARIO AS F 
	FULL JOIN DEPARTAMENTO AS D 
		ON F.Dnr = D.Dnumero;
END
GO

-- Executar a procedure
EXEC sp_ListarNomes;

-- SP HELP = Use o procedimento armazenado sp_helptext para extrair o conteúdo de texto de um stored procedure.
--EXEC sp_helptext nome_procedimento

CREATE PROCEDURE sp_ExibirFunc
WITH ENCRYPTION
AS 
BEGIN 
   SELECT *
   FROM FUNCIONARIO;
END
GO

EXEC sp_ExibirFunc;

EXEC sp_helptext sp_ExibirFunc;

-- Exemplo 2 alteracao
ALTER PROCEDURE sp_ListarNomes
	@nome_dpt VARCHAR(100) 
AS 
BEGIN 
	SELECT 
		F.Pnome + ' ' + F.Minicial + ' ' + F.Unome AS NomeCompleto,
		D.Dnome AS NomeDepartamento
	FROM FUNCIONARIO AS F 
	FULL JOIN DEPARTAMENTO AS D 
		ON F.Dnr = D.Dnumero
	WHERE D.Dnome = @nome_dpt;
END
GO

EXEC sp_ListarNomes @nome_dpt = 'Matriz';


-- Crie uma procedure que atualiza o salário de um funcionário baseado no CPF, 
-- se não encontrar nenhum funcionário com o CPF passado exiba uma mensagem

CREATE PROCEDURE sp_AtualizarSalarioFunc
	@Cpf VARCHAR(11),
	@Porcentagem DECIMAL(10,2)
AS 
BEGIN
	UPDATE FUNCIONARIO 
	SET Salario = Salario * (@Porcentagem / 100 + 1)
	WHERE Cpf = @Cpf;
	--IF(EXISTS(SELECT 1 FROM FUNCIONARIO WHERE Cpf = @Cpf)
	IF @@ROWCOUNT = 0
		PRINT 'Nenhum registro alterado';
	ELSE
		SELECT Pnome, Salario FROM FUNCIONARIO WHERE Cpf = @Cpf;
END
GO
SELECT * FROM FUNCIONARIO;
EXEC sp_AtualizarSalarioFunc '122311', 10;
GO


CREATE PROCEDURE sp_consultaFuncionario
	@Pnome VARCHAR(100) = NULL,
	@Unome VARCHAR(100) = NULL,
	@Sexo CHAR(1) = 'M'
AS
BEGIN 
	SELECT *
	FROM FUNCIONARIO AS F 
	WHERE 
		(@Pnome IS NULL OR F.Pnome = @Pnome)
		AND (@Unome IS NULL OR F.Unome = @Unome)
		AND (F.Sexo = @Sexo);
END
EXEC sp_consultaFuncionario
GO



-- Crie um PROCEDURE que insira um novo departamento com sua respectiva localidade

ALTER PROCEDURE sp_InserirNovoDepartamento
	@Dnome VARCHAR(15),
	@Dnumero INT,
	@Dlocal VARCHAR(15)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM DEPARTAMENTO WHERE Dnome = @Dnome)
	BEGIN
		PRINT 'Departamento já cadastrado!';
	END
	ELSE
	BEGIN
		-- Inserir na tabela DEPARTAMENTO
		INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
		VALUES (@Dnumero, @Dnome);

		-- Inserir na tabela LOCALIZACAO_DEP
		INSERT INTO LOCALIZACAO_DEP (Dnumero, Dlocal)
		VALUES (@Dnumero, @Dlocal);

		PRINT 'Departamento inserido com sucesso.';
	END
END
GO

-- Exemplo de consulta para validar inserção
SELECT D.Dnumero, LD.Dlocal
FROM DEPARTAMENTO AS D
FULL JOIN LOCALIZACAO_DEP AS LD
	ON D.Dnumero = LD.Dnumero;
GO

-- Exemplos de execução
EXEC sp_InserirNovoDepartamento 'Producao', 11, 'São Sepé';
EXEC sp_InserirNovoDepartamento 'Pesquisa', 1050, 'Santa Maria';


SELECT * FROM DEPARTAMENTO;
SELECT * FROM LOCALIZACAO_DEP;


ALTER PROCEDURE sp_ListarNomes
	@Nome_dpt VARCHAR(100) = NULL
AS 
BEGIN 
	IF @Nome_dpt IS NULL
	BEGIN
		SELECT 
			F.Pnome + ' ' + F.Minicial + ' ' + F.Unome AS Nome,
			D.Dnome AS NomeDepartamento
		FROM FUNCIONARIO AS F 
		FULL JOIN DEPARTAMENTO AS D 
			ON F.Dnr = D.Dnumero;
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM DEPARTAMENTO WHERE Dnome = @Nome_dpt)
	BEGIN
		PRINT 'Departamento não encontrado';
	END
	ELSE
	BEGIN
		SELECT 
			F.Pnome + ' ' + F.Minicial + ' ' + F.Unome AS Nome,
			D.Dnome AS NomeDepartamento
		FROM FUNCIONARIO AS F 
		FULL JOIN DEPARTAMENTO AS D 
			ON F.Dnr = D.Dnumero
		WHERE D.Dnome = @Nome_dpt;
	END
END
GO

EXEC sp_ListarNomes;
EXEC sp_ListarNomes @Nome_dpt = 'Pesquisa';
EXEC sp_ListarNomes @Nome_dpt = 'Inexistente';



CREATE PROCEDURE TesteDobroComReturn
	@par1 INT
AS
BEGIN
	RETURN @par1 * 2;
END
GO


