-------------------------------------
-------- UPDATE SELF TABLES --------
-------------------------------------

CREATE OR REPLACE FUNCTION demo.complete_presmed()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
  DIVISOR float;
  USAPESO boolean;
  PESO float;
BEGIN

  IF pg_trigger_depth() = 1 then

    -- Medicamentos com Frequência
    IF NEW.frequenciadia IS NULL AND NEW.fkfrequencia IS NOT NULL THEN
    	    NEW.frequenciadia := (
    	        SELECT f.frequenciadia FROM demo.frequencia f
    	        WHERE f.fkfrequencia = NEW.fkfrequencia
    	    );
    END IF;

    -- Soluções com Etapa
    IF NEW.frequenciadia IS NULL THEN NEW.frequenciadia := NEW.sletapas; END IF;

    -- Medicamentos com Horário
    IF NEW.frequenciadia IS NULL AND NEW.horario IS NOT NULL AND NEW.origem = 'Medicamentos' THEN
          NEW.frequenciadia := ( SELECT array_length(string_to_array(trim(NEW.horario), ' '), 1) );
          IF NEW.horario = 'ACM' THEN NEW.frequenciadia := 44; END IF;
          IF NEW.horario = 'SN' THEN NEW.frequenciadia := 33; END IF;
    END IF;

    -- Soluções com Horário
    IF NEW.frequenciadia IS NULL AND NEW.horario IS NOT NULL AND NEW.origem = 'Soluções' THEN
          NEW.frequenciadia := ( SELECT array_length(string_to_array(trim(NEW.horario), 'das'), 1)-1 );
    END IF;

    -- Soluções ACM
    IF NEW.frequenciadia IS NULL AND NEW.slacm = 'S' AND NEW.origem = 'Soluções' THEN
          NEW.frequenciadia := 44;
    END IF;

    -- Medicamento sem Frequência
    IF NEW.frequenciadia IS NULL THEN
          NEW.frequenciadia := 99;
    END IF;

    NEW.idsegmento := (
        SELECT p.idsegmento FROM demo.prescricao p
        WHERE p.fkprescricao = NEW.fkprescricao
    );

    NEW.doseconv := ( SELECT COALESCE (
		(SELECT (NEW.dose * u.fator) as doseconv
		FROM demo.unidadeconverte u
		WHERE u.idsegmento = NEW.idsegmento
		AND u.fkmedicamento = NEW.fkmedicamento 
		AND u.fkunidademedida = NEW.fkunidademedida )
    , NEW.dose ) );


    -- Medicamento com Faixa de Valores para Outliers
    DIVISOR := (SELECT a.divisor FROM demo.medatributos a
                WHERE a.fkmedicamento = NEW.fkmedicamento 
                  AND a.idsegmento = NEW.idsegmento
                  AND a.divisor IS NOT NULL);

    IF DIVISOR IS NOT NULL THEN

      PESO := 1;

      USAPESO := (SELECT a.usapeso FROM demo.medatributos a
                  WHERE a.fkmedicamento = NEW.fkmedicamento 
                    AND a.idsegmento = NEW.idsegmento
                    AND a.divisor IS NOT NULL);

      IF USAPESO IS TRUE THEN

        PESO := ( SELECT COALESCE (
          ( SELECT pe.peso FROM demo.pessoa pe
          INNER JOIN demo.prescricao pr ON pr.nratendimento = pe.nratendimento
          WHERE pr.fkprescricao = NEW.fkprescricao AND pe.peso > 0 )
          , 1 ) );

      END IF;

      IF PESO > 0 AND DIVISOR > 0 THEN
        NEW.doseconv := (SELECT CEIL(((NEW.doseconv/PESO)/DIVISOR)::numeric) * DIVISOR);
      END IF;

    END IF;


    -- Define Outliers para os Medicamentos

    NEW.idoutlier := (
        SELECT MAX(o.idoutlier) FROM demo.outlier o 
        WHERE o.fkmedicamento = NEW.fkmedicamento
        AND o.doseconv = NEW.doseconv
        AND o.frequenciadia = NEW.frequenciadia
        AND o.idsegmento = NEW.idsegmento
    );

    IF NEW.idoutlier IS NULL AND NEW.doseconv > 0 THEN
        NEW.idoutlier := (SELECT demo.similaridade(
    		NEW.idsegmento,
    		NEW.fkmedicamento,
    		NEW.doseconv, 
    		NEW.frequenciadia));
        IF NEW.idoutlier IS not NULL then
          NEW.aprox := true;
        END IF;
    END IF;

    NEW.checado := (
        SELECT true FROM demo.presmed p2
        INNER JOIN demo.prescricao pr1 ON pr1.fkprescricao = NEW.fkprescricao
        INNER JOIN demo.prescricao pr2 ON pr2.fkprescricao < NEW.fkprescricao
          AND pr2.nratendimento = pr1.nratendimento
          AND pr2.fkprescricao = p2.fkprescricao 
        WHERE p2.fkmedicamento = NEW.fkmedicamento
        AND p2.doseconv = NEW.doseconv
        AND p2.frequenciadia = NEW.frequenciadia
        AND p2.idsegmento = NEW.idsegmento
        AND pr2.status = 's'
        LIMIT 1
    );

    NEW.periodo := (
        SELECT count(distinct(pr2.dtprescricao::date)) FROM demo.presmed p2
        INNER JOIN demo.prescricao pr1 ON pr1.fkprescricao = NEW.fkprescricao
        INNER JOIN demo.prescricao pr2 ON pr2.fkprescricao < NEW.fkprescricao
          AND pr2.nratendimento = pr1.nratendimento
          AND pr2.fkprescricao = p2.fkprescricao 
        WHERE p2.fkmedicamento = NEW.fkmedicamento
        AND pr2.dtprescricao > current_date - interval '30' day
    );

   INSERT INTO demo.presmed (fkprescricao, fkpresmed, fkfrequencia, fkmedicamento, 
	   fkunidademedida, dose, frequenciadia, via, quantidade, idsegmento, doseconv, idoutlier,
	   origem, dtsuspensao, horario, complemento, padronizado, aprox, checado, periodo,
	   slagrupamento, slacm, sletapas, slhorafase, sltempoaplicacao, sldosagem, sltipodosagem, alergia)
  
   VALUES (NEW.fkprescricao, NEW.fkpresmed, NEW.fkfrequencia, NEW.fkmedicamento, 
	   NEW.fkunidademedida, NEW.dose, NEW.frequenciadia, NEW.via, NEW.quantidade, NEW.idsegmento, NEW.doseconv, NEW.idoutlier,
	   NEW.origem, NEW.dtsuspensao, NEW.horario, NEW.complemento, NEW.padronizado, NEW.aprox, NEW.checado, NEW.periodo,
	   NEW.slagrupamento, NEW.slacm, NEW.sletapas, NEW.slhorafase, NEW.sltempoaplicacao, NEW.sldosagem, NEW.sltipodosagem, NEW.alergia)
       ON CONFLICT (fkpresmed) 
         DO UPDATE SET dtsuspensao = NEW.dtsuspensao,
         frequenciadia = NEW.frequenciadia,
         periodo = NEW.periodo,
         checado = NEW.checado,
         idoutlier = NEW.idoutlier,
         doseconv = NEW.doseconv;
      
    RETURN NULL;
 ELSE
    RETURN NEW;
 END IF; 

END;$BODY$;

ALTER FUNCTION demo.complete_presmed()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_presmed ON demo.presmed;
		     
CREATE TRIGGER trg_complete_presmed
    BEFORE INSERT 
    ON demo.presmed
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_presmed();

--------

CREATE OR REPLACE  FUNCTION demo.complete_prescricao()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
   IF pg_trigger_depth() = 1 then
		NEW.idsegmento = (
		    SELECT s.idsegmento FROM demo.segmentosetor s
		    WHERE s.fksetor = NEW.fksetor
		    AND s.fkhospital = NEW.fkhospital
		);
	
	  IF NEW.peso IS NULL THEN
	      INSERT INTO demo.prescricao (fkprescricao, fkpessoa, nratendimento, fksetor, dtprescricao, idsegmento, leito, prontuario) 
				VALUES (NEW.fkprescricao, NEW.fkpessoa, NEW.nratendimento, NEW.fksetor, NEW.dtprescricao, NEW.idsegmento, NEW.leito, NEW.prontuario)
	         ON CONFLICT (fkprescricao)
	         DO UPDATE SET fkpessoa = NEW.fkpessoa,
						fksetor = NEW.fksetor,
						dtprescricao = NEW.dtprescricao,
						idsegmento = NEW.idsegmento;
	  ELSE
	      INSERT INTO demo.prescricao (fkprescricao, fkpessoa, nratendimento, fksetor, dtprescricao, idsegmento, peso, leito, prontuario) 
				VALUES (NEW.fkprescricao, NEW.fkpessoa, NEW.nratendimento, NEW.fksetor, NEW.dtprescricao, NEW.idsegmento, NEW.peso, NEW.leito, NEW.prontuario)
	         ON CONFLICT (fkprescricao)
	         DO UPDATE SET fkpessoa = NEW.fkpessoa,
						fksetor = NEW.fksetor,
						dtprescricao = NEW.dtprescricao,
						idsegmento = NEW.idsegmento;
		END IF; 
      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;  
END;$BODY$;

ALTER FUNCTION demo.complete_prescricao()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_prescricao ON demo.prescricao;
		     
CREATE TRIGGER trg_complete_prescricao
    BEFORE INSERT 
    ON demo.prescricao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_prescricao();

--------

CREATE OR REPLACE  FUNCTION demo.atualiza_escore_presemed()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
    IF NEW.status = 's' THEN
        UPDATE demo.presmed pm
        SET escorefinal = (SELECT COALESCE(escoremanual, escore) 
                                FROM demo.outlier o
                                WHERE o.idoutlier = pm.idoutlier)
        WHERE pm.fkprescricao = NEW.fkprescricao;
    END IF;
    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.atualiza_escore_presemed()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_atualiza_escore_presemed ON demo.prescricao;
		     
CREATE TRIGGER trg_atualiza_escore_presemed
    AFTER UPDATE
    ON demo.prescricao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.atualiza_escore_presemed();

--------

CREATE OR REPLACE FUNCTION demo.complete_prescricaoagg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

    IF NEW.frequenciadia IS NULL AND NEW.fkfrequencia IS NOT NULL THEN
            NEW.frequenciadia := (
                SELECT f.frequenciadia FROM demo.frequencia f
                WHERE f.fkfrequencia = NEW.fkfrequencia
            );
    END IF;
   
   IF NEW.peso IS NULL THEN
   		NEW.peso = 999;
   END IF;

    NEW.idsegmento = (
        SELECT s.idsegmento FROM demo.segmentosetor s
        WHERE s.fksetor = NEW.fksetor
        AND s.fkhospital = NEW.fkhospital
    );

    NEW.doseconv = ( SELECT COALESCE (
		(SELECT (NEW.dose * u.fator) as doseconv
		FROM demo.unidadeconverte u
		WHERE u.idsegmento = NEW.idsegmento 
		AND u.fkmedicamento = NEW.fkmedicamento 
		AND u.fkunidademedida = NEW.fkunidademedida )
    , NEW.dose ) );
   
   IF pg_trigger_depth() = 1 then

        INSERT INTO demo.prescricaoagg
            (fkhospital, fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, frequenciadia, peso, contagem, doseconv)
            VALUES(1, NEW.fksetor, NEW.fkmedicamento, NEW.fkunidademedida, NEW.fkfrequencia, NEW.dose, NEW.frequenciadia, NEW.peso, NEW.contagem, NEW.doseconv)
        ON CONFLICT (fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, frequenciadia, peso)
         DO UPDATE SET contagem = NEW.contagem, doseconv = NEW.doseconv, idsegmento = NEW.idsegmento, frequenciadia = NEW.frequenciadia;

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   

END;$BODY$;

ALTER FUNCTION demo.complete_prescricaoagg()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_prescricaoagg ON demo.prescricaoagg;

CREATE TRIGGER trg_complete_prescricaoagg
    BEFORE INSERT 
    ON demo.prescricaoagg
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_prescricaoagg();

--------

CREATE OR REPLACE FUNCTION demo.complete_frequencia()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

    IF NEW.frequenciadia IS NULL AND NEW.frequenciahora IS NOT NULL THEN
            NEW.frequenciadia := 24 / NEW.frequenciahora;
    END IF;

   IF pg_trigger_depth() = 1 then
      INSERT INTO demo.frequencia (fkhospital, fkfrequencia, nome, frequenciadia, frequenciahora) 
            VALUES(1, NEW.fkfrequencia, NEW.nome, NEW.frequenciadia, NEW.frequenciahora)
         ON CONFLICT (fkfrequencia)
         DO UPDATE SET nome = NEW.nome,
            frequenciadia = NEW.frequenciadia, 
            frequenciahora = NEW.frequenciahora;
      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   

END;$BODY$;

ALTER FUNCTION demo.complete_frequencia()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_frequencia ON demo.frequencia;
		     
CREATE TRIGGER trg_complete_frequencia
    BEFORE INSERT 
    ON demo.frequencia
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_frequencia();

-------------------------------------
-------- UPDATE CHILD TABLES --------
-------------------------------------

CREATE OR REPLACE FUNCTION demo.popula_presmed_by_outlier()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
    UPDATE demo.presmed pm
        SET idoutlier = NEW.idoutlier
        WHERE pm.fkmedicamento = NEW.fkmedicamento
            AND pm.doseconv = NEW.doseconv
            AND pm.frequenciadia = NEW.frequenciadia
            AND pm.idsegmento = NEW.idsegmento
            AND pm.fkprescricao IN (
              SELECT fkprescricao
              FROM demo.prescricao
              WHERE dtprescricao > current_date - 2 AND idsegmento = NEW.idsegmento
            );
    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.popula_presmed_by_outlier()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_popula_presmed_by_outlier ON demo.outlier;
		     
CREATE TRIGGER trg_popula_presmed_by_outlier
    AFTER INSERT
    ON demo.outlier
    FOR EACH ROW
    EXECUTE PROCEDURE demo.popula_presmed_by_outlier();

--------

CREATE OR REPLACE FUNCTION demo.popula_presmed_by_frequencia()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
    UPDATE demo.presmed pm
        SET frequenciadia = NEW.frequenciadia
    WHERE pm.fkfrequencia = NEW.fkfrequencia
    AND pm.escorefinal IS NULL;
    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.popula_presmed_by_frequencia()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_popula_presmed_by_frequencia ON demo.frequencia;
		     
CREATE TRIGGER trg_popula_presmed_by_frequencia
    AFTER INSERT 
    ON demo.frequencia
    FOR EACH ROW
    EXECUTE PROCEDURE demo.popula_presmed_by_frequencia();

--------

CREATE OR REPLACE FUNCTION demo.propaga_idsegmento()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
   
    UPDATE demo.prescricao p
        SET idsegmento = NEW.idsegmento
        WHERE p.fksetor = NEW.fksetor
        AND p.fkhospital = NEW.fkhospital
        AND (p.status IS null or p.status = '0')
        AND p.dtprescricao > current_date - 2;
       
    UPDATE demo.presmed pm
        SET idsegmento = NEW.idsegmento
        WHERE pm.fkprescricao in (
            SELECT p.fkprescricao FROM demo.prescricao p
            WHERE p.idsegmento = NEW.idsegmento
            AND p.dtprescricao > current_date - 2
            )   
        AND pm.escorefinal IS NULL;

    UPDATE demo.prescricaoagg pa
        SET idsegmento = NEW.idsegmento
            WHERE pa.fksetor = NEW.fksetor
            AND pa.fkhospital = NEW.fkhospital;

    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.propaga_idsegmento()
    OWNER TO postgres;
		     
DROP TRIGGER IF EXISTS trg_propaga_idsegmento ON demo.segmentosetor;

CREATE TRIGGER trg_propaga_idsegmento
    AFTER INSERT
    ON demo.segmentosetor
    FOR EACH ROW
    EXECUTE PROCEDURE demo.propaga_idsegmento();

    --------

CREATE OR REPLACE FUNCTION demo.deleta_idsegmento()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

    UPDATE demo.presmed pm
        SET idsegmento = NULL
        WHERE pm.fkprescricao in (
            SELECT p.fkprescricao FROM demo.prescricao p
            WHERE p.fksetor = NEW.fksetor
            AND p.fkhospital = NEW.fkhospital
            AND p.dtprescricao > current_date - 2
            )   
        AND pm.escorefinal IS NULL;
   
    UPDATE demo.prescricao p
        SET idsegmento = NULL
        WHERE p.fksetor = NEW.fksetor
        AND p.fkhospital = NEW.fkhospital
        AND p.dtprescricao > current_date - 2
        AND (p.status IS null or p.status = '0');
       
    UPDATE demo.prescricaoagg pa
        SET idsegmento = NULL
            WHERE pa.fksetor = NEW.fksetor
            AND pa.fkhospital = NEW.fkhospital;

    RETURN OLD;
END;$BODY$;

ALTER FUNCTION demo.deleta_idsegmento()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_deleta_idsegmento ON demo.segmentosetor;
		     
CREATE TRIGGER trg_deleta_idsegmento
    BEFORE DELETE
    ON demo.segmentosetor
    FOR EACH ROW
    EXECUTE PROCEDURE demo.deleta_idsegmento();

-------------------------------------------------------
-------- HANDLE INSERT ON CONFLICT (from Nifi) --------
-------------------------------------------------------

CREATE OR REPLACE  FUNCTION demo.insert_update_setor()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
   IF pg_trigger_depth() = 1 then
      INSERT INTO demo.setor (fkhospital, fksetor, nome) 
            VALUES(1, NEW.fksetor, NEW.nome)
         ON CONFLICT (fksetor)
         DO UPDATE SET nome = NEW.nome;
      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   
END;$BODY$;

ALTER FUNCTION demo.insert_update_setor()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_insert_update_setor ON demo.setor;
		     
CREATE TRIGGER trg_insert_update_setor
    BEFORE INSERT 
    ON demo.setor
    FOR EACH ROW
    EXECUTE PROCEDURE demo.insert_update_setor();

-----------------

CREATE OR REPLACE  FUNCTION demo.insert_update_medicamento()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
   IF pg_trigger_depth() = 1 then

        INSERT INTO demo.medicamento (fkhospital, fkmedicamento, nome)
            VALUES(1, NEW.fkmedicamento, NEW.nome)
         ON CONFLICT (fkmedicamento)
         DO UPDATE SET nome = NEW.nome;

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   
END;$BODY$;

ALTER FUNCTION demo.insert_update_medicamento()
    OWNER TO postgres;
		     
DROP TRIGGER IF EXISTS trg_insert_update_medicamento ON demo.medicamento;

CREATE TRIGGER trg_insert_update_medicamento
    BEFORE INSERT 
    ON demo.medicamento
    FOR EACH ROW
    EXECUTE PROCEDURE demo.insert_update_medicamento();

-----------------

CREATE OR REPLACE  FUNCTION demo.insert_update_hospital()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
   IF pg_trigger_depth() = 1 then

        INSERT INTO demo.hospital (fkhospital, nome)
            VALUES(NEW.fkhospital, NEW.nome)
         ON CONFLICT (fkhospital)
         DO UPDATE SET nome = NEW.nome;

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   
END;$BODY$;

ALTER FUNCTION demo.insert_update_hospital()
    OWNER TO postgres;
		     
DROP TRIGGER IF EXISTS insert_update_hospital ON demo.hospital;

CREATE TRIGGER insert_update_hospital
    BEFORE INSERT 
    ON demo.hospital
    FOR EACH ROW
    EXECUTE PROCEDURE demo.insert_update_hospital();

-----------------

CREATE OR REPLACE  FUNCTION demo.insert_update_unidademedida()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
   IF pg_trigger_depth() = 1 then

      INSERT INTO demo.unidademedida (fkhospital, fkunidademedida, nome) 
            VALUES(1, NEW.fkunidademedida, NEW.nome)
         ON CONFLICT (fkunidademedida)
         DO UPDATE SET nome = NEW.nome;

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   
END;$BODY$;

ALTER FUNCTION demo.insert_update_unidademedida()
    OWNER TO postgres;
		     
DROP TRIGGER IF EXISTS insert_update_hospital ON demo.unidademedida;

CREATE TRIGGER insert_update_unidademedida
    BEFORE INSERT 
    ON demo.unidademedida
    FOR EACH ROW
    EXECUTE PROCEDURE demo.insert_update_unidademedida();

-----------------

CREATE OR REPLACE  FUNCTION demo.atualiza_doseconv()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

   UPDATE demo.presmed pm
     SET doseconv = COALESCE (pm.dose * NEW.fator, pm.dose)
     WHERE pm.idsegmento = NEW.idsegmento
     AND pm.fkmedicamento = NEW.fkmedicamento
     AND pm.fkunidademedida = NEW.fkunidademedida
     AND pm.fkprescricao IN (
          SELECT fkprescricao
          FROM demo.prescricao
          WHERE dtprescricao > current_date - 2
          );

   UPDATE demo.prescricaoagg pa
     SET doseconv = COALESCE (pa.dose * NEW.fator, pa.dose)
     WHERE pa.idsegmento = NEW.idsegmento
     AND pa.fkmedicamento = NEW.fkmedicamento
     AND pa.fkunidademedida = NEW.fkunidademedida;

    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.atualiza_doseconv()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_atualiza_doseconv_on_insert ON demo.unidadeconverte;
		     
CREATE TRIGGER trg_atualiza_doseconv_on_insert
    AFTER INSERT
    ON demo.unidadeconverte
    FOR EACH ROW
    EXECUTE PROCEDURE demo.atualiza_doseconv();
		     
DROP TRIGGER IF EXISTS trg_atualiza_doseconv_on_update ON demo.unidadeconverte;

CREATE TRIGGER trg_atualiza_doseconv_on_update
    AFTER UPDATE
    ON demo.unidadeconverte
    FOR EACH ROW
    EXECUTE PROCEDURE demo.atualiza_doseconv();

-----------------

CREATE OR REPLACE  FUNCTION demo.atualiza_divisor()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

    IF NEW.divisor IS NOT NULL THEN    

      UPDATE demo.prescricaoagg pa
        SET doseconv = ( SELECT COALESCE (
          ( SELECT (pa.dose * un.fator) as doseconv
            FROM demo.unidadeconverte un
            WHERE un.fkmedicamento = pa.fkmedicamento
            AND un.fkunidademedida = pa.fkunidademedida
            AND un.idsegmento = NEW.idsegmento) 
          , pa.dose) )
        WHERE pa.fkmedicamento = NEW.fkmedicamento
        AND pa.idsegmento = NEW.idsegmento;

      IF NEW.usapeso = true THEN 

        UPDATE demo.prescricaoagg pa
          SET doseconv = COALESCE ( CEIL((((pa.doseconv+0.1)/pa.peso)/NEW.divisor)::numeric) * NEW.divisor, pa.doseconv)
          WHERE pa.fkmedicamento = NEW.fkmedicamento
          AND pa.idsegmento = NEW.idsegmento
          AND pa.peso != 999 and pa.peso >= 0.5
          AND doseconv is not null;

        UPDATE demo.prescricaoagg pa
          SET doseconv = NULL
          WHERE pa.fkmedicamento = NEW.fkmedicamento
          AND pa.idsegmento = NEW.idsegmento
          AND (pa.peso = 999 or pa.peso < 0.5 or pa.peso IS NULL);

      ELSE

        UPDATE demo.prescricaoagg pa
          SET doseconv = COALESCE ( CEIL(((pa.doseconv+0.1)/NEW.divisor)::numeric) * NEW.divisor, pa.doseconv)
          WHERE pa.fkmedicamento = NEW.fkmedicamento
          AND pa.idsegmento = NEW.idsegmento
          AND doseconv is not null;

      END IF;

    END IF;

    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.atualiza_divisor()
    OWNER TO postgres;
    
DROP TRIGGER IF EXISTS trg_atualiza_divisor_on_insert ON demo.medatributos;

CREATE TRIGGER trg_atualiza_divisor_on_insert
    AFTER INSERT
    ON demo.medatributos
    FOR EACH ROW
    EXECUTE PROCEDURE demo.atualiza_divisor();
    
DROP TRIGGER IF EXISTS trg_atualiza_divisor_on_update ON demo.medatributos;

CREATE TRIGGER trg_atualiza_divisor_on_update
    AFTER UPDATE
    ON demo.medatributos
    FOR EACH ROW
    WHEN (OLD.divisor IS DISTINCT FROM NEW.divisor) 
    EXECUTE PROCEDURE demo.atualiza_divisor();

-----------------

CREATE OR REPLACE FUNCTION demo.similaridade (p_idsegmento int2, p_fkmedicamento int8, p_doseconv float4, p_frequenciadia float4)
    RETURNS int4
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE r_idoutlier int4 default null;
BEGIN

	SELECT (idoutlier) INTO r_idoutlier
	from 
	(	
		SELECT o.idoutlier,
			1 - ( (o.doseconv * p_doseconv + o.frequenciadia * p_frequenciadia) / (sqrt( power(o.doseconv,2) + power(o.frequenciadia,2) ) *
			sqrt( power(p_doseconv,2) + power(p_frequenciadia,2)) ) ) as cosine,
			sqrt(power(o.doseconv - p_doseconv,2) + power(o.frequenciadia - p_frequenciadia,2)) as euclidian
		FROM demo.outlier o
		WHERE o.idsegmento = p_idsegmento
		and o.fkmedicamento = p_fkmedicamento
    and o.doseconv > 0 and o.frequenciadia > 0
	) as t
	ORDER BY cosine asc, euclidian asc
	LIMIT 1;
	
    RETURN r_idoutlier;
END;$BODY$;

ALTER FUNCTION demo.similaridade(int2, int8, float4, float4)
    OWNER TO postgres;
