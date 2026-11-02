USE sprint3;

CREATE TABLE estudante (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(60)
);

CREATE TABLE cursos (
idCurso INT PRIMARY KEY AUTO_INCREMENT,
nomeCurso VARCHAR(60),
fkArea INT,
fkInstrutor INT, 
fkEstudante INT,

FOREIGN KEY (fkArea) REFERENCES areaconhecimento (idArea),
FOREIGN KEY (fkInstrutor) REFERENCES instrutor (idInstrutor),
FOREIGN KEY (fkEstudante) REFERENCES estudante (id)
);

CREATE TABLE instrutor (
idInstrutor INT PRIMARY KEY AUTO_INCREMENT,
nomeInstrutor VARCHAR(60)
);

CREATE TABLE atuacaoinstrutor (
idAtuacao INT PRIMARY KEY AUTO_INCREMENT,
atuacao VARCHAR(80),
fkInstrutor INT,
FOREIGN KEY (fkInstrutor) REFERENCES instrutor (idInstrutor)
);

CREATE TABLE areaconhecimento (
idArea INT PRIMARY KEY AUTO_INCREMENT, 
tipo VARCHAR(45)
);

CREATE TABLE inscricao (
idInscricao INT PRIMARY KEY AUTO_INCREMENT, 
nota DECIMAL(4,2),
frequencia INT,
estatus VARCHAR(40),
fkCurso INT, 
FOREIGN KEY (fkCurso) REFERENCES cursos (idCurso)
);

ALTER TABLE inscricao ADD CONSTRAINT chk_nota CHECK (nota BETWEEN 0 AND 10);

drop table inscricao;

CREATE TABLE especialidade (
idEspecialidade INT PRIMARY KEY AUTO_INCREMENT,
nomeEspecialidade VARCHAR(45),
fkInstrutor INT,
FOREIGN KEY (fkInstrutor) REFERENCES instrutor (idInstrutor)
);

SHOW TABLES;

ALTER TABLE inscricao 
ADD CONSTRAINT chk_nota CHECK( nota >= 0 AND nota <= 10);

ALTER TABLE inscricao 
ADD CONSTRAINT chk_frequencia CHECK( frequencia >= 0 AND frequencia <= 100);

-- INSERTS -- 

INSERT INTO areaconhecimento (idArea, tipo) VALUES 
(1, 'Tecnologia'),
(2, 'Idiomas'),
(3, 'Artes');

INSERT INTO instrutor (idInstrutor, nomeInstrutor) VALUES 
(1, 'Mariana Souza'),
(2, 'Carlos Oliveira'),
(3, 'Fernanda Lima'),
(4, 'Rafael Santos');

UPDATE instrutor 
SET remuneracao = CASE idInstrutor
    WHEN 1 THEN 3500.00
    WHEN 2 THEN 4200.00
    WHEN 3 THEN 3800.00
    WHEN 4 THEN 5000.00
END
WHERE idInstrutor IN (1, 2, 3, 4);

INSERT INTO atuacaoinstrutor (atuacao, fkInstrutor) VALUES 
('Desenvolvimento Web', 1),
('Línguas Estrangeiras', 2),
('Artes Cênicas', 3);

INSERT INTO especialidade (nomeEspecialidade, fkInstrutor) VALUES 
('Desenvolvimento Web', 1),
('Línguas Estrangeiras', 2),
('Artes Cênicas', 3);

INSERT INTO estudante (id, nome) VALUES 
(1, 'Ana Costa'),	
(2, 'Bruno Pereira'),
(3, 'Camila Rocha'),
(4, 'Diego Gomes'),
(5, 'Eduarda Alves'),
(6, 'Felipe Martins'),
(7, 'Gabriela Ribeiro'),
(8, 'Henrique Fernandes'),
(9, 'Isabela Carvalho'),
(10, 'João Mendes');

INSERT INTO cursos (idCurso, nomeCurso, fkArea, fkInstrutor, fkEstudante) VALUES 
(1, 'HTML e CSS', 1, 1, 1),
(2, 'JavaScript Básico', 1, 1, 2),
(3, 'Inglês para Iniciantes', 2, 2, 3),
(4, 'Espanhol Intermediário', 2, 2, 4),
(5, 'Dança Contemporânea', 3, 3, 5),
(6, 'Teatro Básico', 3, 3, NULL);

ALTER TABLE instrutor 
ADD COLUMN remuneracao DECIMAL(10, 2) NOT NULL DEFAULT 0.00;

INSERT INTO inscricao (nota, frequencia, estatus, fkCurso) VALUES 
(8.5, 90, 'Aprovado', 1),
(4.0, 85, 'Reprovado por Nota', 1),
(9.0, 60, 'Reprovado por Frequencia', 2),
(5.0, 50, 'Reprovado por Nota e Freq', 3),
(7.0, 80, 'Aprovado', 4),
(3.5, 40, 'Reprovado por Nota e Freq', 5);

INSERT INTO inscricao (nota, frequencia, estatus, fkCurso) VALUES 
(8.5, 75, 'Aprovado', 1),
(9.8, 80, 'Aprovado', 1);
drop table inscricao;

-- Comandos -- 

SELECT estudante.nome, cursos.nomeCurso, inscricao.nota, inscricao.frequencia
	FROM estudante
		INNER JOIN cursos 
			ON cursos.fkEstudante = estudante.id
				INNER JOIN inscricao
					ON inscricao.fkCurso = cursos.idCurso
					 INNER JOIN areaconhecimento
						ON cursos.fkArea = areaconhecimento.idArea
							WHERE areaconhecimento.tipo = 'Tecnologia'; 
                            
SELECT cursos.nomeCurso, COUNT(*) , MIN(inscricao.nota), MAX(inscricao.nota), ROUND(AVG(inscricao.nota), 1)
	FROM cursos
		INNER JOIN estudante
			ON cursos.fkEstudante = estudante.id
				INNER JOIN inscricao
					ON inscricao.fkCurso = cursos.idCurso
						GROUP BY estudante.nome, cursos.nomeCurso;
						
SELECT 
    cursos.nomeCurso
FROM
    cursos
        INNER JOIN
    estudante ON cursos.fkEstudante = estudante.id
        INNER JOIN
    inscricao ON inscricao.fkCurso = cursos.idCurso
WHERE
    inscricao.nota >= 6
        AND inscricao.frequencia >= 75
GROUP BY cursos.nomeCurso
HAVING COUNT(estudante.id) >= 3;

SELECT instrutor.nomeInstrutor, especialidade.nomeEspecialidade,
	COUNT(cursos.idCurso) AS qtd_cursos,
	SUM(instrutor.remuneracao) AS soma_remunercao
FROM instrutor
	INNER JOIN cursos
		ON cursos.fkInstrutor = instrutor.idInstrutor
			INNER JOIN especialidade
				ON especialidade.fkInstrutor = instrutor.idInstrutor
		GROUP BY instrutor.nomeInstrutor, especialidade.nomeEspecialidade;
			

SELECT 
    cursos.nomeCurso,
    SUM(CASE WHEN inscricao.estatus = 'Aprovado' THEN 1 ELSE 0 END) AS total_aprovados,
    SUM(CASE WHEN inscricao.estatus = 'Reprovado por Frequência' THEN 1 ELSE 0 END) AS total_reprovados_frequencia,
    SUM(CASE WHEN inscricao.estatus = 'Reprovado por Nota' THEN 1 ELSE 0 END) AS total_reprovados_nota
FROM cursos
    INNER JOIN inscricao 
        ON inscricao.fkCurso = cursos.idCurso
GROUP BY 
    cursos.idCurso, 
    cursos.nomeCurso;
    
-- Exibir, por área de conhecimento, a quantidade de cursos, a quantidade de estudantes 
-- distintos inscritos, a média das notas e o percentual de aprovações.-- 

SELECT areaconhecimento.tipo, 
		COUNT(cursos.idCurso),
        COUNT(estudante.id),
        ROUND(AVG(inscricao.nota),1),
       SUM(CASE WHEN inscricao.nota >= 6 AND inscricao.frequencia >= 75 THEN 1 ELSE 0 END) AS 'Aprovados'
FROM areaconhecimento
	INNER JOIN cursos
		ON cursos.fkArea = areaconhecimento.idArea
			INNER JOIN estudante
				ON cursos.fkEstudante = estudante.id
					INNER JOIN inscricao
						ON inscricao.fkCurso = cursos.idCurso	
							GROUP BY areaconhecimento.tipo;
-- Fim -- 

-- Exercicio 02

CREATE TABLE regiao (
    id_regiao INT AUTO_INCREMENT PRIMARY KEY,
    nome_regiao VARCHAR(50) NOT NULL
);

CREATE TABLE situacao (
    id_situacao INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE area_atuacao (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    nome_area VARCHAR(50) NOT NULL
);

CREATE TABLE setor (
    id_setor INT AUTO_INCREMENT PRIMARY KEY,
    nome_setor VARCHAR(50) NOT NULL
);

CREATE TABLE voluntario (
    id_voluntario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(20)
);

CREATE TABLE instituicao (
    id_instituicao INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(20) UNIQUE,
    id_setor INT
);

CREATE TABLE projeto (
    id_projeto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    orcamento_previsto DECIMAL(10, 2),
    data_inicio DATE,
    data_fim DATE,
    meta_horas INT,
    id_regiao INT,
    id_situacao INT,
    id_area INT
);

CREATE TABLE participacao (
    id_participacao INT AUTO_INCREMENT PRIMARY KEY,
    id_projeto INT NOT NULL,
    id_voluntario INT NOT NULL,
    horas_trabalhadas DECIMAL(5, 2),
    data_registro DATE
);

CREATE TABLE apoio_financeiro (
    id_apoio INT AUTO_INCREMENT PRIMARY KEY,
    id_projeto INT NOT NULL,
    id_instituicao INT NOT NULL,
    valor DECIMAL(10, 2),
    data_apoio DATE
);
							
-- Inserts 

INSERT INTO regiao (id_regiao, nome_regiao) VALUES 
(1, 'Zona Sul'),
(2, 'Zona Norte'),
(3, 'Zona Leste'),
(4, 'Zona Oeste'),
(5, 'Centro');

INSERT INTO situacao (id_situacao, descricao) VALUES 
(1, 'Ativo'),
(2, 'Concluído'),
(3, 'Suspenso'),
(4, 'Em planejamento');

INSERT INTO area_atuacao (id_area, nome_area) VALUES 
(1, 'Reflorestamento'),
(2, 'Educação Ambiental'),
(3, 'Reciclagem'),
(4, 'Recursos Hídricos'),
(5, 'Proteção Animal');

INSERT INTO setor (id_setor, nome_setor) VALUES 
(1, 'Terceiro Setor'),
(2, 'Privado'),
(3, 'Governamental'),
(4, 'Acadêmico');

INSERT INTO voluntario (id_voluntario, nome, email, telefone) VALUES 
(1, 'Ana Souza', 'ana.souza@email.com', '(11) 98111-0001'),
(2, 'Bruno Lima', 'bruno.lima@email.com', '(11) 98111-0002'),
(3, 'Carla Mendes', 'carla.mendes@email.com', '(11) 98111-0003'),
(4, 'Diego Rocha', 'diego.rocha@email.com', '(11) 98111-0004'),
(5, 'Elisa Prado', 'elisa.prado@email.com', '(11) 98111-0005'),
(6, 'Felipe Nunes', 'felipe.nunes@email.com', '(11) 98111-0006'),
(7, 'Gabriela Alves', 'gabriela.alves@email.com', '(11) 98111-0007'),
(8, 'Henrique Dias', 'henrique.dias@email.com', '(11) 98111-0008'),
(9, 'Isabela Castro', 'isabela.castro@email.com', '(11) 98111-0009'),
(10, 'João Ramos', 'joao.ramos@email.com', '(11) 98111-0010');

INSERT INTO instituicao (id_instituicao, nome, cnpj, id_setor) VALUES 
(1, 'Fundação Verde Paulista', '12.345.678/0001-01', 1),
(2, 'Instituto Mata Atlântica', '23.456.789/0001-02', 1),
(3, 'Banco Paulista S.A.', '34.567.890/0001-03', 2),
(4, 'Secretaria do Verde e Meio Ambiente', '45.678.901/0001-04', 3),
(5, 'Universidade São Paulo Tech', '56.789.012/0001-05', 4);

INSERT INTO projeto (id_projeto, nome, orcamento_previsto, data_inicio, data_fim, meta_horas, id_regiao, id_situacao, id_area) VALUES 
(1, 'Refloresta Sul', 50000.00, '2026-02-01', '2026-12-20', 120, 1, 1, 1),
(2, 'Horta Norte', 18000.00, '2026-03-10', '2026-11-30', 80, 2, 1, 2),
(3, 'Recicla Leste', 32000.00, '2026-01-15', '2026-12-15', 150, 3, 1, 3),
(4, 'Águas do Oeste', 45000.00, '2026-04-01', '2027-03-31', 100, 4, 1, 4),
(5, 'Educa Centro', 12000.00, '2025-08-01', '2026-06-30', 60, 5, 2, 2),
(6, 'Mata Ciliar Sul', 60000.00, '2026-02-20', '2027-02-19', 200, 1, 1, 1),
(7, 'Fauna Norte', 25000.00, '2026-05-05', '2026-10-05', 90, 2, 3, 5),
(8, 'Praças Leste', 15000.00, '2026-09-01', '2027-08-31', 100, 3, 4, 2);

INSERT INTO participacao (id_participacao, id_projeto, id_voluntario, horas_trabalhadas, data_registro) VALUES 
(1, 1, 1, 30.00, '2026-02-15'),
(2, 1, 2, 40.00, '2026-02-20'),
(3, 1, 6, 25.00, '2026-03-02'),
(4, 2, 3, 50.00, '2026-03-18'),
(5, 2, 8, 45.00, '2026-03-25'),
(6, 3, 3, 60.00, '2026-01-28'),
(7, 3, 7, 40.00, '2026-02-10'),
(8, 3, 8, 30.00, '2026-02-22'),
(9, 4, 4, 55.00, '2026-04-12'),
(10, 4, 8, 50.00, '2026-04-28'),
(11, 5, 1, 35.00, '2025-09-05'),
(12, 6, 2, 70.00, '2026-03-08'),
(13, 6, 6, 60.00, '2026-03-22'),
(14, 7, 5, 20.00, '2026-05-20');

INSERT INTO apoio_financeiro (id_apoio, id_projeto, id_instituicao, valor, data_apoio) VALUES 
(1, 1, 1, 20000.00, '2026-02-10'),
(2, 1, 3, 15000.00, '2026-03-05'),
(3, 3, 2, 12000.00, '2026-01-20'),
(4, 3, 4, 10000.00, '2026-02-15'),
(5, 3, 1, 8000.00, '2026-03-01'),
(6, 4, 3, 25000.00, '2026-04-10'),
(7, 5, 5, 5000.00, '2025-08-15'),
(8, 6, 1, 30000.00, '2026-03-01'),
(9, 6, 2, 20000.00, '2026-03-20');



                    



