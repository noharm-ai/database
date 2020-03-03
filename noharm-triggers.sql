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

    RETURN NEW;
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

    RETURN NEW;
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
