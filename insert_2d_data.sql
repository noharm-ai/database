INSERT INTO demo_2d.hospital
	SELECT fkhospital, nome 
	FROM demo.hospital;
	
INSERT INTO demo_2d.setor
	SELECT fkhospital, fksetor, nome 
	FROM demo.setor;

INSERT INTO demo_2d.segmento
	SELECT idsegmento, nome, idade_min, idade_max, peso_min, peso_max, status
	FROM demo.segmento;

INSERT INTO demo_2d.segmentosetor
	SELECT idsegmento, fkhospital, fksetor
	FROM demo.segmentosetor;
	
INSERT INTO demo_2d.frequencia
	SELECT fkhospital, fkfrequencia, nome, frequenciadia, frequenciahora
	FROM demo.frequencia;

INSERT INTO demo_2d.unidademedida
	SELECT fkhospital, fkunidademedida, nome
	FROM demo.unidademedida;

INSERT INTO demo_2d.unidadeconverte
	SELECT fkhospital, fkmedicamento, fkunidademedida, fator
	FROM demo.unidadeconverte;

INSERT INTO demo_2d.medicamento
	SELECT fkhospital, fkmedicamento, fkunidademedida, nome, antimicro, mav, controlados
	FROM demo.medicamento;

INSERT INTO demo_2d.prescricao
	SELECT fkhospital, fksetor, fkprescricao, fkpessoa, nratendimento, idsegmento, dtprescricao, status , update_at, update_by
	FROM demo.prescricao
	WHERE dtprescricao > current_date - 2;

INSERT INTO demo_2d.pessoa
	SELECT fkhospital, fkpessoa, nratendimento, dtnascimento, dtinternacao, cor, sexo, peso
	FROM demo.pessoa p
	WHERE EXISTS (
		SELECT * 
		FROM demo_2d.prescricao pre
		WHERE p.fkpessoa = pre.fkpessoa
		AND p.nratendimento = pre.nratendimento
	);

INSERT INTO demo_2d.exame
	SELECT fkexame, fkpessoa, nratendimento, fkprescricao, dtexame, tpexame, resultado, unidade
	FROM demo.exame e
	WHERE EXISTS (
		SELECT *
		FROM demo_2d.pessoa p
		WHERE p.fkpessoa = e.fkpessoa
		AND p.nratendimento = e.nratendimento
	);

INSERT INTO demo_2d.presmed
	SELECT distinct on(fkmedicamento, idsegmento, doseconv, frequenciadia)
	fkpresmed, fkprescricao, fkmedicamento, fkunidademedida, 
	fkfrequencia, idsegmento, idoutlier, dose, doseconv, frequenciadia, 
	via, complemento, quantidade, escorefinal, status, update_at, update_by
	FROM demo.presmed p
	WHERE p.fkprescricao IN (
		SELECT fkprescricao FROM demo_2d.prescricao
	);

INSERT INTO demo_2d.outlier
	SELECT fkmedicamento, idoutlier, idsegmento, contagem, doseconv, 
	frequenciadia, escore, escoremanual, idusuario, update_at, update_by
	FROM demo.outlier;

INSERT INTO demo_2d.prescricaoagg
	SELECT fkhospital, fksetor, idsegmento, fkmedicamento, fkunidademedida, 
	fkfrequencia, dose, doseconv, frequenciadia, idade, peso, contagem
	FROM demo.prescricaoagg;
