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
  "link" varchar(255) DEFAULT NULL,
  "idclasse" varchar(10) NULL,
  "ativo" boolean DEFAULT true
);

CREATE TABLE public."notifica" (
  "idnotifica" SERIAL PRIMARY KEY NOT NULL,
  "titulo" varchar(100) NOT NULL,
  "tooltip" varchar(255) NOT NULL,
  "link" varchar(100) NOT NULL,
  "icon" varchar(25) NOT NULL,
  "classname" varchar(50) NOT NULL,
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

CREATE TABLE public.bulletin (
  idbulletin serial4 NOT NULL,
  "schema" varchar(50) NULL,
  category text NULL,
  groupid text NULL,
  id text NULL,
  "level" text NULL,
  message text NULL,
  sourcename text NULL,
  sourceid text NULL,
  "timestamp" text NULL,
  created_at timestamptz NULL DEFAULT now(),
  CONSTRAINT bulletin_pkey PRIMARY KEY (idbulletin)
);

CREATE TABLE public.classe (
  idclasse varchar(10) NOT NULL,
  idclassemae varchar(10) NULL,
  nome varchar(250) NOT NULL,
  CONSTRAINT classe_pkey PRIMARY KEY (idclasse)
);

CREATE TABLE public.schema_config (
	schema_name varchar(200) NOT NULL,
	updated_at timestamp NULL,
	created_at timestamp NOT NULL,
	fl1_atualiza_indicadores_cpoe bool NOT NULL DEFAULT false,
	fl2_atualiza_indicadores_prescricao bool NOT NULL DEFAULT false,
	fl3_atualiza_prescricaoagg bool NOT NULL DEFAULT false,
	fl3_segmentos _int4 NULL,
	fl4_cria_conciliacao bool NOT NULL DEFAULT false,
	configuracao jsonb NULL,
	tp_noharm_care int2 NOT NULL DEFAULT 2,
	status int4 NOT NULL DEFAULT 0,
	updated_by int4 NULL,
	CONSTRAINT schema_config_pkey PRIMARY KEY (schema_name)
);

CREATE TABLE public."memoria" (
  "idmemoria" SERIAL NOT NULL,
  "tipo" varchar(100) NOT NULL,
  "valor" json NOT NULL,
  "update_at" timestamp NOT NULL DEFAULT NOW(),
  "update_by" integer NOT NULL,
  PRIMARY KEY ("idmemoria", "tipo")
);

CREATE UNIQUE INDEX ON public."substancia" ("sctid");

CREATE UNIQUE INDEX ON public."relacao" ("sctida", "sctidb", "tprelacao");