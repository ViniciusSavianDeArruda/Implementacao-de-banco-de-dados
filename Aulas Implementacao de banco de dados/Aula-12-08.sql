--Aula implementacao de banco de dados dia 12/08/25---
-- Consultas SQL Banco de dados empresa

--INNER JOIN: Retorna registros que possuem valores correspondentes em ambas as tabelas
--LEFT JOIN: Retorna todos os registros da tabela da esquerda e os registros correspondentes da tabela da direita
--RIGHT	JOIN:	retorna  todos  os  registros  da  tabela  da  direita  e  os  registros correspondentes da tabela da esquerda
--CROSS JOIN: Retorna todos os registros de ambas as tabelas


-- INNER JOIN
--Selecionar o primeiro nome, �ltimo nome, endere�o dos funcion�rios que trabalham no departamento de �Pesquisa�.
SELECT F.Pnome, F.Unome, F.Endereco 
FROM FUNCIONARIO F
INNER JOIN DEPARTAMENTO D
ON F.Dnr = D.Dnumero
WHERE D.Dnome = 'Pesquisa';
GO

--Liste o nome dos funcion�rios que est�o desenvolvendo o �ProdutoX�.
SELECT F.Pnome, F.Unome
FROM FUNCIONARIO F
INNER JOIN TRABALHA_EM T ON F.Cpf = T.Fcpf
INNER JOIN PROJETO P ON T.Pnr = P.Projnumero
WHERE P.Projnome = 'ProdutoX';
GO

--Para cada projeto localizado em �Mau�, liste o n�mero do projeto, 
--o n�mero do departamento que o controla e o sobrenome, endere�o e data de nascimento do gerente do departamento.
SELECT P.Projnome, P.Projnumero, D.Dnome, D.Dnumero, F.Unome, F.Endereco, F.Datanasc
FROM FUNCIONARIO AS F
INNER JOIN DEPARTAMENTO AS D
	ON D.Cpf_gerente = F.Cpf
INNER JOIN LOCALIZACAO_DEP AS LD
	ON LD.Dnumero = D.Dnumero
INNER JOIN PROJETO AS P
	ON P.Dnum = D.Dnumero
WHERE LD.Dlocal = 'Mau�';
GO

--LEFT JOIN
--Liste o �ltimo nome de TODOS os funcion�rios e o �ltimo nome dos respectivos gerentes, caso possuam
SELECT *
FROM FUNCIONARIO AS F 
WHERE F.Cpf_supervisor IS NOT NULL;
GO

SELECT F.Pnome AS 'Funcionario_Nome', G.Pnome AS 'Gerente_Nome'
FROM FUNCIONARIO AS F
LEFT JOIN FUNCIONARIO AS G ON F.Cpf_supervisor = G.Cpf
GO

--Encontre os funcion�rios que n�o possuem um departamento a eles vinculado
SELECT *
FROM FUNCIONARIO AS F
LEFT JOIN DEPARTAMENTO AS D ON D.Dnumero = f.Dnr
WHERE F.Dnr IS NULL 
GO

SELECT *
FROM DEPARTAMENTO AS D
LEFT JOIN FUNCIONARIO AS F ON D.Dnumero = f.Dnr
WHERE F.Cpf IS NULL 
GO

SELECT *
FROM DEPARTAMENTO AS D
WHERE D.Dnumero NOT IN (
    SELECT DISTINCT F.Dnr
    FROM FUNCIONARIO AS F
    WHERE F.Dnr IS NOT NULL
);
GO


--NOT EXISTS()
SELECT *
FROM DEPARTAMENTO AS D 
WHERE NOT EXISTS (SELECT 1 FROM FUNCIONARIO AS F WHERE F.Dnr = D.Dnumero);
GO


--RIGHT JOIN 
--Quais sao os funcionarios que nao pussem dependentes
SELECT *
FROM DEPENDENTE AS D
RIGHT JOIN FUNCIONARIO AS F ON F.Cpf = D.Fcpf
WHERE D.Nome_dependente IS NULL;
GO

--FULL JOIN
SELECT *
FROM FUNCIONARIO AS F 
FULL JOIN DEPARTAMENTO AS D ON D.Dnumero = F.Dnr;
GO

--CROSS JOIN
SELECT *
FROM FUNCIONARIO AS F
CROSS JOIN DEPARTAMENTO AS D
WHERE D.Dnumero = F.Dnr;
GO


--UNION 
SELECT D.Nome_dependente AS Nome, D.Sexo, D.Datanasc
FROM DEPENDENTE AS D
UNION
SELECT F.Pnome AS Nome, F.Sexo, F.Datanasc
FROM FUNCIONARIO�AS�F;
GO




