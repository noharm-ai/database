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

		-- USAR VALORES CALCULADOS
		new.origem := PRESMED_RESULTADO.origem;
		new.idsegmento := PRESMED_RESULTADO.idsegmento;

		new.idoutlier := PRESMED_RESULTADO.idoutlier;
		new.aprox := PRESMED_RESULTADO.aprox;
		new.escorefinal := PRESMED_RESULTADO.escorefinal;

		new.sonda := PRESMED_RESULTADO.sonda;
		new.intravenosa := PRESMED_RESULTADO.intravenosa;

		new.checado := PRESMED_RESULTADO.checado;
		if new.periodo is null then 	-- com esse if, usa o período do pep quando disponível
			new.periodo := PRESMED_RESULTADO.periodo;
            new.tp_periodo := 1;
        ELSE
            new.tp_periodo := 2;
		end if;
		new.frequenciadia := PRESMED_RESULTADO.frequenciadia;
		new.doseconv := PRESMED_RESULTADO.doseconv;
		new.alergia := PRESMED_RESULTADO.alergia;

		new.cpoe_grupo := PRESMED_RESULTADO.cpoe_grupo;


    INSERT INTO demo.presmed (
      fkprescricao, fkpresmed, fkfrequencia, fkmedicamento,
      fkunidademedida, dose, frequenciadia, via, idsegmento, doseconv, idoutlier, escorefinal,
      origem, dtsuspensao, horario, complemento, aprox, checado, periodo,
      slagrupamento, slacm, sletapas, slhorafase, sltempoaplicacao, sldosagem, sltipodosagem,
      alergia, sonda, intravenosa, cpoe_grupo, cpoe_nrseq, cpoe_nrseq_anterior, periodo_total,
      tp_periodo
    )
    VALUES (
      NEW.fkprescricao, NEW.fkpresmed, NEW.fkfrequencia, NEW.fkmedicamento,
      NEW.fkunidademedida, NEW.dose, NEW.frequenciadia, NEW.via, NEW.idsegmento, NEW.doseconv, NEW.idoutlier, NEW.escorefinal,
      NEW.origem, NEW.dtsuspensao, NEW.horario, NEW.complemento, NEW.aprox, NEW.checado, NEW.periodo,
      NEW.slagrupamento, NEW.slacm, NEW.sletapas, NEW.slhorafase, NEW.sltempoaplicacao, NEW.sldosagem,
      NEW.sltipodosagem, NEW.alergia, NEW.sonda, NEW.intravenosa, NEW.cpoe_grupo, NEW.cpoe_nrseq, NEW.cpoe_nrseq_anterior,
      NEW.periodo_total, NEW.tp_periodo
    )
    ON CONFLICT (fkpresmed)
    DO UPDATE SET
      dtsuspensao = NEW.dtsuspensao,
      frequenciadia = NEW.frequenciadia,
      periodo = NEW.periodo,
      periodo_total = NEW.periodo_total,
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
      V_PARAMETRO.features = ARRAY['COMPLETE_PRESCRICAO_FEATURES_REPLACE']::text[];
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
        fkfrequencia, dose, frequenciadia, peso, contagem, doseconv,
        idsegmento
      )
		values
			(
        NEW.fkhospital, NEW.fksetor, NEW.fkmedicamento, NEW.fkunidademedida,
        NEW.fkfrequencia, NEW.dose, NEW.frequenciadia, NEW.peso, NEW.contagem, NEW.doseconv,
        NEW.idsegmento
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
