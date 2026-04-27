CREATE TABLE "demo".pessoa_historico (
	fkhospital int2 DEFAULT 1 NULL,
	fkpessoa int8 NOT NULL,
	nratendimento int8 NOT NULL,
	dtnascimento date NULL,
	dtinternacao timestamp NOT NULL,
	dtalta timestamp NULL,
	motivoalta varchar(100) DEFAULT NULL::character varying NULL,
	cor varchar(100) DEFAULT NULL::character varying NULL,
	sexo bpchar(1) DEFAULT NULL::bpchar NULL,
	peso float4 NULL,
	altura float4 NULL,
	dtpeso timestamp NULL,
	anotacao text NULL,
	alertadata timestamp NULL,
	alertatexto text NULL,
	alertavigencia timestamp NULL,
	alerta_by int4 NULL,
	dialise bpchar(1) DEFAULT NULL::bpchar NULL,
	update_at timestamp NULL,
	update_by int4 NULL,
	nratendimentoref int8 NULL,
	fkespecialidade int4 NULL,
	fkresponsavel int8 NULL,
	change_type varchar(20) NULL,
	change_date timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	lactante bool NULL,
	gestante bool NULL,
	st_concilia int2 DEFAULT 0 NULL,
	marcadores _varchar NULL,
	medico_responsavel varchar(255) DEFAULT NULL::character varying NULL,
	dt_alta_prevista timestamp NULL,
	idcid varchar(50) DEFAULT NULL::character varying NULL,
	fksetor int4 NULL,
	leito varchar(32) NULL,
	dt_ultima_transferencia timestamp NULL,
	cidade varchar(250) NULL,
	CONSTRAINT pessoa_historico_unique_nratendimento_nratendimentoref UNIQUE (nratendimento, nratendimentoref)
);


CREATE OR REPLACE FUNCTION demo.log_pessoa_changes()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO demo.pessoa_historico (
        	fkhospital, fkpessoa, nratendimento, dtnascimento, dtinternacao, dtalta, motivoalta, cor, sexo, peso, altura, dtpeso, anotacao, 
        	alertadata, alertatexto, alertavigencia, alerta_by, dialise, update_at, update_by, nratendimentoref, 
        	lactante, gestante, st_concilia, marcadores, medico_responsavel, dt_alta_prevista, idcid,
          fksetor, leito, dt_ultima_transferencia, cidade,
          change_type, change_date
        )
        SELECT 
          new.fkhospital, new.fkpessoa, new.nratendimento, new.dtnascimento, new.dtinternacao, new.dtalta, 
          new.motivoalta, new.cor, new.sexo, new.peso, new.altura, new.dtpeso, new.anotacao, 
          new.alertadata, new.alertatexto, new.alertavigencia, new.alerta_by, new.dialise, new.update_at, 
          new.update_by, new.nratendimentoref, new.lactante, new.gestante, 
          new.st_concilia, new.marcadores, new.medico_responsavel, new.dt_alta_prevista, new.idcid,
          new.fksetor, new.leito, new.dt_ultima_transferencia, new.cidade, 
          'INSERT', current_timestamp
        ON CONFLICT (nratendimento, nratendimentoref) DO NOTHING;
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO demo.pessoa_historico (
        	fkhospital, fkpessoa, nratendimento, dtnascimento, dtinternacao, dtalta, motivoalta, cor, sexo, peso, altura, dtpeso, anotacao, 
        	alertadata, alertatexto, alertavigencia, alerta_by, dialise, update_at, update_by, nratendimentoref, 
        	lactante, gestante, st_concilia, marcadores, medico_responsavel, dt_alta_prevista, idcid,
          fksetor, leito, dt_ultima_transferencia, cidade,
          change_type, change_date 
        )
        SELECT new.fkhospital, new.fkpessoa, new.nratendimento, new.dtnascimento, new.dtinternacao, new.dtalta, 
          new.motivoalta, new.cor, new.sexo, new.peso, new.altura, new.dtpeso, new.anotacao, 
          new.alertadata, new.alertatexto, new.alertavigencia, new.alerta_by, new.dialise, new.update_at, 
          new.update_by, new.nratendimentoref, new.lactante, new.gestante, 
          new.st_concilia, new.marcadores, new.medico_responsavel, new.dt_alta_prevista, new.idcid,
          new.fksetor, new.leito, new.dt_ultima_transferencia, new.cidade, 
          'UPDATE', current_timestamp
        ON CONFLICT (nratendimento, nratendimentoref) DO NOTHING;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO demo.pessoa_historico (
        	fkhospital, fkpessoa, nratendimento, dtnascimento, dtinternacao, dtalta, motivoalta, cor, sexo, peso, altura, dtpeso, anotacao, 
        	alertadata, alertatexto, alertavigencia, alerta_by, dialise, update_at, update_by, nratendimentoref, 
        	lactante, gestante, st_concilia, marcadores, medico_responsavel, dt_alta_prevista, idcid,
          fksetor, leito, dt_ultima_transferencia, cidade,
          change_type, change_date 
        )
        SELECT 
          old.fkhospital, old.fkpessoa, old.nratendimento, old.dtnascimento, old.dtinternacao, old.dtalta, 
          old.motivoalta, old.cor, old.sexo, old.peso, old.altura, old.dtpeso, old.anotacao, 
        	old.alertadata, old.alertatexto, old.alertavigencia, old.alerta_by, old.dialise, old.update_at, 
          old.update_by, old.nratendimentoref, old.lactante, old.gestante, 
          old.st_concilia, old.marcadores, old.medico_responsavel, old.dt_alta_prevista, old.idcid,
          old.fksetor, old.leito, old.dt_ultima_transferencia, old.cidade, 
          'DELETE', current_timestamp
        ON CONFLICT (nratendimento, nratendimentoref) DO NOTHING;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$function$
;

create trigger pessoa_historico_trigger after insert or update on
demo.pessoa for each row execute function demo.log_pessoa_changes();


CREATE OR REPLACE FUNCTION demo.complete_evolucao()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$BEGIN

	NEW.nratendimento = coalesce (
		(SELECT p.nratendimento FROM demo.pessoa p
		WHERE p.nratendimentoref  = NEW.nratendimento limit 1)
	, NEW.nratendimento);

    RETURN NEW;

END;$function$
;

create trigger trg_complete_evolucao before
insert
    on
    demo.evolucao for each row execute function demo.complete_evolucao();



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

      NEW.nratendimentoref = NEW.nratendimento;

      if new.concilia is null then
        NEW.nratendimento = NEW.prontuario;	
      end if;

      -- UPSERT
      PERFORM public.upsert_prescricao(V_PARAMETRO.nome_schema, new, V_RESULTADO);

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;
END;$BODY$;
