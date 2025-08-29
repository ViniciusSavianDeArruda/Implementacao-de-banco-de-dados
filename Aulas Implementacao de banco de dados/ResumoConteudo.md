# 📘 Implementação de Banco de Dados

Repositório com resumos e consultas SQL desenvolvidos na disciplina de **Implementação de Banco de Dados** (UFN – 2025/2).  
Aluno: **Vinicius Arruda**  

---

## 🔹 Conteúdos das Aulas  

### 📅 Aula 05/08/25 – Revisão (Consultas SQL básicas)  
- **DISTINCT** → remove valores duplicados de um resultado.  
- **WHERE** → filtra linhas de acordo com uma condição.  
- **AND / OR / NOT** → operadores lógicos para combinar condições.  
- **ORDER BY ASC/DESC** → ordena os resultados em ordem crescente ou decrescente.  
- **IS NULL / IS NOT NULL** → verifica se um campo está vazio ou não.  
- **TOP** → limita a quantidade de registros exibidos.  
- **Funções de agregação**:  
  - `MIN()` → menor valor  
  - `MAX()` → maior valor  
  - `COUNT()` → quantidade de registros  
  - `AVG()` → média  
  - `SUM()` → soma  
- **LIKE** → busca por padrões em texto (`%` para qualquer sequência, `_` para um caractere).  
- **IN** → verifica se um valor está em uma lista.  
- **BETWEEN** → filtra valores dentro de um intervalo.  
- **Subconsultas** → uma consulta dentro de outra.  
- **JOIN implícito (vírgula)** → forma antiga de juntar tabelas usando `FROM tabela1, tabela2`.  

---

### 📅 Aula 12/08/25 – Revisão (Joins)  
- **INNER JOIN** → retorna registros que têm correspondência nas duas tabelas.  
- **LEFT JOIN** → retorna todos os registros da esquerda e os correspondentes da direita (se não existir, vem `NULL`).  
- **RIGHT JOIN** → igual ao LEFT, mas prioriza a tabela da direita.  
- **FULL JOIN** → junta todos os registros das duas tabelas (mesmo sem correspondência).  
- **CROSS JOIN** → produto cartesiano (combina todas as linhas de uma tabela com todas da outra).  
- **NOT EXISTS** → retorna resultados apenas quando uma subconsulta **não** tem valores.  
- **UNION** → une resultados de duas consultas (sem duplicados por padrão).  

---

### 📅 Aula 26/08/25 – Conteúdo Novo (SQL Procedural – T-SQL)  
- **DECLARE / SET** → cria e atribui valores a variáveis.  
- **PRINT** → mostra mensagens no console do SQL.  
- **CAST / CONVERT / CONCAT** → funções para converter e manipular tipos de dados.  
- **IF / ELSE** → estruturas condicionais para tomar decisões.  
- **WHILE** → laço de repetição para executar comandos várias vezes.  
- **Exemplos práticos trabalhados em aula**:  
  - cálculo de aumento salarial;  
  - cálculo de idade a partir da data de nascimento;  
  - comparação de salário com a média do departamento;  
  - verificação de condições para aposentadoria.  

---

## 📂 Organização  
Cada aula possui um arquivo `.sql` com os códigos da prática em sala, organizados por data.  
