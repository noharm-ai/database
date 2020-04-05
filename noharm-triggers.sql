-------------------------------------
-------- UPDATE SELF TABLES --------
-------------------------------------

CREATE FUNCTION demo.complete_presmed()
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

    NEW.idsegmento = (
        SELECT p.idsegmento FROM demo.prescricao p
        WHERE p.fkprescricao = NEW.fkprescricao
    );

    NEW.doseconv = ( SELECT COALESCE (
		(SELECT (NEW.dose * u.fator) as doseconv
		FROM demo.unidadeconverte u
		WHERE u.fkhospital = 1 
		AND u.fkmedicamento = NEW.fkmedicamento 
		AND u.fkunidademedida = NEW.fkunidademedida )
    , NEW.dose ) );

    NEW.idoutlier := (
        SELECT MAX(o.idoutlier) FROM demo.outlier o 
        WHERE o.fkmedicamento = NEW.fkmedicamento
        AND o.doseconv = NEW.doseconv
        AND o.frequenciadia = NEW.frequenciadia
        AND o.idsegmento = NEW.idsegmento
    );

    IF NEW.idoutlier IS NULL THEN
        NEW.idoutlier := (SELECT demo.similaridade(
		NEW.idsegmento,
		NEW.fkmedicamento,
		NEW.doseconv, 
		NEW.frequenciadia));
    END IF;

    RETURN NEW;
END;$BODY$;

ALTER FUNCTION demo.complete_presmed()
    OWNER TO postgres;

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
      INSERT INTO demo.prescricao (fkprescricao, fkpessoa, nratendimento, fksetor, dtprescricao, idsegmento) 
			VALUES (NEW.fkprescricao, NEW.fkpessoa, NEW.nratendimento, NEW.fksetor, NEW.dtprescricao, NEW.idsegmento)
         ON CONFLICT (fkprescricao)
         DO UPDATE SET fkpessoa = NEW.fkpessoa,
					fksetor = NEW.fksetor,
					dtprescricao = NEW.dtprescricao,
					idsegmento = NEW.idsegmento;
      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   
END;$BODY$;

ALTER FUNCTION demo.complete_prescricao()
    OWNER TO postgres;

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
    IF NEW.status = 'S' THEN
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

CREATE TRIGGER trg_atualiza_escore_presemed
    AFTER UPDATE
    ON demo.prescricao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.atualiza_escore_presemed();

--------

CREATE FUNCTION demo.complete_prescricaoagg()
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
		WHERE u.fkhospital = NEW.fkhospital 
		AND u.fkmedicamento = NEW.fkmedicamento 
		AND u.fkunidademedida = NEW.fkunidademedida )
    , NEW.dose ) );
   
   IF pg_trigger_depth() = 1 then

        INSERT INTO demo.prescricaoagg
            (fkhospital, fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, frequenciadia, idade, peso, contagem, doseconv)
            VALUES(1, NEW.fksetor, NEW.fkmedicamento, NEW.fkunidademedida, NEW.fkfrequencia, NEW.dose, NEW.frequenciadia, NEW.idade, NEW.peso, NEW.contagem, NEW.doseconv)
        ON CONFLICT (fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, frequenciadia, idade, peso)
         DO UPDATE SET contagem = NEW.contagem, doseconv = NEW.doseconv, idsegmento = NEW.idsegmento, frequenciadia = NEW.frequenciadia;

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   

END;$BODY$;

ALTER FUNCTION demo.complete_prescricaoagg()
    OWNER TO postgres;

CREATE TRIGGER trg_complete_prescricaoagg
    BEFORE INSERT 
    ON demo.prescricaoagg
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_prescricaoagg();

--------

CREATE FUNCTION demo.complete_frequencia()
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

CREATE TRIGGER trg_complete_frequencia
    BEFORE INSERT 
    ON demo.frequencia
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_frequencia();

-------------------------------------
-------- UPDATE CHILD TABLES --------
-------------------------------------

CREATE FUNCTION demo.popula_presmed_by_outlier()
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
            AND pm.escorefinal IS NULL;
    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.popula_presmed_by_outlier()
    OWNER TO postgres;

--CREATE TRIGGER trg_popula_presmed_by_outlier
--    AFTER INSERT
--    ON demo.outlier
--    FOR EACH ROW
--    EXECUTE PROCEDURE demo.popula_presmed_by_outlier();

--------

CREATE FUNCTION demo.popula_presmed_by_frequencia()
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

CREATE TRIGGER trg_popula_presmed_by_frequencia
    AFTER INSERT 
    ON demo.frequencia
    FOR EACH ROW
    EXECUTE PROCEDURE demo.popula_presmed_by_frequencia();

--------

CREATE FUNCTION demo.propaga_idsegmento()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

    UPDATE demo.presmed pm
        SET idsegmento = NEW.idsegmento
        WHERE pm.fkprescricao in (
            SELECT p.fkprescricao FROM demo.prescricao p
            WHERE p.fksetor = NEW.fksetor
            AND p.fkhospital = NEW.fkhospital
            )   
        AND pm.escorefinal IS NULL;
   
    UPDATE demo.prescricao p
        SET idsegmento = NEW.idsegmento
        WHERE p.fksetor = NEW.fksetor
        AND p.fkhospital = NEW.fkhospital
        AND (p.status IS null or p.status = '0');
       
    UPDATE demo.prescricaoagg pa
        SET idsegmento = NEW.idsegmento
            WHERE pa.fksetor = NEW.fksetor
            AND pa.fkhospital = NEW.fkhospital;

    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.propaga_idsegmento()
    OWNER TO postgres;

CREATE TRIGGER trg_propaga_idsegmento
    AFTER INSERT
    ON demo.segmentosetor
    FOR EACH ROW
    EXECUTE PROCEDURE demo.propaga_idsegmento();

    --------

CREATE FUNCTION demo.deleta_idsegmento()
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
            )   
        AND pm.escorefinal IS NULL;
   
    UPDATE demo.prescricao p
        SET idsegmento = NULL
        WHERE p.fksetor = NEW.fksetor
        AND p.fkhospital = NEW.fkhospital
        AND (p.status IS null or p.status = '0');
       
    UPDATE demo.prescricaoagg pa
        SET idsegmento = NULL
            WHERE pa.fksetor = NEW.fksetor
            AND pa.fkhospital = NEW.fkhospital;

    RETURN OLD;
END;$BODY$;

ALTER FUNCTION demo.deleta_idsegmento()
    OWNER TO postgres;

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

        INSERT INTO demo.medicamento (fkhospital, fkmedicamento, fkunidademedida, nome)
            VALUES(1, NEW.fkmedicamento, NEW.fkunidademedida, NEW.nome)
         ON CONFLICT (fkmedicamento)
         DO UPDATE SET nome = NEW.nome,
            fkunidademedida = NEW.fkunidademedida;

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   
END;$BODY$;

ALTER FUNCTION demo.insert_update_medicamento()
    OWNER TO postgres;

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

CREATE TRIGGER insert_update_hospital
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
     WHERE 1 = NEW.fkhospital
     AND pm.fkmedicamento = NEW.fkmedicamento
     AND pm.fkunidademedida = NEW.fkunidademedida;

   UPDATE demo.prescricaoagg pa
     SET doseconv = COALESCE (pa.dose * NEW.fator, pa.dose)
     WHERE pa.fkhospital = NEW.fkhospital
     AND pa.fkmedicamento = NEW.fkmedicamento
     AND pa.fkunidademedida = NEW.fkunidademedida;

    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.atualiza_doseconv()
    OWNER TO postgres;

CREATE TRIGGER trg_atualiza_doseconv_on_insert
    AFTER INSERT
    ON demo.unidadeconverte
    FOR EACH ROW
    EXECUTE PROCEDURE demo.atualiza_doseconv();

CREATE TRIGGER trg_atualiza_doseconv_on_update
    AFTER UPDATE
    ON demo.unidadeconverte
    FOR EACH ROW
    WHEN (OLD.fator IS DISTINCT FROM NEW.fator) 
    EXECUTE PROCEDURE demo.atualiza_doseconv();

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
	) as t
	ORDER BY cosine asc, euclidian asc
	LIMIT 1;
	
    RETURN r_idoutlier;
END;$BODY$;

ALTER FUNCTION demo.similaridade(int2, int8, float4, float4)
    OWNER TO postgres;
