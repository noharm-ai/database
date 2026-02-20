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
  PRESMED_RESULTADO public.PRESMED_RESULTADO_TYPE_V2;
	PRESMED_PARAMETRO public.PARAMETRO_TYPE;
BEGIN

  IF pg_trigger_depth() = 1 then

    -- DEFINIR PARAMETROS
	PRESMED_PARAMETRO.nome_schema = 'demo';
	PRESMED_PARAMETRO.features = ARRAY['COMPLETE_PRESMED_FEATURES_REPLACE']::text[];
	PRESMED_PARAMETRO.skip_list = ARRAY[]::text[];

	-- FUNCAO CENTRAL
	PRESMED_RESULTADO := public.complete_presmed_v2(PRESMED_PARAMETRO.*, new.*);

	IF PRESMED_RESULTADO IS NULL THEN
		RETURN NULL;
	END IF;

	-- QUANDO NECESSARIO, UTILIZE ESTE ESPACO PARA ALTERAR OS VALORES CALCULADOS
      -- EX:
      -- PRESMED_RESULTADO.idsegmento := 2;

    -- UPSERT
    PERFORM public.upsert_presmed(PRESMED_PARAMETRO.nome_schema, new, PRESMED_RESULTADO);

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
      V_PARAMETRO.features = ARRAY['COMPLETE_PRESCRICAO_FEATURES_REPLACE']::text[];
      V_PARAMETRO.skip_list = ARRAY[]::text[];

      -- FUNCAO CENTRAL
      V_RESULTADO := public.complete_prescricao(V_PARAMETRO.*, new.*);

      -- QUANDO NECESSARIO, UTILIZE ESTE ESPACO PARA ALTERAR OS VALORES CALCULADOS
      -- EX:
      -- V_RESULTADO.idsegmento := 2;

      -- UPSERT
      PERFORM public.upsert_prescricao(V_PARAMETRO.nome_schema, new, V_RESULTADO);

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
    V_PARAMETRO.features = ARRAY['COMPLETE_PRESCRICAOAGG_FEATURES_REPLACE']::text[];
    V_PARAMETRO.skip_list = ARRAY[]::text[];

    -- FUNCAO CENTRAL
    V_RESULTADO := public.complete_prescricaoagg(V_PARAMETRO.*, new.*);

	PERFORM public.upsert_prescricaoagg(V_PARAMETRO.nome_schema, new, V_RESULTADO);

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

-------------------

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
  V_PARAMETRO.features = ARRAY['ATUALIZA_PRESCRICAO_FEATURES_REPLACE']::text[];
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
