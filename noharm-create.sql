DROP SCHEMA IF EXISTS demo CASCADE;

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
  "unidade" varchar(250) DEFAULT NULL
);

CREATE TABLE demo."intervencao" (
  "fkpresmed" bigint DEFAULT 0,
  "fkprescricao" bigint DEFAULT 0,
  "nratendimento" bigint NOT NULL,
  "idmotivointervencao" smallint [] NULL,
  "erro" boolean NULL,
  "dtintervencao" timestamp NOT NULL DEFAULT NOW(),
  "interacoes" bigint [] NULL,
  "custo" boolean NULL,
  "observacao" text NULL,
  "status" char(1) NOT NULL DEFAULT '0',
  "transcricao" json DEFAULT NULL,
  "update_at" timestamp NOT NULL DEFAULT NOW(),
  "update_by" integer NOT NULL
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
  "update_at" timestamp DEFAULT NOW(),
  "update_by" integer
);

CREATE TABLE demo."prescricaoagg" (
  "fkhospital" smallint DEFAULT 1,
  "fksetor" integer NOT NULL,
  "idsegmento" smallint DEFAULT null,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(32) DEFAULT NULL,
  "fkfrequencia" varchar(16) DEFAULT NULL,
  "dose" float4 DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "peso" float4 DEFAULT NULL,
  "contagem" integer DEFAULT NULL
);

CREATE TABLE demo."presmed" (
  "fkpresmed" bigserial PRIMARY KEY NOT NULL,
  "fkprescricao" bigint NOT NULL,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(32) DEFAULT NULL,
  "fkfrequencia" varchar(16) DEFAULT NULL,
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
  "sltempoaplicacao" bigint DEFAULT NULL,
  "sldosagem" float4 DEFAULT NULL,
  "sltipodosagem" varchar(16) DEFAULT NULL,
  "alergia" char(1) DEFAULT NULL,
  "status" char(1),
  "aprox" boolean,
  "suspenso" boolean,
  "checado" boolean  DEFAULT NULL,
  "periodo" int2  DEFAULT NULL,
  "update_at" timestamp DEFAULT NOW(),
  "update_by" integer
);

CREATE TABLE demo."medicamento" (
  "fkhospital" smallint DEFAULT 1,
  "fkmedicamento" bigint PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL,
  "sctid" bigint DEFAULT NULL
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
  "custo" float4,
  "tempotratamento" smallint,
  "update_at" timestamp DEFAULT NULL,
  "update_by" integer DEFAULT NULL
);

CREATE TABLE demo."motivointervencao" (
  "fkhospital" smallint DEFAULT 1,
  "idmotivointervencao" SERIAL PRIMARY KEY NOT NULL,
  "idmotivomae" int4 NULL,
  "ativo" bool NOT NULL DEFAULT true,
  "nome" varchar(250) NOT NULL
);

CREATE TABLE demo."frequencia" (
  "fkhospital" smallint DEFAULT 1,
  "fkfrequencia" varchar(16) PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "frequenciahora" float4 DEFAULT NULL
);

CREATE TABLE demo."unidademedida" (
  "fkhospital" smallint DEFAULT 1,
  "fkunidademedida" varchar(32) PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL
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
  "status" smallint DEFAULT NULL
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
  "fksetor" integer PRIMARY KEY NOT NULL,
  "nome" varchar(255) NOT NULL
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
  "nomes" smallint NULL,
  "sinaistexto" varchar(255) NULL,
  "dadostexto" varchar(255) NULL,
  "complicacoestexto" varchar(255) NULL,
  "doencastexto" varchar(255) NULL,
  "sintomastexto" varchar(255) NULL,
  "processed" smallint NULL,
  "total" smallint NULL,
  "exame" boolean NULL,
  "update_at" timestamp NULL,
  "update_by" integer NULL,
  "review_at" timestamp NULL,
  "review_by" integer NULL
);

CREATE TABLE demo.checkedindex (
  "nratendimento" bigint NOT NULL,
  "fkmedicamento" bigint NOT NULL,
  "doseconv" float4 DEFAULT 0,
  "frequenciadia" float4 DEFAULT 0,
  "sletapas" bigint DEFAULT 0,
  "slhorafase" float4 DEFAULT 0,
  "sltempoaplicacao" bigint DEFAULT 0,
  "sldosagem" float4 DEFAULT 0,
  "dtprescricao" timestamp NOT NULL
);
CREATE INDEX demo_checkedindex_idx ON demo.checkedindex ("nratendimento","fkmedicamento");

CREATE UNIQUE INDEX demo_intervencao_unique ON demo."intervencao" ("fkpresmed","fkprescricao");
CREATE INDEX demo_intervencao_nratendimento_idx ON demo."intervencao" ("nratendimento");
CREATE INDEX demo_intervencao_dtintervencao_idx ON demo."intervencao" USING brin ("dtintervencao") with (pages_per_range = 1);

CREATE INDEX demo_exame_fkx ON demo."exame" ("fkpessoa");
CREATE INDEX demo_exame_dtexame_idx ON demo."exame" USING brin ("dtexame") with (pages_per_range = 1);

CREATE UNIQUE INDEX demo_outlier_idx ON demo."outlier" ("fkmedicamento", "idsegmento", "doseconv", "frequenciadia");

CREATE INDEX demo_prescricao_fksetor_idx ON demo."prescricao" ("fksetor");
CREATE INDEX demo_prescricao_idsegmento_idx ON demo."prescricao" ("idsegmento");
CREATE INDEX demo_prescricao_nratendimento_idx ON demo."prescricao" ("nratendimento","dtprescricao");
CREATE INDEX demo_prescricao_update_by_idx ON demo."prescricao" ("update_by");
CREATE INDEX demo_prescricao_update_at_idx ON demo."prescricao" USING brin ("update_at") with (pages_per_range = 1);
CREATE INDEX demo_prescricao_evolucao_at_idx ON demo."prescricao" USING brin ("evolucao_at") with (pages_per_range = 1);

CREATE INDEX demo_pessoa_alertadata_idx ON demo."pessoa" USING brin ("alertadata") with (pages_per_range = 1);
CREATE INDEX demo_pessoa_dtnascimento_idx ON demo."pessoa" USING brin ("dtnascimento") with (pages_per_range = 1);

CREATE INDEX demo_presmed_fkmedicamento_idx ON demo."presmed" ("fkmedicamento", "idsegmento");
CREATE INDEX demo_presmed_update_by_idx ON demo."presmed" ("update_by");
CREATE INDEX demo_presmed_fkprescricao_idx ON demo."presmed" ("fkprescricao");
CREATE INDEX demo_presmed_slagrupamento_idx ON demo."presmed" USING brin ("slagrupamento") with (pages_per_range = 1);

CREATE UNIQUE INDEX ON demo.prescricaoagg USING btree (fkmedicamento, fksetor, fkunidademedida, fkfrequencia, dose, peso);
CREATE INDEX ON demo."prescricaoagg" ("idsegmento", "fkmedicamento", "doseconv", "frequenciadia");

CREATE UNIQUE INDEX demo_medicamento_idx ON demo."medicamento" ("fkhospital", "fkmedicamento");
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

CREATE OR REPLACE VIEW demo.usuario
  AS SELECT usuario.idusuario,
    usuario.fkusuario
    FROM public.usuario
    WHERE usuario.schema = 'demo';
