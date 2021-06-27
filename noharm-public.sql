CREATE TABLE public."usuario" (
  "idusuario" SERIAL PRIMARY KEY NOT NULL,
  "nome" varchar(255) UNIQUE NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "senha" varchar(255) NOT NULL,
  "schema" varchar(25) NOT NULL,
  "fkusuario" integer DEFAULT NULL,
  "config" json DEFAULT NULL
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
  "update_at" timestamp DEFAULT NOW(),
  "update_by" integer
);

CREATE UNIQUE INDEX ON public."substancia" ("sctid");
CREATE UNIQUE INDEX ON public."relacao" ("sctida", "sctidb","tprelacao");