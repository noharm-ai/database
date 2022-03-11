CREATE TABLE public."usuario" (
  "idusuario" SERIAL PRIMARY KEY NOT NULL,
  "nome" varchar(255) NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "senha" varchar(255) NOT NULL,
  "schema" varchar(25) NOT NULL,
  "fkusuario" varchar(50) DEFAULT NULL,
  "config" json DEFAULT NULL,
  "ativo" bool NOT NULL DEFAULT true
);

CREATE TABLE public."substancia" (
  "sctid" bigint NOT NULL,
  "nome" varchar(255) NOT NULL,
  "link" varchar(255) DEFAULT NULL
);

CREATE TABLE public."notifica" (
  "idnotifica" SERIAL PRIMARY KEY NOT NULL,
  "titulo" varchar(100) NOT NULL,
  "tooltip" varchar(255) NOT NULL,
  "link" varchar(100) NOT NULL,
  "icon" varchar(25) NOT NULL,
  "classname"  varchar(50) NOT NULL,
  "inicio" date NOT NULL,
  "validade" date NOT NULL,
  "schema" varchar(25) NULL
);

CREATE TABLE public."relacao" (
  "sctida" bigint NOT NULL,
  "sctidb" bigint NOT NULL,
  "tprelacao" char(2) DEFAULT NULL,
  "texto" text,
  "ativo" boolean,
  "create_by" integer,
  "update_at" timestamp DEFAULT NOW(),
  "update_by" integer
);

CREATE UNIQUE INDEX ON public."substancia" ("sctid");
CREATE UNIQUE INDEX ON public."relacao" ("sctida", "sctidb","tprelacao");
