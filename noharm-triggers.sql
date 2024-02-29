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
  PRESMED_RESULTADO public.PRESMED_RESULTADO_TYPE;
	PRESMED_PARAMETRO public.PARAMETRO_TYPE;
BEGIN

  IF pg_trigger_depth() = 1 then
  
    -- DEFINIR PARAMETROS
		PRESMED_PARAMETRO.nome_schema = 'demo';
		PRESMED_PARAMETRO.features = ARRAY[]::text[];
    --PRESMED_PARAMETRO.features = ARRAY['CPOE']::text[];
		PRESMED_PARAMETRO.skip_list = ARRAY[]::text[];
  
		-- FUNCAO CENTRAL
		PRESMED_RESULTADO := public.complete_presmed(PRESMED_PARAMETRO.*, new.*);
	  
		-- USAR VALORES CALCULADOS
		new.origem := PRESMED_RESULTADO.origem;
		new.idsegmento := PRESMED_RESULTADO.idsegmento;
	
		new.idoutlier := PRESMED_RESULTADO.idoutlier;
		new.aprox := PRESMED_RESULTADO.aprox;
		new.escorefinal := PRESMED_RESULTADO.escorefinal;
		
		new.sonda := PRESMED_RESULTADO.sonda;
		new.intravenosa := PRESMED_RESULTADO.intravenosa;
		
		new.checado := PRESMED_RESULTADO.checado;
		new.periodo := PRESMED_RESULTADO.periodo;
		new.frequenciadia := PRESMED_RESULTADO.frequenciadia;
		new.doseconv := PRESMED_RESULTADO.doseconv;
		
		new.cpoe_grupo := PRESMED_RESULTADO.cpoe_grupo;

    INSERT INTO demo.presmed (
      fkprescricao, fkpresmed, fkfrequencia, fkmedicamento, 
      fkunidademedida, dose, frequenciadia, via, idsegmento, doseconv, idoutlier, escorefinal,
      origem, dtsuspensao, horario, complemento, aprox, checado, periodo,
      slagrupamento, slacm, sletapas, slhorafase, sltempoaplicacao, sldosagem, sltipodosagem, 
      alergia, sonda, intravenosa, cpoe_grupo, cpoe_nrseq, cpoe_nrseq_anterior
    )
    VALUES (
      NEW.fkprescricao, NEW.fkpresmed, NEW.fkfrequencia, NEW.fkmedicamento, 
      NEW.fkunidademedida, NEW.dose, NEW.frequenciadia, NEW.via, NEW.idsegmento, NEW.doseconv, NEW.idoutlier, NEW.escorefinal,
      NEW.origem, NEW.dtsuspensao, NEW.horario, NEW.complemento, NEW.aprox, NEW.checado, NEW.periodo,
      NEW.slagrupamento, NEW.slacm, NEW.sletapas, NEW.slhorafase, NEW.sltempoaplicacao, NEW.sldosagem, 
      NEW.sltipodosagem, NEW.alergia, NEW.sonda, NEW.intravenosa, NEW.cpoe_grupo, NEW.cpoe_nrseq, NEW.cpoe_nrseq_anterior
    )
    ON CONFLICT (fkpresmed) 
    DO UPDATE SET 
      dtsuspensao = NEW.dtsuspensao,
      frequenciadia = NEW.frequenciadia,
      periodo = NEW.periodo,
      checado = NEW.checado,
      idoutlier = NEW.idoutlier,
      doseconv = NEW.doseconv,
      escorefinal = NEW.escorefinal;
      
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
AS $BODY$
DECLARE
  V_RESULTADO public.PRESCRICAO_RESULTADO_TYPE;
	V_PARAMETRO public.PARAMETRO_TYPE;
BEGIN
    IF pg_trigger_depth() = 1 then
      -- DEFINIR PARAMETROS
      V_PARAMETRO.nome_schema = 'demo';
      V_PARAMETRO.features = ARRAY[]::text[];
      --V_PARAMETRO.features = ARRAY['CPOE']::text[];
      V_PARAMETRO.skip_list = ARRAY[]::text[];
      
      -- FUNCAO CENTRAL
      V_RESULTADO := public.complete_prescricao(V_PARAMETRO.*, new.*);
      
      -- USAR VALORES CALCULADOS
      new.idsegmento := V_RESULTADO.idsegmento;
      new.dtvigencia := V_RESULTADO.dtvigencia;
      
      INSERT INTO demo.prescricao (
        fkhospital, fkprescricao, fkpessoa, nratendimento, fksetor, dtprescricao, idsegmento, 
        leito, prontuario, dtvigencia, prescritor, agregada, indicadores, aggsetor, aggmedicamento, 
        concilia, convenio, dtatualizacao
      ) 
      VALUES (
        NEW.fkhospital, NEW.fkprescricao, NEW.fkpessoa, NEW.nratendimento, NEW.fksetor, NEW.dtprescricao, NEW.idsegmento, 
        NEW.leito, NEW.prontuario, NEW.dtvigencia, NEW.prescritor, NEW.agregada, NEW.indicadores, NEW.aggsetor, NEW.aggmedicamento, 
        NEW.concilia, NEW.convenio, NEW.dtatualizacao
      )
      ON CONFLICT (fkprescricao)
      DO UPDATE SET 
        fkpessoa = NEW.fkpessoa,
        fksetor = NEW.fksetor,
		    leito = NEW.leito,
        dtprescricao = NEW.dtprescricao,
        idsegmento = NEW.idsegmento,
        dtatualizacao = NEW.dtatualizacao
      WHERE
        demo.prescricao.status <> 's';

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

        INSERT INTO demo.checkedindex
            (
              nratendimento, fkmedicamento, doseconv, frequenciadia, sletapas, slhorafase,
              sltempoaplicacao, sldosagem, dtprescricao, via, horario, dose
            )
            SELECT p.nratendimento, pm.fkmedicamento, pm.doseconv, pm.frequenciadia, 
            COALESCE(pm.sletapas, 0), COALESCE(pm.slhorafase, 0), 
            COALESCE(pm.sltempoaplicacao, 0), COALESCE(pm.sldosagem, 0),
            p.dtprescricao, COALESCE(pm.via, ''), COALESCE(left(pm.horario ,50), ''),
            pm.dose
            FROM demo.prescricao p
            INNER JOIN demo.presmed pm ON pm.fkprescricao = p.fkprescricao 
            WHERE p.status = 's'
            AND p.fkprescricao = NEW.fkprescricao
            AND pm.dtsuspensao is null;

        DELETE FROM demo.checkedindex
            WHERE dtprescricao < current_date - 15;

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
  LANGUAGE plpgsql
AS $function$
declare 
	V_RESULTADO public.PRESCRICAOAGG_RESULTADO_TYPE;
	V_PARAMETRO public.PARAMETRO_TYPE;
begin
	IF pg_trigger_depth() = 1 then

    -- DEFINIR PARAMETROS
    V_PARAMETRO.nome_schema = 'demo';
    V_PARAMETRO.features = ARRAY[]::text[];
    --V_PARAMETRO.features = ARRAY['CPOE']::text[];
    V_PARAMETRO.skip_list = ARRAY[]::text[];
    
    -- FUNCAO CENTRAL
    V_RESULTADO := public.complete_prescricaoagg(V_PARAMETRO.*, new.*);
    
    -- USAR VALORES CALCULADOS
    new.idsegmento := V_RESULTADO.idsegmento;
    new.fkfrequencia := V_RESULTADO.fkfrequencia;
    new.fkunidademedida := V_RESULTADO.fkunidademedida;

    new.frequenciadia := V_RESULTADO.frequenciadia;
    new.doseconv := V_RESULTADO.doseconv;
    new.peso := V_RESULTADO.peso;

		INSERT INTO 
			demo.prescricaoagg
      (
        fkhospital, fksetor, fkmedicamento, fkunidademedida, 
        fkfrequencia, dose, frequenciadia, peso, contagem, doseconv
      )
		values
			(
        NEW.fkhospital, NEW.fksetor, NEW.fkmedicamento, NEW.fkunidademedida, 
        NEW.fkfrequencia, NEW.dose, NEW.frequenciadia, NEW.peso, NEW.contagem, NEW.doseconv
      )
      ON CONFLICT (
        fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, peso
      )
		DO UPDATE SET 
			contagem = NEW.contagem, 
			doseconv = NEW.doseconv, 
			idsegmento = NEW.idsegmento, 
      updated_at = now(),
			frequenciadia = NEW.frequenciadia;

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   

END;$function$
;


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

    IF NEW.frequenciadia IS NULL AND NEW.frequenciahora IS NOT NULL AND NEW.frequenciahora <> 0 THEN
            NEW.frequenciadia := 24 / NEW.frequenciahora;
    END IF;

   IF pg_trigger_depth() = 1 then
      INSERT INTO demo.frequencia (fkhospital, fkfrequencia, nome, frequenciadia, frequenciahora) 
            VALUES(NEW.fkhospital, NEW.fkfrequencia, NEW.nome, NEW.frequenciadia, NEW.frequenciahora)
         ON CONFLICT (fkhospital, fkfrequencia)
         DO NOTHING;
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

CREATE OR REPLACE FUNCTION demo.insert_update_evolucao()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
 TEST_EXISTS int8;
BEGIN

   TEST_EXISTS := (
           SELECT fkevolucao FROM demo.evolucao e
				   WHERE fkevolucao = NEW.fkevolucao 
				   LIMIT 1
   );

   IF TEST_EXISTS IS NULL THEN
      RETURN NEW;
   ELSE
      RETURN NULL;
   END IF;   
END;$BODY$;

ALTER FUNCTION demo.insert_update_evolucao()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_insert_update_evolucao ON demo.evolucao;
		     
CREATE TRIGGER trg_insert_update_evolucao
    BEFORE INSERT 
    ON demo.evolucao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.insert_update_evolucao();

--------

CREATE OR REPLACE  FUNCTION demo.complete_intervencao_cpoe()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

		NEW.fksetor = (
		    SELECT fksetor FROM demo.prescricao p
		    WHERE p.nratendimento = NEW.nratendimento
		    ORDER BY p.dtprescricao
            LIMIT 1
		);	

      RETURN NEW;

END;$BODY$;

ALTER FUNCTION demo.complete_intervencao_cpoe()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_intervencao_cpoe ON demo.intervencao;
		     
CREATE TRIGGER trg_complete_intervencao_cpoe
    BEFORE INSERT 
    ON demo.intervencao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_intervencao_cpoe();

DROP FUNCTION IF EXISTS demo.atualiza_prescricao();

CREATE OR REPLACE FUNCTION demo.atualiza_prescricao()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare 
	V_RESULTADO public.PRESCRICAO_RESULTADO_TYPE;
	V_PARAMETRO public.PARAMETRO_TYPE;
BEGIN
  -- DEFINIR PARAMETROS
  V_PARAMETRO.nome_schema = 'demo';
  V_PARAMETRO.features = ARRAY[]::text[];
  --V_PARAMETRO.features = ARRAY['CPOE']::text[];
  V_PARAMETRO.skip_list = ARRAY[]::text[];
  
  -- FUNCAO CENTRAL
  V_RESULTADO := public.atualiza_prescricao(V_PARAMETRO.*, new.*);
  
  -- USAR VALORES CALCULADOS
  new.dtvigencia := V_RESULTADO.dtvigencia;
  new.aggsetor := V_RESULTADO.aggsetor;

  RETURN NEW;

END;$function$
;

ALTER FUNCTION demo.atualiza_prescricao() OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_atualiza_prescricao ON demo.prescricao;

create trigger trg_atualiza_prescricao before
update
    on
    demo.prescricao for each row execute function demo.atualiza_prescricao();

--------
