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
  "resultado" float DEFAULT null,
  "unidade" varchar(250) DEFAULT NULL
);

CREATE TABLE demo."intervencao" (
  "fkpresmed" bigint PRIMARY KEY NOT NULL,
  "nratendimento" bigint NOT NULL,
  "idmotivointervencao" smallint [] NOT NULL,
  "erro" boolean NULL,
  "dtintervencao" timestamp NOT NULL DEFAULT 'NOW()',
  "interacoes" bigint [] NULL,
  "custo" boolean NULL,
  "observacao" text NULL,
  "status" char(1) NOT NULL DEFAULT '0',
  "update_at" timestamp NOT NULL DEFAULT 'NOW()',
  "update_by" integer NOT NULL
);

CREATE TABLE demo."outlier" (
  "fkmedicamento" bigint NOT NULL,
  "idoutlier" SERIAL PRIMARY KEY NOT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "contagem" integer DEFAULT NULL,
  "doseconv" float DEFAULT NULL,
  "frequenciadia" float DEFAULT NULL,
  "escore" smallint DEFAULT NULL,
  "escoremanual" smallint DEFAULT NULL,
  "update_at" timestamp DEFAULT 'NOW()',
  "update_by" integer
);

CREATE TABLE demo."observacao" (
  "idoutlier" integer DEFAULT 0,
  "fkpresmed" bigint DEFAULT 0,
  "nratendimento" bigint NOT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "fkmedicamento" bigint DEFAULT NULL,
  "doseconv" float DEFAULT NULL,
  "frequenciadia" float DEFAULT NULL,
  "text" text DEFAULT NULL,
  "update_at" timestamp DEFAULT 'NOW()',
  "update_by" integer
);

CREATE TABLE demo."pessoa" (
  "fkhospital" smallint DEFAULT 1,
  "fkpessoa" bigint NOT NULL,
  "nratendimento" bigint UNIQUE NOT NULL,
  "dtnascimento" date DEFAULT NULL,
  "dtinternacao" timestamp NOT NULL,
  "cor" varchar(100) DEFAULT NULL,
  "sexo" char(1) DEFAULT NULL,
  "peso" float DEFAULT NULL,
  "altura" float DEFAULT NULL,
  "dtpeso" timestamp DEFAULT NULL,
  "update_at" timestamp DEFAULT NULL,
  "update_by" integer DEFAULT NULL,
  PRIMARY KEY ("fkpessoa", "nratendimento")
);

CREATE TABLE demo."nome" (
  "fkpessoa" bigint PRIMARY KEY NOT NULL,
  "nome" varchar(255) NOT NULL
);

CREATE TABLE demo."prescricao" (
  "fkhospital" smallint DEFAULT 1,
  "fksetor" integer NOT NULL,
  "fkprescricao" bigint PRIMARY KEY NOT NULL,
  "fkpessoa" bigint NOT NULL,
  "nratendimento" bigint NOT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "dtprescricao" timestamp NOT NULL,
  "status" char(1) DEFAULT '0',
  "peso" float DEFAULT NULL,
  "leito" varchar(16) NULL,
  "prontuario" int8 NULL,
  "crm" varchar(16) NULL,
  "update_at" timestamp DEFAULT 'NOW()',
  "update_by" integer
);

CREATE TABLE demo."prescricaoagg" (
  "fkhospital" smallint DEFAULT 1,
  "fksetor" integer NOT NULL,
  "idsegmento" smallint DEFAULT null,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(16) DEFAULT NULL,
  "fkfrequencia" varchar(16) DEFAULT NULL,
  "dose" float4 DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "idade" smallint DEFAULT NULL,
  "peso" float4 DEFAULT NULL,
  "contagem" integer DEFAULT NULL
);

CREATE TABLE demo."presmed" (
  "fkpresmed" bigserial PRIMARY KEY NOT NULL,
  "fkprescricao" bigint NOT NULL,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(16) DEFAULT NULL,
  "fkfrequencia" varchar(16) DEFAULT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "idoutlier" integer DEFAULT NULL,
  "dose" float4 DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "via" varchar(50) DEFAULT NULL,
  "horario" varchar(600) DEFAULT NULL,
  "complemento" text,
  "quantidade" integer DEFAULT NULL,
  "origem" varchar(13) DEFAULT NULL,
  "dtsuspensao" timestamp DEFAULT NULL,
  "padronizado" char(1) DEFAULT NULL,
  "escorefinal" smallint DEFAULT NULL,
  "slagrupamento" bigint DEFAULT NULL,
  "slacm" varchar(1) DEFAULT NULL,
  "sletapas" bigint DEFAULT NULL,
  "slhorafase" float4 DEFAULT NULL,
  "sltempoaplicacao" bigint DEFAULT NULL,
  "sldosagem" float4 DEFAULT NULL,
  "sltipodosagem" varchar(3) DEFAULT NULL,
  "alergia" char(1) DEFAULT NULL,
  "status" char(1),
  "aprox" boolean,
  "suspenso" boolean,
  "checado" boolean  DEFAULT NULL,
  "periodo" int2  DEFAULT NULL,
  "update_at" timestamp DEFAULT 'NOW()',
  "update_by" integer
);

CREATE TABLE demo."medicamento" (
  "fkhospital" smallint DEFAULT 1,
  "fkmedicamento" bigint PRIMARY KEY NOT NULL,
  "fkunidademedida" varchar(16) DEFAULT NULL,
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
  "dosemaxima" smallint,
  "renal" smallint,
  "hepatico" smallint,
  "idoso" boolean,
  "divisor" float4,
  "usapeso" boolean,
  "concentracao" float4,
  "concentracaounidade" varchar(3),
  "linhabranca" boolean
);

CREATE TABLE demo."motivointervencao" (
  "fkhospital" smallint DEFAULT 1,
  "idmotivointervencao" SERIAL PRIMARY KEY NOT NULL,
  "idmotivomae" int4 NULL,
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
  "fkunidademedida" varchar(16) PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL
);

CREATE TABLE demo."unidadeconverte" (
  "idsegmento" smallint DEFAULT 1,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(15) NOT NULL,
  "fator" float NOT NULL
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
  "update_at" timestamp NOT NULL DEFAULT 'NOW()',
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

CREATE TABLE public."usuario" (
  "idusuario" SERIAL PRIMARY KEY NOT NULL,
  "nome" varchar(255) UNIQUE NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "senha" varchar(255) NOT NULL,
  "schema" varchar(10) NOT NULL,
  "getnameurl" varchar(255) DEFAULT NULL,
  "logourl" varchar(255) DEFAULT NULL,
  "relatorios" json DEFAULT NULL
);

CREATE TABLE demo."prescricaofoto" (
  "fkprescricao" bigint NOT NULL,
  "foto" json NOT NULL
);

CREATE TABLE public."substancia" (
  "sctid" bigint NOT NULL,
  "nome" varchar(255) NOT NULL
);

CREATE TABLE public."relacao" (
  "sctida" bigint NOT NULL,
  "sctidb" bigint NOT NULL,
  "tprelacao" char(2) DEFAULT NULL,
  "texto" text,
  "ativo" boolean,
  "create_by" integer,
  "update_at" timestamp DEFAULT 'NOW()',
  "update_by" integer
);

CREATE UNIQUE INDEX prescricaofoto_fkprescricao_idx ON demo.prescricaofoto (fkprescricao);

CREATE UNIQUE INDEX ON demo."intervencao" ("fkpresmed");
CREATE INDEX ON demo."intervencao" ("nratendimento");

CREATE INDEX ON demo."exame" ("nratendimento", "tpexame");

CREATE UNIQUE INDEX ON demo."outlier" ("fkmedicamento", "idsegmento", "doseconv", "frequenciadia");

CREATE INDEX ON demo."prescricao" ("nratendimento");
CREATE INDEX ON demo."prescricao" ("fksetor");
CREATE INDEX ON demo."prescricao" ("idsegmento");

CREATE UNIQUE INDEX ON demo."prescricaoagg" ("fksetor", "fkmedicamento", "fkunidademedida", "dose", "fkfrequencia", "frequenciadia", "idade", "peso");
CREATE INDEX ON demo."prescricaoagg" ("idsegmento", "fkmedicamento", "doseconv", "frequenciadia");

CREATE INDEX ON demo."presmed" ("fkmedicamento", "idsegmento", "doseconv", "frequenciadia");
CREATE INDEX ON demo."presmed" ("fkprescricao");

CREATE UNIQUE INDEX ON demo."medicamento" ("fkhospital", "fkmedicamento");

CREATE UNIQUE INDEX ON demo."medatributos" ("fkmedicamento", "idsegmento");

CREATE UNIQUE INDEX ON demo."frequencia" ("fkhospital", "fkfrequencia");

CREATE UNIQUE INDEX ON demo."unidademedida" ("fkhospital", "fkunidademedida");

CREATE UNIQUE INDEX ON demo."unidadeconverte" ("fkmedicamento", "fkunidademedida");

CREATE UNIQUE INDEX ON demo."segmentosetor" ("fkhospital", "fksetor");

CREATE UNIQUE INDEX ON demo."setor" ("fkhospital", "fksetor");

CREATE INDEX ON demo."presmed" ("update_by");
CREATE INDEX ON demo."prescricao" ("update_by");

CREATE UNIQUE INDEX ON demo."observacao" ("idoutlier", "fkpresmed");
CREATE INDEX ON demo."observacao" ("nratendimento","fkmedicamento");

CREATE UNIQUE INDEX ON public."substancia" ("sctid");
CREATE UNIQUE INDEX ON public."relacao" ("sctida", "sctidb","tprelacao");