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

    NEW.idoutlier := (
        SELECT MAX(o.idoutlier) FROM demo.outlier o 
        WHERE o.fkmedicamento = NEW.fkmedicamento
        AND o.dose = NEW.dose
        AND o.frequenciadia = NEW.frequenciadia
        AND o.idsegmento = NEW.idsegmento
    );

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
      INSERT INTO demo.prescricao (fkprescricao, fkpessoa, fksetor, dtprescricao, idsegmento) 
			VALUES (NEW.fkprescricao, NEW.fkpessoa, NEW.fksetor, NEW.dtprescricao, NEW.idsegmento)
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
                                WHERE o.idoutlier = pm.idoutlier);
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

    NEW.idsegmento = (
        SELECT s.idsegmento FROM demo.segmentosetor s
        WHERE s.fksetor = NEW.fksetor
        AND s.fkhospital = NEW.fkhospital
    );

   IF pg_trigger_depth() = 1 then

        INSERT INTO demo.prescricaoagg
            (fkhospital, fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, frequenciadia, idade, peso, contagem)
            VALUES(1, NEW.fksetor, NEW.fkmedicamento, NEW.fkunidademedida, NEW.fkfrequencia, NEW.dose, NEW.frequenciadia, NEW.idade, NEW.peso, NEW.contagem)
        ON CONFLICT (fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, frequenciadia, idade, peso)
         DO UPDATE SET contagem = NEW.contagem;

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
      INSERT INTO hscpoa.frequencia (fkhospital, fkfrequencia, nome, frequenciadia, frequenciahora) 
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
            AND pm.dose = NEW.dose
            AND pm.frequenciadia = NEW.frequenciadia
            AND pm.idsegmento = NEW.idsegmento
            AND pm.escorefinal IS NULL;
    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.popula_presmed_by_outlier()
    OWNER TO postgres;

CREATE TRIGGER trg_popula_presmed_by_outlier
    AFTER INSERT
    ON demo.outlier
    FOR EACH ROW
    EXECUTE PROCEDURE demo.popula_presmed_by_outlier();

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