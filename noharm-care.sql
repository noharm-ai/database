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
  "evolucao" boolean NULL,
  "update_at" timestamp NULL,
  "update_by" integer NULL,
  "review_at" timestamp NULL,
  "review_by" integer NULL
);

CREATE INDEX demo_evolucao_nratendimento_idx ON demo."evolucao" ("nratendimento");
CREATE INDEX demo_evolucao_dtevolucao_idx ON demo."evolucao" USING brin ("dtevolucao") with (pages_per_range = 32);

GRANT SELECT, UPDATE ON demo.evolucao TO api_user;
GRANT SELECT, INSERT, UPDATE ON demo.evolucao TO onlydemo;

CREATE OR REPLACE FUNCTION demo.insert_update_evolucao()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
 TEST_EXISTS integer;
BEGIN

   TEST_EXISTS := (
           SELECT fkevolucao FROM demo.evolucao e
				   WHERE fkevolucao = NEW.fkevolucao 
				   LIMIT 1
   );

   IF TEST_EXISTS IS NULL THEN
      RETURN NEW;
   ELSE
      RETURN NULL;
   END IF;   
END;$BODY$;

ALTER FUNCTION demo.insert_update_evolucao()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_insert_update_evolucao ON demo.evolucao;
		     
CREATE TRIGGER trg_insert_update_evolucao
    BEFORE INSERT 
    ON demo.evolucao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.insert_update_evolucao();