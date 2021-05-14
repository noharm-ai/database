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

CREATE INDEX demo_evolucao_nratendimento_idx ON demo."evolucao" ("nratendimento");
CREATE INDEX demo_evolucao_dtevolucao_idx ON demo."evolucao" USING brin ("dtevolucao") with (pages_per_range = 32);

GRANT SELECT, UPDATE ON demo.evolucao TO api_user;
GRANT SELECT, INSERT, UPDATE ON demo.evolucao TO onlydemo;