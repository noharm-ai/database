DROP SCHEMA IF EXISTS demo CASCADE;
DROP TABLE IF EXISTS public.usuario;
CREATE SCHEMA demo;
CREATE USER demo;
GRANT ALL ON SCHEMA demo TO postgres;
GRANT ALL ON SCHEMA demo TO demo;


CREATE TABLE demo."exame" (
  "fkexame" bigint NOT NULL,
  "fkpessoa" bigint NOT NULL,
  "nratendimento" bigint NOT NULL,
  "dtexame" timestamp NOT NULL,
  "tpexame" varchar(100) NOT NULL,
  "resultado" float NOT NULL,
  "unidade" varchar(250) DEFAULT NULL
);

CREATE TABLE demo."intervencao" (
  "idintervencao" SERIAL PRIMARY KEY NOT NULL,
  "fkpresmed" bigint NOT NULL,
  "idusuario" smallint NOT NULL,
  "idmotivointervencao" smallint NOT NULL,
  "dtintervencao" timestamp NOT NULL DEFAULT 'now()',
  "boolpropaga" char(1) NOT NULL DEFAULT 'n',
  "observacao" text
);

CREATE TABLE demo."outlier" (
  "fkmedicamento" integer NOT NULL,
  "idoutlier" SERIAL PRIMARY KEY NOT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "contagem" integer DEFAULT NULL,
  "doseconv" float DEFAULT NULL,
  "frequenciadia" float DEFAULT NULL,
  "escore" smallint DEFAULT NULL,
  "escoremanual" smallint DEFAULT NULL,
  "idusuario" smallint DEFAULT NULL
);

CREATE TABLE demo."pessoa" (
  "fkhospital" smallint DEFAULT 1,
  "fkpessoa" bigint PRIMARY KEY NOT NULL,
  "nratendimento" bigint UNIQUE NOT NULL,
  "dtnascimento" date NOT NULL,
  "dtinternacao" timestamp NOT NULL,
  "cor" varchar(100) DEFAULT NULL,
  "sexo" char(1) DEFAULT NULL,
  "peso" float DEFAULT NULL
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
  "update_at" timestamp NULL DEFAULT NOW()
);

CREATE TABLE demo."prescricaoagg" (
  "fkhospital" smallint DEFAULT 1,
  "fksetor" integer NOT NULL,
  "idsegmento" smallint NOT NULL,
  "fkmedicamento" bigint NOT NULL,
  "fkunidademedida" varchar(16) DEFAULT NULL,
  "fkfrequencia" varchar(16) DEFAULT NULL,
  "dose" float DEFAULT NULL,
  "doseconv" float DEFAULT NULL,
  "peso" float DEFAULT NULL,
  "idade" smallint DEFAULT NULL,
  "frequenciadia" float DEFAULT NULL,
  "contagem" integer DEFAULT NULL
);

CREATE TABLE demo."presmed" (
  "fkpresmed" SERIAL PRIMARY KEY NOT NULL,
  "fkprescricao" bigint NOT NULL,
  "fkmedicamento" integer NOT NULL,
  "fkunidademedida" varchar(16) DEFAULT NULL,
  "fkfrequencia" varchar(16) DEFAULT NULL,
  "idsegmento" smallint DEFAULT NULL,
  "idoutlier" integer DEFAULT NULL,
  "dose" float DEFAULT NULL,
  "doseconv" float DEFAULT NULL,
  "frequenciadia" float DEFAULT NULL,
  "via" varchar(50) DEFAULT NULL,
  "complemento" text,
  "quantidade" integer DEFAULT NULL,
  "escorefinal" smallint DEFAULT NULL
);

CREATE TABLE demo."medicamento" (
  "fkhospital" smallint DEFAULT 1,
  "fkmedicamento" bigint PRIMARY KEY NOT NULL,
  "fkunidademedida" varchar(16) DEFAULT NULL,
  "nome" varchar(250) NOT NULL,
  "antimicro" boolean NULL,
  "mav" boolean NULL,
  "controlados" boolean NULL

);

CREATE TABLE demo."motivointervencao" (
  "fkhospital" smallint DEFAULT 1,
  "idmotivointervencao" SERIAL PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL,
  "tipo" varchar(50) NOT NULL
);

CREATE TABLE demo."frequencia" (
  "fkhospital" smallint DEFAULT 1,
  "fkfrequencia" varchar(16) PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL,
  "frequenciadia" float DEFAULT NULL,
  "frequenciahora" float DEFAULT NULL
);

CREATE TABLE demo."unidademedida" (
  "fkhospital" smallint DEFAULT 1,
  "fkunidademedida" varchar(16) PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL
);

CREATE TABLE demo."unidadeconverte" (
  "fkhospital" smallint DEFAULT 1,
  "fkunidademedida" varchar(16) NOT NULL,
  "fkmedicamento" bigint NOT NULL,
  "fator" float NOT NULL
);

CREATE TABLE demo."segmento" (
  "idsegmento" SERIAL PRIMARY KEY NOT NULL,
  "nome" varchar(250) NOT NULL,
  "idade_min" smallint DEFAULT NULL,
  "idade_max" smallint DEFAULT NULL,
  "peso_min" smallint DEFAULT NULL,
  "peso_max" smallint DEFAULT NULL,
  "status" smallint DEFAULT NULL
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
  "fksetor" smallint PRIMARY KEY NOT NULL,
  "nome" varchar(255) NOT NULL
);

CREATE TABLE public."usuario" (
  "idusuario" SERIAL PRIMARY KEY NOT NULL,
  "nome" varchar(255) UNIQUE NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "senha" varchar(255) NOT NULL,
  "schema" varchar(16) NOT NULL,
  "getnameurl" varchar(255) DEFAULT NULL,
  "logourl" varchar(255) DEFAULT NULL
);

ALTER TABLE demo."intervencao" ADD FOREIGN KEY ("fkpresmed") REFERENCES demo."presmed" ("fkpresmed");

ALTER TABLE demo."intervencao" ADD FOREIGN KEY ("idmotivointervencao") REFERENCES demo."motivointervencao" ("idmotivointervencao");

CREATE INDEX ON demo."exame" ("fkpessoa", "nratendimento");

CREATE UNIQUE INDEX ON demo."outlier" ("fkmedicamento", "idsegmento", "doseconv", "frequenciadia");

CREATE UNIQUE INDEX ON demo."prescricao" ("fksetor", "fkprescricao");

CREATE UNIQUE INDEX ON demo."prescricaoagg" (fksetor, fkmedicamento, fkunidademedida, dose, fkfrequencia, frequenciadia, idade, peso);

CREATE UNIQUE INDEX ON demo."presmed" ("fkprescricao", "fkmedicamento", "doseconv", "fkfrequencia");

CREATE UNIQUE INDEX ON demo."medicamento" ("fkhospital", "fkmedicamento");

CREATE UNIQUE INDEX ON demo."frequencia" ("fkhospital", "fkfrequencia");

CREATE UNIQUE INDEX ON demo."unidademedida" ("fkhospital", "fkunidademedida");

CREATE UNIQUE INDEX ON demo."unidadeconverte" ("fkmedicamento", "fkunidademedida");

CREATE UNIQUE INDEX ON demo."setor" ("fkhospital", "fksetor");

CREATE INDEX presmed_fkprescricao_idx ON demo.presmed (fkprescricao);
