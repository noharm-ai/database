CREATE SCHEMA demo;
GRANT ALL ON SCHEMA demo TO postgres;


CREATE TABLE demo."exame" (
  "fkexame" bigint NOT NULL,
  "fkpessoa" bigint NOT NULL,
  "nratendimento" bigint DEFAULT null,
  "fkprescricao" bigint DEFAULT null,
  "dtexame" timestamp NOT NULL,
  "tpexame" varchar(100) NOT NULL,
  "resultado" float4 DEFAULT null,
  "unidade" varchar(250) DEFAULT NULL,
  "created_at" timestamp NOT NULL DEFAULT NOW(),
  "created_by" int4 DEFAULT NULL
);

CREATE TABLE demo."cultura_cabecalho" (
  "idculturacab" serial4 NOT NULL,  
  "fkpessoa" bigint NOT NULL,
  "fksetor" int4 null,
  "nratendimento" bigint DEFAULT null,
  "fkexame" bigint NOT NULL,
  "fkitemexame" bigint NOT NULL,
  "nomeexame" varchar(250) NULL,
  "nomematerial" varchar(250) NULL,
  "nomematerialtipo" varchar(250) NULL,
  "dtpedido" timestamp NULL,
  "dtcoleta" timestamp NULL,
  "dtliberacao" timestamp NULL,
  "gram" varchar(250) DEFAULT null,
  "dscolonia" varchar(250) DEFAULT null,
  "nrcolonia" bigint DEFAULT NULL,
  "resultprevio" varchar(250) DEFAULT null,
  "complemento" text DEFAULT null,
  "predict" boolean NULL
);

CREATE TABLE demo.cultura (
  "idcultura" serial4 NOT NULL,  
  "fkexame" bigint NOT NULL,
  "fkitemexame" bigint NOT NULL,
  "fkmedicamento" int8 NULL,
  "nomemedicamento" varchar(250) NULL DEFAULT NULL::character varying,
  "fkmicroorganismo" int8 NULL,
  "nomemicroorganismo" varchar(250) NULL DEFAULT NULL::character varying,
  "qtmicroorganismo" varchar(250) NULL,
  "resultado" varchar(250) NULL DEFAULT NULL::character varying,
  "predict" bpchar(1) NULL,
  "predict_proba" float4 NULL,
  "medicamento_proba" float4 NULL
);

CREATE TABLE demo."intervencao" (
  "idintervencao" serial NOT NULL,
  "fkpresmed" bigint DEFAULT 0,
  "fkprescricao" bigint DEFAULT 0,
  "nratendimento" bigint NOT NULL,
  "fksetor" integer DEFAULT null,
  "idmotivointervencao" smallint [] NULL,
  "erro" boolean NULL,
  "dtintervencao" timestamp NOT NULL DEFAULT NOW(),
  "interacoes" bigint [] NULL,
  "custo" boolean NULL,
  "observacao" text NULL,
  "status" char(1) NOT NULL DEFAULT '0',
  "transcricao" json DEFAULT NULL,
  "dias_economia" smallint default NULL,
  "dose_despendida" float4 default NULL,
  "tp_economia" smallint NULL,
  "vl_economia_dia" float4 NULL,
  "vl_economia_dia_manual" boolean not null default false,
  "fkpresmed_destino" int8 null,
  "origem" jsonb null,
  "destino" jsonb null,
  "dt_base_economia" timestamp null,
  "dt_fim_economia" timestamp null,
  "ram" jsonb null,
  "periodo_uso" int4 null,
  "update_at" timestamp NOT NULL DEFAULT NOW(),
  "update_by" integer NOT NULL,
  "outcome_at" timestamp null,
  "outcome_by" integer null
);

CREATE TABLE demo."outlier" (
  "fkmedicamento" bigint NOT NULL,
  "idoutlier" SERIAL PRIMARY KEY NOT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "contagem" integer DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "escore" smallint DEFAULT NULL,
  "escoremanual" smallint DEFAULT NULL,
  "update_at" timestamp DEFAULT NOW(),
  "update_by" integer
);

CREATE TABLE demo."observacao" (
  "idoutlier" integer DEFAULT 0,
  "fkpresmed" bigint DEFAULT 0,
  "nratendimento" bigint DEFAULT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "fkmedicamento" bigint DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "text" text DEFAULT NULL,
  "update_at" timestamp DEFAULT NOW(),
  "update_by" integer
);

CREATE TABLE demo."pessoa" (
  "fkhospital" smallint DEFAULT 1,
  "fkpessoa" bigint NOT NULL,
  "nratendimento" bigint UNIQUE NOT NULL,
  "dtnascimento" date DEFAULT NULL,
  "dtinternacao" timestamp NOT NULL,
  "dtalta" timestamp DEFAULT NULL,
  "motivoalta" varchar(100) DEFAULT NULL,
  "cor" varchar(100) DEFAULT NULL,
  "sexo" char(1) DEFAULT NULL,
  "peso" float4 DEFAULT NULL,
  "altura" float4 DEFAULT NULL,
  "dtpeso" timestamp DEFAULT NULL,
  "anotacao" text DEFAULT NULL,
  "alertadata" timestamp DEFAULT NULL,
  "alertatexto" text DEFAULT NULL,
  "alertavigencia" timestamp DEFAULT NULL,
  "alerta_by" integer DEFAULT NULL,
  "dialise" char(1) DEFAULT NULL,
  "lactante" boolean DEFAULT NULL,
  "gestante" boolean DEFAULT NULL,
  "st_concilia" smallint default 0,
  "marcadores" _varchar DEFAULT NULL,
  "medico_responsavel" varchar(255) NULL,
  "dt_alta_prevista" timestamp default null,
  "idcid" varchar(50) default NULL,
  "fksetor" int4 default NULL,
  "leito" varchar(32) default null,
  "dt_ultima_transferencia" timestamp default null,
  "update_at" timestamp DEFAULT NULL,
  "update_by" integer DEFAULT NULL,
  PRIMARY KEY ("nratendimento")
);

CREATE TABLE demo."prescricao" (
  "fkhospital" smallint DEFAULT 1,
  "fksetor" integer NOT NULL,
  "fkprescricao" bigint PRIMARY KEY NOT NULL,
  "fkpessoa" bigint NOT NULL,
  "nratendimento" bigint NOT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "dtprescricao" timestamp NOT NULL,
  "dtvigencia" timestamp NULL,
  "dtatualizacao" timestamp NULL,
  "status" char(1) DEFAULT '0',
  "leito" varchar(16) NULL,
  "prontuario" int8 NULL,
  "prescritor" varchar(255) NULL,
  "indicadores" json DEFAULT NULL,
  "evolucao" text DEFAULT NULL,
  "evolucao_at" timestamp DEFAULT NULL,
  "agregada" boolean DEFAULT NULL,
  "aggsetor" integer [] NULL,
  "aggmedicamento" bigint [] NULL,
  "concilia" char(1) DEFAULT NULL,
  "convenio" varchar(100) NULL,
  "tp_revisao" smallint default 0,
  "update_at" timestamp DEFAULT NOW(),
  "update_by" integer,
  "dtcriacao_origem" timestamp default null
);

create table demo."prescricao_audit" (
	"idprescricao_audit" serial8 not null,
	"tp_audit" smallint not null,
	"nratendimento" bigint not null,
	"fkprescricao" bigint not null,
	"dtprescricao" timestamp not null,
	"fksetor" integer not null,
	"total_itens" integer not null,
	"agregada" boolean, 
	"concilia" char(1),
	"idsegmento" smallint,
	"leito" varchar(16),
  	"extra" json,
	"created_at" timestamp not null,
	"created_by" integer not null
);

CREATE TABLE demo."prescricaoagg" (
  "fkhospital" smallint DEFAULT 1,
  "fksetor" integer NOT NULL,
  "idsegmento" smallint DEFAULT null,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(32) DEFAULT NULL,
  "fkfrequencia" varchar(32) DEFAULT NULL,
  "dose" float4 DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "peso" float4 DEFAULT NULL,
  "contagem" integer DEFAULT NULL,
  "created_at" timestamp not null default now(),
  "updated_at" timestamp null
);

CREATE TABLE demo."presmed" (
  "fkpresmed" bigserial PRIMARY KEY NOT NULL,
  "fkprescricao" bigint NOT NULL,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(32) DEFAULT NULL,
  "fkfrequencia" varchar(32) DEFAULT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "idoutlier" integer DEFAULT NULL,
  "dose" float4 DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "via" varchar(50) DEFAULT NULL,
  "sonda" boolean DEFAULT NULL,
  "intravenosa" boolean DEFAULT NULL,
  "horario" varchar(600) DEFAULT NULL,
  "complemento" text,
  "origem" varchar(13) DEFAULT NULL,
  "dtsuspensao" timestamp DEFAULT NULL,
  "escorefinal" smallint DEFAULT NULL,
  "slagrupamento" bigint DEFAULT NULL,
  "slacm" varchar(1) DEFAULT NULL,
  "sletapas" bigint DEFAULT NULL,
  "slhorafase" float4 DEFAULT NULL,
  "sltempoaplicacao" float4 DEFAULT NULL,
  "sldosagem" float4 DEFAULT NULL,
  "sltipodosagem" varchar(16) DEFAULT NULL,
  "alergia" char(1) DEFAULT NULL,
  "status" char(1),
  "aprox" boolean,
  "suspenso" boolean,
  "checado" boolean  DEFAULT NULL,
  "periodo" int2  DEFAULT NULL,
  "periodo_total" int2  DEFAULT NULL,
  "update_at" timestamp DEFAULT NOW(),
  "update_by" integer,
  "cpoe_grupo" bigint NULL,
  "cpoe_nrseq" bigint NULL,
  "cpoe_nrseq_anterior" bigint NULL,
  "form" json NULL,
  "aprazamento" timestamp[][] NULL,
  "nr_ordem" int4 NULL
);

create table demo."presmed_audit" (
	"idpresmed_audit" serial8 not null,
	"tp_audit" smallint not null,
	"fkpresmed" bigint not null,
  "extra" json,
	"created_at" timestamp not null,
	"created_by" integer not null
);

CREATE TABLE demo."medicamento" (
  "fkhospital" smallint DEFAULT 1,
  "fkmedicamento" bigint NOT NULL,
  "nome" varchar(250) NOT NULL,
  "sctid" bigint DEFAULT NULL,
  "ia_acuracia" float4 null, 
  "origem" varchar(13) DEFAULT NULL,
  "created_by" int4 null,
  "updated_by" int4 null,
  "created_at" timestamp NOT NULL DEFAULT now(),
  "updated_at" timestamp null,
  PRIMARY KEY ("fkhospital", "fkmedicamento")
);

CREATE TABLE demo."medatributos" (
  "fkmedicamento" bigint NOT NULL,
  "idsegmento" smallint NOT NULL,
  "antimicro" boolean,
  "mav" boolean,
  "controlados" boolean,
  "naopadronizado" boolean,
  "dosemaxima" float4,
  "renal" smallint,
  "hepatico" smallint,
  "plaquetas" integer,
  "idoso" boolean,
  "sonda" boolean,
  "quimio" boolean,
  "divisor" float4,
  "usapeso" boolean,
  "concentracao" float4,
  "concentracaounidade" varchar(3),
  "linhabranca" boolean,
  "fkunidademedida" varchar(32),
  "fkunidademedidacusto" varchar(32),
  "custo" float4,
  "tempotratamento" smallint,
  "risco_queda" smallint,
  "dialisavel" boolean,
  "lactante" varchar(1),
  "gestante" varchar(1), 
  "jejum" boolean,
  "ref_dosemaxima" float4,
  "ref_dosemaxima_peso" float4,
  "update_at" timestamp DEFAULT NULL,
  "update_by" integer DEFAULT NULL
);

CREATE TABLE demo."motivointervencao" (
  "fkhospital" smallint DEFAULT 1,
  "idmotivointervencao" SERIAL PRIMARY KEY NOT NULL,
  "idmotivomae" int4 NULL,
  "ativo" bool NOT NULL DEFAULT true,
  "nome" varchar(250) NOT NULL,
  "suspensao" bool NOT NULL DEFAULT false,
  "substituicao" bool NOT NULL DEFAULT false,
  "economia_customizada" bool NOT NULL DEFAULT false,
  "bloqueante" bool NOT NULL DEFAULT false,
  "tp_relacao" smallint NOT NULL DEFAULT 0,
  "ram" bool NOT NULL DEFAULT false
);

CREATE TABLE demo."frequencia" (
  "fkhospital" smallint DEFAULT 1,
  "fkfrequencia" varchar(32) NOT NULL,
  "nome" varchar(250) NOT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "frequenciahora" float4 DEFAULT NULL,
  "jejum" bool DEFAULT false,
  PRIMARY KEY ("fkhospital", "fkfrequencia")
);

CREATE TABLE demo."unidademedida" (
  "fkhospital" smallint DEFAULT 1,
  "fkunidademedida" varchar(32) NOT NULL,
  "nome" varchar(250) NOT NULL,
  "unidademedida_nh" varchar(32),
  PRIMARY KEY ("fkhospital", "fkunidademedida")
);

CREATE TABLE demo."unidadeconverte" (
  "idsegmento" smallint DEFAULT 1,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(32) NOT NULL,
  "fator" float4 NOT NULL
);

CREATE TABLE demo."segmento" (
  "idsegmento" SERIAL PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL,
  "status" smallint DEFAULT NULL,
  "tp_segmento" smallint,
  "cpoe" boolean not null default false,
  "cpoe_ambulatorio" boolean not null default false
);

CREATE TABLE demo."segmentoexame" (
  "idsegmento" smallint NOT NULL,
  "tpexame" varchar(100) NOT NULL,
  "abrev" varchar(50),
  "nome" varchar(250), 
  "min" float4,
  "max" float4, 
  "referencia" varchar(250), 
  "posicao" smallint, 
  "ativo" boolean,
  "update_at" timestamp NOT NULL DEFAULT NOW(),
  "update_by" integer NOT NULL,
  PRIMARY KEY ("idsegmento", "tpexame")
);

CREATE TABLE demo."segmentosetor" (
  "idsegmento" smallint NOT NULL,
  "fkhospital" smallint NOT NULL,
  "fksetor" integer NOT NULL
);

CREATE TABLE demo."hospital" (
  "fkhospital" smallint UNIQUE PRIMARY KEY NOT NULL,
  "nome" varchar(255) NOT NULL
);

CREATE TABLE demo."setor" (
  "fkhospital" smallint DEFAULT 1,
  "fksetor" integer NOT NULL,
  "nome" varchar(255) NOT NULL,
  PRIMARY KEY ("fkhospital", "fksetor")
);

CREATE TABLE demo."memoria" (
  "idmemoria" SERIAL NOT NULL,
  "tipo" varchar(100) NOT NULL,
  "valor" json NOT NULL,
  "update_at" timestamp NOT NULL DEFAULT NOW(),
  "update_by" integer NOT NULL,
  PRIMARY KEY ("idmemoria", "tipo")
);

CREATE TABLE demo."evolucao" (
  "fkevolucao" bigint PRIMARY KEY NOT NULL,
  "nratendimento" bigint NOT NULL,
  "dtevolucao" timestamp NOT NULL,
  "texto" text DEFAULT NULL,
  "prescritor" varchar(255) NULL,
  "cargo" varchar(255) NULL,
  "complicacoes" smallint NULL,
  "sintomas" smallint NULL,
  "doencas" smallint NULL,
  "medicamentos" smallint NULL,
  "dados" smallint NULL,
  "conduta" smallint NULL,
  "sinais" smallint NULL,
  "alergia" smallint NULL,
  "dialise" smallint NULL,
  "nomes" smallint NULL,
  "sinaistexto" varchar(255) NULL,
  "dadostexto" varchar(255) NULL,
  "complicacoestexto" varchar(255) NULL,
  "doencastexto" varchar(255) NULL,
  "sintomastexto" varchar(255) NULL,
  "alergiatexto" varchar(255) NULL,
  "dialisetexto" varchar(255) NULL,
  "germetexto" varchar(255) NULL,
  "processed" smallint NULL,
  "total" smallint NULL,
  "exame" boolean NULL,
  "update_at" timestamp NULL,
  "update_by" integer NULL,
  "review_at" timestamp NULL,
  "review_by" integer NULL,
  "anotacoes" jsonb NULL,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE demo.checkedindex (
  "nratendimento" bigint NOT NULL,
  "fkmedicamento" bigint NOT NULL,
  "doseconv" float4 DEFAULT 0,
  "frequenciadia" float4 DEFAULT 0,
  "sletapas" bigint DEFAULT 0,
  "slhorafase" float4 DEFAULT 0,
  "sltempoaplicacao" float4 DEFAULT 0,
  "sldosagem" float4 DEFAULT 0,
  "dtprescricao" timestamp NOT NULL,
  "via" varchar(50) DEFAULT NULL,
  "horario" varchar(50) DEFAULT NULL,
  "dose" float4 DEFAULT 0,
  "complemento" varchar(50) DEFAULT NULL,
  "fkprescricao" int8 default null,
  "created_at" timestamp default null,
  "created_by" int4 default null
);

CREATE TABLE demo."alergia" (
  "fkpessoa" bigint NOT NULL,
  "fkmedicamento" bigint DEFAULT null,
  "nome_medicamento" varchar(250) DEFAULT NULL,
  "ativo" boolean DEFAULT true,
  "created_at" timestamp NOT NULL DEFAULT now(),
  "created_by" integer NOT NULL,
  "updated_at" timestamp DEFAULT now(),
  "updated_by" integer DEFAULT 0
);

CREATE TABLE demo."nifi_queue" (
  "idqueue" serial4 PRIMARY KEY NOT NULL,
  "url" varchar(300) NOT NULL,
  "method" varchar(100) NOT NULL,
  "body" jsonb NULL,
  "run_status" bool DEFAULT false NOT NULL,
  "response_code" int4 NULL,
  "response" jsonb NULL,
  "extra" jsonb null,
  "create_at" timestamp DEFAULT now() NOT NULL,
  "created_by" int4 NULL,
  "response_at" timestamp NULL
);

CREATE TABLE demo."evolucao_audit"(
	idevolucao_audit bigserial NOT NULL,
	tp_audit int2 NOT NULL,
	fkevolucao int8 NOT NULL,
	extra json NULL,
	created_at timestamp NOT NULL,
	created_by int4 NOT NULL
);

CREATE TABLE demo."intervencao_audit" (
	idintervencao_audit bigserial NOT NULL,
	tp_audit int2 NOT NULL,
	idintervencao int8 NOT NULL,
	extra json NULL,
	created_at timestamp NOT NULL,
	created_by int4 NOT NULL
);

CREATE TABLE demo."medatributos_audit" (
	idmedatributos_audit bigserial NOT NULL,
	tp_audit int2 NOT NULL,
	fkmedicamento int8 NOT NULL,
	idsegmento int4 NOT NULL,
	extra json NULL,
	created_at timestamp NOT NULL,
	created_by int4 NOT NULL
);

CREATE TABLE demo."pessoa_audit" (
	idpessoa_audit bigserial NOT NULL,
	tp_audit int2 NOT NULL,
	nratendimento int8 NOT NULL,
	extra json NULL,
	created_at timestamp NOT NULL,
	created_by int4 NOT NULL
);

create table demo."marcador" (
	"nome" varchar(50) not null,
	"tp_marcador" smallint not null,
	"ativo" boolean not null,
	"updated_at" timestamp null,
	"updated_by" integer null,
	"created_at" timestamp not null,
	"created_by" integer not null,
	CONSTRAINT tag_pkey PRIMARY KEY (nome, tp_marcador)
);

CREATE TABLE demo.cache_atendimento_ativo (
    "nratendimento" int8,
    "cached_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX demo_checkedindex_idx ON demo.checkedindex ("nratendimento","fkmedicamento");

CREATE UNIQUE INDEX demo_intervencao_unique ON demo."intervencao" ("idintervencao");
CREATE INDEX demo_intervencao_fkpresmed_idx ON demo."intervencao" ("fkpresmed");
CREATE INDEX demo_intervencao_fkprescricao_idx ON demo."intervencao" ("fkprescricao");
CREATE INDEX demo_intervencao_nratendimento_idx ON demo."intervencao" ("nratendimento");
CREATE INDEX demo_intervencao_idx_status_dtintervencao ON demo."intervencao" USING btree ("status", "dtintervencao");
CREATE INDEX demo_intervencao_fkpresmed_destino_idx ON demo.intervencao USING btree ("fkpresmed_destino");


CREATE UNIQUE INDEX demo_exame_idx ON demo."exame" ("fkexame", "fkpessoa", "tpexame");
CREATE INDEX demo_exame_dtexame_idx ON demo."exame" USING brin ("dtexame") with (pages_per_range = 1);
CREATE INDEX demo_exame_fkpessoa_idx ON demo."exame" USING btree ("fkpessoa");

CREATE INDEX demo_pessoa_fkpessoa_idx ON demo."pessoa" USING btree ("fkpessoa");

CREATE UNIQUE INDEX demo_cultura_cab_idx ON demo."cultura_cabecalho" ("idculturacab");
CREATE UNIQUE INDEX demo_cultura_cab_uniq ON demo."cultura_cabecalho" ("fkexame", "fkpessoa", "fkitemexame");

CREATE INDEX demo_cultura_fkitemexame_idx ON demo.cultura USING brin (fkitemexame) WITH (pages_per_range='1');
CREATE UNIQUE INDEX demo_cultura_unq ON demo."cultura" ("fkexame","fkitemexame", "fkmedicamento");

CREATE UNIQUE INDEX demo_outlier_idx ON demo."outlier" ("fkmedicamento", "idsegmento", "doseconv", "frequenciadia");

CREATE INDEX demo_prescricao_fksetor_idx ON demo."prescricao" ("fksetor");
CREATE INDEX demo_prescricao_idsegmento_idx ON demo."prescricao" ("idsegmento");
CREATE INDEX demo_prescricao_nratendimento_idx ON demo."prescricao" ("nratendimento");
CREATE INDEX demo_prescricao_dtprescricao_idx ON demo."prescricao" USING brin ("dtprescricao") WITH (pages_per_range='1');
CREATE INDEX demo_prescricao_update_by_idx ON demo."prescricao" ("update_by");
CREATE INDEX demo_prescricao_update_at_idx ON demo."prescricao" USING brin ("update_at") with (pages_per_range = 1);
CREATE INDEX demo_prescricao_evolucao_at_idx ON demo."prescricao" ("evolucao_at");

CREATE INDEX demo_prescricao_audit_fkprescricao_idx ON demo."prescricao_audit" ("fkprescricao");
CREATE INDEX demo_prescricao_audit_created_at_idx ON demo."prescricao_audit" USING brin ("created_at") with (pages_per_range = 1);

CREATE INDEX demo_presmed_audit_fkpresmed_idx ON demo."presmed_audit" ("fkpresmed");

CREATE INDEX demo_pessoa_alertadata_idx ON demo."pessoa" USING brin ("alertadata") with (pages_per_range = 1);
CREATE INDEX demo_pessoa_dtnascimento_idx ON demo."pessoa" USING brin ("dtnascimento") with (pages_per_range = 1);

CREATE INDEX demo_presmed_fkmedicamento_idx ON demo."presmed" ("fkmedicamento", "idsegmento");
CREATE INDEX demo_presmed_fkprescricao_idx ON demo."presmed" ("fkprescricao");
CREATE INDEX demo_presmed_slagrupamento_idx ON demo."presmed" USING brin ("slagrupamento") with (pages_per_range = 1);

CREATE UNIQUE INDEX ON demo.prescricaoagg USING btree (fkmedicamento, fksetor, fkunidademedida, fkfrequencia, dose, peso);
CREATE INDEX ON demo."prescricaoagg" ("idsegmento", "fkmedicamento", "doseconv", "frequenciadia");

CREATE UNIQUE INDEX demo_medatributos_idx ON demo."medatributos" ("fkmedicamento", "idsegmento");
CREATE UNIQUE INDEX demo_frequencia_idx ON demo."frequencia" ("fkhospital", "fkfrequencia");
CREATE UNIQUE INDEX demo_unidademedida_idx ON demo."unidademedida" ("fkhospital", "fkunidademedida");
CREATE UNIQUE INDEX demo_unidadeconverte_idx ON demo."unidadeconverte" ("idsegmento", "fkmedicamento", "fkunidademedida");
CREATE UNIQUE INDEX demo_segmentosetor_idx ON demo."segmentosetor" ("fkhospital", "fksetor");
CREATE UNIQUE INDEX demo_setor_idx ON demo."setor" ("fkhospital", "fksetor");

CREATE UNIQUE INDEX ON demo."observacao" ("idoutlier", "fkpresmed");
CREATE INDEX ON demo."observacao" ("nratendimento","fkmedicamento");

CREATE INDEX demo_evolucao_nratendimento_idx ON demo."evolucao" ("nratendimento");
CREATE INDEX demo_evolucao_dtevolucao_idx ON demo."evolucao" USING brin ("dtevolucao") with (pages_per_range = 1);

CREATE INDEX demo_evolucao_audit_fkevolucao_idx ON demo.evolucao_audit USING btree (fkevolucao);
CREATE INDEX demo_intervencao_audit_idintervencao_idx ON demo.intervencao_audit USING btree (idintervencao);
CREATE INDEX demo_medatributos_audit_fkmedicamento_idsegmento_idx ON demo.medatributos_audit USING btree (fkmedicamento, idsegmento);
CREATE INDEX demo_pessoa_audit_nratendimento_idx ON demo.pessoa_audit USING btree (nratendimento);

ALTER TABLE demo."alergia" ADD CONSTRAINT demo_alergia_uniq_const UNIQUE (fkpessoa,fkmedicamento);

CREATE OR REPLACE VIEW demo.usuario
  AS SELECT usuario.idusuario,
    usuario.fkusuario, usuario.nome, usuario.email, usuario.ativo
    FROM public.usuario
    WHERE usuario.schema = 'demo';

CREATE TABLE IF NOT EXISTS demo.presmed_arquivo
    (LIKE demo.presmed EXCLUDING INDEXES);

CREATE TABLE IF NOT EXISTS demo.prescricao_arquivo
    (LIKE demo.prescricao EXCLUDING INDEXES);

CREATE TABLE IF NOT EXISTS demo.exame_arquivo
    (LIKE demo.exame EXCLUDING INDEXES);

CREATE TABLE IF NOT EXISTS demo.evolucao_arquivo
    (LIKE demo.evolucao EXCLUDING INDEXES);
