INSERT INTO demo_test.hospital
	SELECT *
	FROM demo.hospital;
	
INSERT INTO demo_test.setor
	SELECT *
	FROM demo.setor;

INSERT INTO demo_test.segmento
	SELECT *
	FROM demo.segmento;

INSERT INTO demo_test.segmentosetor
	SELECT *
	FROM demo.segmentosetor;
	
INSERT INTO demo_test.frequencia
	SELECT *
	FROM demo.frequencia;

INSERT INTO demo_test.unidademedida
	SELECT *
	FROM demo.unidademedida;

INSERT INTO demo_test.unidadeconverte
	SELECT *
	FROM demo.unidadeconverte;

INSERT INTO demo_test.medicamento
	SELECT *
	FROM demo.medicamento;

INSERT INTO demo_test.prescricao
	SELECT fkhospital, fksetor, fkprescricao, fkpessoa, nratendimento, idsegmento, dtprescricao + INTERVAL '1 month', status , peso, update_at, update_by
	FROM demo.prescricao
	WHERE dtprescricao > current_date - 2 and idsegmento = 1;

INSERT INTO demo_test.pessoa
	SELECT fkhospital, fkpessoa, nratendimento, dtnascimento, dtinternacao + INTERVAL '1 month', cor, sexo, peso
	FROM demo.pessoa p
	WHERE EXISTS (
		SELECT * 
		FROM demo_test.prescricao pre
		WHERE p.fkpessoa = pre.fkpessoa
		AND p.nratendimento = pre.nratendimento
	);

INSERT INTO demo_test.exame
	SELECT fkexame, fkpessoa, nratendimento, fkprescricao, dtexame + INTERVAL '1 month', tpexame, resultado, unidade
	FROM demo.exame e
	WHERE EXISTS (
		SELECT *
		FROM demo_test.pessoa p
		WHERE p.fkpessoa = e.fkpessoa
		AND p.nratendimento = e.nratendimento
	);

INSERT INTO demo_test.presmed
	SELECT *
	FROM demo.presmed p
	WHERE p.fkprescricao IN (
		SELECT fkprescricao FROM demo_test.prescricao
	);

INSERT INTO demo_test.outlier
	SELECT *
	FROM demo.outlier where idsegmento = 1;

INSERT INTO demo_test.prescricaoagg
	SELECT *
	FROM demo.prescricaoagg where idsegmento = 1;
