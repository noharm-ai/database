CREATE SCHEMA demo;

GRANT ALL ON SCHEMA demo TO postgres;

CREATE TABLE demo."exame" (
  "fkexame" BIGINT NOT NULL,
  "fkpessoa" BIGINT NOT NULL,
  "nratendimento" BIGINT DEFAULT NULL,
  "fkprescricao" BIGINT DEFAULT NULL,
  "dtexame" TIMESTAMP NOT NULL,
  "tpexame" VARCHAR(100) NOT NULL,
  "resultado" float4 DEFAULT NULL,
  "unidade" VARCHAR(250) DEFAULT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "created_by" int4 DEFAULT NULL
);

CREATE TABLE demo."cultura_cabecalho" (
  "idculturacab" serial4 NOT NULL,
  "fkpessoa" BIGINT NOT NULL,
  "fksetor" int4 NULL,
  "nratendimento" BIGINT DEFAULT NULL,
  "fkexame" BIGINT NOT NULL,
  "fkitemexame" BIGINT NOT NULL,
  "nomeexame" VARCHAR(250) NULL,
  "nomematerial" VARCHAR(250) NULL,
  "nomematerialtipo" VARCHAR(250) NULL,
  "dtpedido" TIMESTAMP NULL,
  "dtcoleta" TIMESTAMP NULL,
  "dtliberacao" TIMESTAMP NULL,
  "gram" VARCHAR(250) DEFAULT NULL,
  "dscolonia" VARCHAR(250) DEFAULT NULL,
  "nrcolonia" BIGINT DEFAULT NULL,
  "resultprevio" VARCHAR(250) DEFAULT NULL,
  "complemento" TEXT DEFAULT NULL,
  "predict" BOOLEAN NULL
);

CREATE TABLE demo.cultura (
  "idcultura" serial4 NOT NULL,
  "fkexame" BIGINT NOT NULL,
  "fkitemexame" BIGINT NOT NULL,
  "fkmedicamento" int8 NULL,
  "nomemedicamento" VARCHAR(250) NULL DEFAULT NULL :: CHARACTER VARYING,
  "fkmicroorganismo" int8 NULL,
  "nomemicroorganismo" VARCHAR(250) NULL DEFAULT NULL :: CHARACTER VARYING,
  "qtmicroorganismo" VARCHAR(250) NULL,
  "resultado" VARCHAR(250) NULL DEFAULT NULL :: CHARACTER VARYING,
  "predict" bpchar(1) NULL,
  "predict_proba" float4 NULL,
  "medicamento_proba" float4 NULL
);

CREATE TABLE demo."intervencao" (
  "idintervencao" serial NOT NULL,
  "fkpresmed" BIGINT DEFAULT 0,
  "fkprescricao" BIGINT DEFAULT 0,
  "nratendimento" BIGINT NOT NULL,
  "fksetor" INTEGER DEFAULT NULL,
  "idmotivointervencao" SMALLINT [ ] NULL,
  "erro" BOOLEAN NULL,
  "dtintervencao" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "interacoes" BIGINT [ ] NULL,
  "custo" BOOLEAN NULL,
  "observacao" TEXT NULL,
  "status" CHAR(1) NOT NULL DEFAULT '0',
  "transcricao" json DEFAULT NULL,
  "dias_economia" SMALLINT DEFAULT NULL,
  "dose_despendida" float4 DEFAULT NULL,
  "tp_economia" SMALLINT NULL,
  "vl_economia_dia" float4 NULL,
  "vl_economia_dia_manual" BOOLEAN NOT NULL DEFAULT FALSE,
  "fkpresmed_destino" int8 NULL,
  "origem" jsonb NULL,
  "destino" jsonb NULL,
  "dt_base_economia" TIMESTAMP NULL,
  "dt_fim_economia" TIMESTAMP NULL,
  "ram" jsonb NULL,
  "periodo_uso" int4 NULL,
  "update_at" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "update_by" INTEGER NOT NULL,
  "outcome_at" TIMESTAMP NULL,
  "outcome_by" INTEGER NULL
);

CREATE TABLE demo."outlier" (
  "fkmedicamento" BIGINT NOT NULL,
  "idoutlier" SERIAL PRIMARY KEY NOT NULL,
  "idsegmento" SMALLINT DEFAULT NULL,
  "contagem" INTEGER DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "escore" SMALLINT DEFAULT NULL,
  "escoremanual" SMALLINT DEFAULT NULL,
  "update_at" TIMESTAMP DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "update_by" INTEGER
);

CREATE TABLE demo."observacao" (
  "idoutlier" INTEGER DEFAULT 0,
  "fkpresmed" BIGINT DEFAULT 0,
  "nratendimento" BIGINT DEFAULT NULL,
  "idsegmento" SMALLINT DEFAULT NULL,
  "fkmedicamento" BIGINT DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "text" TEXT DEFAULT NULL,
  "update_at" TIMESTAMP DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "update_by" INTEGER
);

CREATE TABLE demo."pessoa" (
  "fkhospital" SMALLINT DEFAULT 1,
  "fkpessoa" BIGINT NOT NULL,
  "nratendimento" BIGINT UNIQUE NOT NULL,
  "nratendimentoref" BIGINT DEFAULT NULL,
  "dtnascimento" date DEFAULT NULL,
  "dtinternacao" TIMESTAMP NOT NULL,
  "dtalta" TIMESTAMP DEFAULT NULL,
  "motivoalta" VARCHAR(100) DEFAULT NULL,
  "cor" VARCHAR(100) DEFAULT NULL,
  "sexo" CHAR(1) DEFAULT NULL,
  "peso" float4 DEFAULT NULL,
  "altura" float4 DEFAULT NULL,
  "dtpeso" TIMESTAMP DEFAULT NULL,
  "anotacao" TEXT DEFAULT NULL,
  "alertadata" TIMESTAMP DEFAULT NULL,
  "alertatexto" TEXT DEFAULT NULL,
  "alertavigencia" TIMESTAMP DEFAULT NULL,
  "alerta_by" INTEGER DEFAULT NULL,
  "dialise" CHAR(1) DEFAULT NULL,
  "lactante" BOOLEAN DEFAULT NULL,
  "gestante" BOOLEAN DEFAULT NULL,
  "st_concilia" SMALLINT DEFAULT 0,
  "marcadores" _varchar DEFAULT NULL,
  "medico_responsavel" VARCHAR(255) NULL,
  "dt_alta_prevista" TIMESTAMP DEFAULT NULL,
  "idcid" VARCHAR(50) DEFAULT NULL,
  "fksetor" int4 DEFAULT NULL,
  "leito" VARCHAR(32) DEFAULT NULL,
  "dt_ultima_transferencia" TIMESTAMP DEFAULT NULL,
  "cidade" VARCHAR(250) DEFAULT NULL,
  "update_at" TIMESTAMP DEFAULT NULL,
  "update_by" INTEGER DEFAULT NULL,
  PRIMARY KEY ("nratendimento")
);

CREATE TABLE demo."prescricao" (
  "fkhospital" SMALLINT DEFAULT 1,
  "fksetor" INTEGER NOT NULL,
  "fkprescricao" BIGINT PRIMARY KEY NOT NULL,
  "fkpessoa" BIGINT NOT NULL,
  "nratendimento" BIGINT NOT NULL,
  "nratendimentoref" BIGINT DEFAULT NULL,
  "idsegmento" SMALLINT DEFAULT NULL,
  "dtprescricao" TIMESTAMP NOT NULL,
  "dtvigencia" TIMESTAMP NULL,
  "dtatualizacao" TIMESTAMP NULL,
  "status" CHAR(1) DEFAULT '0',
  "leito" VARCHAR(16) NULL,
  "prontuario" int8 NULL,
  "prescritor" VARCHAR(255) NULL,
  "especialidade" VARCHAR(100) NULL,
  "indicadores" json DEFAULT NULL,
  "evolucao" TEXT DEFAULT NULL,
  "evolucao_at" TIMESTAMP DEFAULT NULL,
  "agregada" BOOLEAN DEFAULT NULL,
  "aggsetor" INTEGER [ ] NULL,
  "aggmedicamento" BIGINT [ ] NULL,
  "concilia" CHAR(1) DEFAULT NULL,
  "convenio" VARCHAR(100) NULL,
  "tp_revisao" SMALLINT DEFAULT 0,
  "update_at" TIMESTAMP DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "update_by" INTEGER,
  "dtcriacao_origem" TIMESTAMP DEFAULT NULL,
  "dtimpressao" TIMESTAMP DEFAULT NULL,
  "idtipoevolucao" VARCHAR(50) NULL
);

CREATE TABLE demo."prescricao_evolucao" (
  "idprescricao_evolucao" serial8 NOT NULL,
  "fkprescricao" BIGINT NOT NULL,
  "texto" TEXT NOT NULL,
  "idtipoevolucao" VARCHAR(50) NULL,
  "concilia" CHAR(1) DEFAULT NULL,
  "tp_status" SMALLINT NOT NULL,
  "desc_erro_integracao" VARCHAR(255) NULL,
  "updated_at" TIMESTAMP NULL,
  "updated_by" INTEGER NULL,
  "created_at" TIMESTAMP NOT NULL,
  "created_by" INTEGER NOT NULL,
  "sent_at" TIMESTAMP NULL
);

CREATE TABLE demo."prescricao_audit" (
  "idprescricao_audit" serial8 NOT NULL,
  "tp_audit" SMALLINT NOT NULL,
  "nratendimento" BIGINT NOT NULL,
  "fkprescricao" BIGINT NOT NULL,
  "dtprescricao" TIMESTAMP NOT NULL,
  "fksetor" INTEGER NOT NULL,
  "total_itens" INTEGER NOT NULL,
  "agregada" BOOLEAN,
  "concilia" CHAR(1),
  "idsegmento" SMALLINT,
  "leito" VARCHAR(16),
  "extra" json,
  "created_at" TIMESTAMP NOT NULL,
  "created_by" INTEGER NOT NULL
);

CREATE TABLE demo."prescricaoagg" (
  "fkhospital" SMALLINT DEFAULT 1,
  "fksetor" INTEGER NOT NULL,
  "idsegmento" SMALLINT DEFAULT NULL,
  "fkmedicamento" BIGINT NOT NULL,
  "fkunidademedida" VARCHAR(32) DEFAULT NULL,
  "fkfrequencia" VARCHAR(64) DEFAULT NULL,
  "dose" float4 DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "peso" float4 DEFAULT NULL,
  "contagem" INTEGER DEFAULT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "updated_at" TIMESTAMP NULL
);

CREATE TABLE demo."presmed" (
  "fkpresmed" bigserial PRIMARY KEY NOT NULL,
  "fkprescricao" BIGINT NOT NULL,
  "fkmedicamento" BIGINT NOT NULL,
  "fkunidademedida" VARCHAR(32) DEFAULT NULL,
  "fkfrequencia" VARCHAR(64) DEFAULT NULL,
  "idsegmento" SMALLINT DEFAULT NULL,
  "idoutlier" INTEGER DEFAULT NULL,
  "dose" float4 DEFAULT NULL,
  "doseconv" float4 DEFAULT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "via" VARCHAR(50) DEFAULT NULL,
  "sonda" BOOLEAN DEFAULT NULL,
  "intravenosa" BOOLEAN DEFAULT NULL,
  "horario" VARCHAR(600) DEFAULT NULL,
  "complemento" TEXT,
  "origem" VARCHAR(13) DEFAULT NULL,
  "dtsuspensao" TIMESTAMP DEFAULT NULL,
  "escorefinal" SMALLINT DEFAULT NULL,
  "slagrupamento" BIGINT DEFAULT NULL,
  "slacm" VARCHAR(1) DEFAULT NULL,
  "sletapas" BIGINT DEFAULT NULL,
  "slhorafase" float4 DEFAULT NULL,
  "sltempoaplicacao" float4 DEFAULT NULL,
  "sldosagem" float4 DEFAULT NULL,
  "sltipodosagem" VARCHAR(16) DEFAULT NULL,
  "alergia" CHAR(1) DEFAULT NULL,
  "status" CHAR(1),
  "aprox" BOOLEAN,
  "suspenso" BOOLEAN,
  "checado" BOOLEAN DEFAULT NULL,
  "periodo" int2 DEFAULT NULL,
  "periodo_total" int2 DEFAULT NULL,
  "tp_periodo" int2 DEFAULT NULL,
  "update_at" TIMESTAMP DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "update_by" INTEGER,
  "cpoe_grupo" BIGINT NULL,
  "cpoe_nrseq" BIGINT NULL,
  "cpoe_nrseq_anterior" BIGINT NULL,
  "form" json NULL,
  "aprazamento" TIMESTAMP [ ] [ ] NULL,
  "nr_ordem" int4 NULL
);

CREATE TABLE demo."presmed_audit" (
  "idpresmed_audit" serial8 NOT NULL,
  "tp_audit" SMALLINT NOT NULL,
  "fkpresmed" BIGINT NOT NULL,
  "extra" json,
  "created_at" TIMESTAMP NOT NULL,
  "created_by" INTEGER NOT NULL
);

CREATE TABLE demo."medicamento" (
  "fkhospital" SMALLINT DEFAULT 1,
  "fkmedicamento" BIGINT NOT NULL,
  "nome" VARCHAR(250) NOT NULL,
  "sctid" BIGINT DEFAULT NULL,
  "ia_acuracia" float4 NULL,
  "origem" VARCHAR(13) DEFAULT NULL,
  "created_by" int4 NULL,
  "updated_by" int4 NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "updated_at" TIMESTAMP NULL,
  PRIMARY KEY ("fkmedicamento")
);

CREATE TABLE demo."medatributos" (
  "fkmedicamento" BIGINT NOT NULL,
  "idsegmento" SMALLINT NOT NULL,
  "antimicro" BOOLEAN,
  "mav" BOOLEAN,
  "controlados" BOOLEAN,
  "naopadronizado" BOOLEAN,
  "dosemaxima" float4,
  "renal" SMALLINT,
  "hepatico" SMALLINT,
  "plaquetas" INTEGER,
  "idoso" BOOLEAN,
  "sonda" BOOLEAN,
  "quimio" BOOLEAN,
  "divisor" float4,
  "usapeso" BOOLEAN,
  "concentracao" float4,
  "concentracaounidade" VARCHAR(3),
  "linhabranca" BOOLEAN,
  "fkunidademedida" VARCHAR(32),
  "fkunidademedidacusto" VARCHAR(32),
  "custo" float4,
  "tempotratamento" SMALLINT,
  "risco_queda" SMALLINT,
  "dialisavel" BOOLEAN,
  "lactante" VARCHAR(1),
  "gestante" VARCHAR(1),
  "jejum" BOOLEAN,
  "ref_dosemaxima" float4,
  "ref_dosemaxima_peso" float4,
  "update_at" TIMESTAMP DEFAULT NULL,
  "update_by" INTEGER DEFAULT NULL
);

CREATE TABLE demo."motivointervencao" (
  "fkhospital" SMALLINT DEFAULT 1,
  "idmotivointervencao" SERIAL PRIMARY KEY NOT NULL,
  "idmotivomae" int4 NULL,
  "ativo" bool NOT NULL DEFAULT TRUE,
  "nome" VARCHAR(250) NOT NULL,
  "suspensao" bool NOT NULL DEFAULT FALSE,
  "substituicao" bool NOT NULL DEFAULT FALSE,
  "economia_customizada" bool NOT NULL DEFAULT FALSE,
  "bloqueante" bool NOT NULL DEFAULT FALSE,
  "tp_relacao" SMALLINT NOT NULL DEFAULT 0,
  "ram" bool NOT NULL DEFAULT FALSE
);

CREATE TABLE demo."frequencia" (
  "fkhospital" SMALLINT DEFAULT 1,
  "fkfrequencia" VARCHAR(64) NOT NULL,
  "nome" VARCHAR(250) NOT NULL,
  "frequenciadia" float4 DEFAULT NULL,
  "frequenciahora" float4 DEFAULT NULL,
  "jejum" bool DEFAULT FALSE,
  PRIMARY KEY ("fkhospital", "fkfrequencia")
);

CREATE TABLE demo."unidademedida" (
  "fkhospital" SMALLINT DEFAULT 1,
  "fkunidademedida" VARCHAR(32) NOT NULL,
  "nome" VARCHAR(250) NOT NULL,
  "unidademedida_nh" VARCHAR(32),
  PRIMARY KEY ("fkhospital", "fkunidademedida")
);

CREATE TABLE demo."unidadeconverte" (
  "idsegmento" SMALLINT DEFAULT 1,
  "fkmedicamento" BIGINT NOT NULL,
  "fkunidademedida" VARCHAR(32) NOT NULL,
  "fator" float4 NOT NULL
);

CREATE TABLE demo."segmento" (
  "idsegmento" SERIAL PRIMARY KEY NOT NULL,
  "nome" VARCHAR(250) NOT NULL,
  "status" SMALLINT DEFAULT NULL,
  "tp_segmento" SMALLINT,
  "cpoe" BOOLEAN NOT NULL DEFAULT FALSE,
  "cpoe_ambulatorio" BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE demo."segmentoexame" (
  "idsegmento" SMALLINT NOT NULL,
  "tpexame" VARCHAR(100) NOT NULL,
  "abrev" VARCHAR(50),
  "nome" VARCHAR(250),
  "min" float4,
  "max" float4,
  "referencia" VARCHAR(250),
  "posicao" SMALLINT,
  "ativo" BOOLEAN,
  "tpexame_ref" VARCHAR(100),
  "update_at" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "update_by" INTEGER NOT NULL,
  PRIMARY KEY ("idsegmento", "tpexame")
);

CREATE TABLE demo."segmentosetor" (
  "idsegmento" SMALLINT NOT NULL,
  "fkhospital" SMALLINT NOT NULL,
  "fksetor" INTEGER NOT NULL
);

CREATE TABLE demo."hospital" (
  "fkhospital" SMALLINT UNIQUE PRIMARY KEY NOT NULL,
  "nome" VARCHAR(255) NOT NULL
);

CREATE TABLE demo."setor" (
  "fkhospital" SMALLINT DEFAULT 1,
  "fksetor" INTEGER NOT NULL,
  "nome" VARCHAR(255) NOT NULL,
  PRIMARY KEY ("fkhospital", "fksetor")
);

CREATE TABLE demo."memoria" (
  "idmemoria" SERIAL NOT NULL,
  "tipo" VARCHAR(100) NOT NULL,
  "valor" json NOT NULL,
  "update_at" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "update_by" INTEGER NOT NULL,
  PRIMARY KEY ("idmemoria", "tipo")
);

CREATE TABLE demo."evolucao" (
  "fkevolucao" BIGINT PRIMARY KEY NOT NULL,
  "nratendimento" BIGINT NOT NULL,
  "dtevolucao" TIMESTAMP NOT NULL,
  "texto" TEXT DEFAULT NULL,
  "prescritor" VARCHAR(255) NULL,
  "cargo" VARCHAR(255) NULL,
  "complicacoes" SMALLINT NULL,
  "sintomas" SMALLINT NULL,
  "doencas" SMALLINT NULL,
  "medicamentos" SMALLINT NULL,
  "dados" SMALLINT NULL,
  "conduta" SMALLINT NULL,
  "sinais" SMALLINT NULL,
  "alergia" SMALLINT NULL,
  "dialise" SMALLINT NULL,
  "nomes" SMALLINT NULL,
  "sinaistexto" VARCHAR(255) NULL,
  "dadostexto" VARCHAR(255) NULL,
  "complicacoestexto" VARCHAR(255) NULL,
  "doencastexto" VARCHAR(255) NULL,
  "sintomastexto" VARCHAR(255) NULL,
  "alergiatexto" VARCHAR(255) NULL,
  "dialisetexto" VARCHAR(255) NULL,
  "germetexto" VARCHAR(255) NULL,
  "processed" SMALLINT NULL,
  "total" SMALLINT NULL,
  "exame" BOOLEAN NULL,
  "update_at" TIMESTAMP NULL,
  "update_by" INTEGER NULL,
  "review_at" TIMESTAMP NULL,
  "review_by" INTEGER NULL,
  "anotacoes" jsonb NULL,
  "formulario" jsonb NULL,
  "template" jsonb NULL,
  "sumario" jsonb NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT)
);

CREATE TABLE demo.checkedindex (
  "nratendimento" BIGINT NOT NULL,
  "fkmedicamento" BIGINT NOT NULL,
  "doseconv" float4 DEFAULT 0,
  "frequenciadia" float4 DEFAULT 0,
  "sletapas" BIGINT DEFAULT 0,
  "slhorafase" float4 DEFAULT 0,
  "sltempoaplicacao" float4 DEFAULT 0,
  "sldosagem" float4 DEFAULT 0,
  "dtprescricao" TIMESTAMP NOT NULL,
  "via" VARCHAR(50) DEFAULT NULL,
  "horario" VARCHAR(50) DEFAULT NULL,
  "dose" float4 DEFAULT 0,
  "complemento" VARCHAR(50) DEFAULT NULL,
  "fkprescricao" int8 DEFAULT NULL,
  "created_at" TIMESTAMP DEFAULT NULL,
  "created_by" int4 DEFAULT NULL
);

CREATE TABLE demo."alergia" (
  "fkpessoa" BIGINT NOT NULL,
  "fkmedicamento" BIGINT DEFAULT NULL,
  "nome_medicamento" VARCHAR(250) DEFAULT NULL,
  "ativo" BOOLEAN DEFAULT TRUE,
  "created_at" TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "created_by" INTEGER NOT NULL,
  "updated_at" TIMESTAMP DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT),
  "updated_by" INTEGER DEFAULT 0
);

CREATE TABLE demo."nifi_queue" (
  "idqueue" serial4 PRIMARY KEY NOT NULL,
  "url" VARCHAR(300) NOT NULL,
  "method" VARCHAR(100) NOT NULL,
  "body" jsonb NULL,
  "run_status" bool DEFAULT FALSE NOT NULL,
  "response_code" int4 NULL,
  "response" jsonb NULL,
  "extra" jsonb NULL,
  "create_at" TIMESTAMP DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT) NOT NULL,
  "created_by" int4 NULL,
  "response_at" TIMESTAMP NULL
);

CREATE TABLE demo."evolucao_audit"(
  idevolucao_audit bigserial NOT NULL,
  tp_audit int2 NOT NULL,
  fkevolucao int8 NOT NULL,
  extra json NULL,
  created_at TIMESTAMP NOT NULL,
  created_by int4 NOT NULL
);

CREATE TABLE demo."intervencao_audit" (
  idintervencao_audit bigserial NOT NULL,
  tp_audit int2 NOT NULL,
  idintervencao int8 NOT NULL,
  extra json NULL,
  created_at TIMESTAMP NOT NULL,
  created_by int4 NOT NULL
);

CREATE TABLE demo."medatributos_audit" (
  idmedatributos_audit bigserial NOT NULL,
  tp_audit int2 NOT NULL,
  fkmedicamento int8 NOT NULL,
  idsegmento int4 NOT NULL,
  extra json NULL,
  created_at TIMESTAMP NOT NULL,
  created_by int4 NOT NULL
);

CREATE TABLE demo."pessoa_audit" (
  idpessoa_audit bigserial NOT NULL,
  tp_audit int2 NOT NULL,
  nratendimento BIGINT NOT NULL,
  extra json NULL,
  created_at TIMESTAMP NOT NULL,
  created_by int4 NOT NULL
);

CREATE TABLE demo."marcador" (
  "nome" VARCHAR(50) NOT NULL,
  "tp_marcador" SMALLINT NOT NULL,
  "ativo" BOOLEAN NOT NULL,
  "updated_at" TIMESTAMP NULL,
  "updated_by" INTEGER NULL,
  "created_at" TIMESTAMP NOT NULL,
  "created_by" INTEGER NOT NULL,
  CONSTRAINT tag_pkey PRIMARY KEY (nome, tp_marcador)
);

CREATE TABLE demo.cache_atendimento_ativo (
  "nratendimento" BIGINT,
  "cached_at" TIMESTAMP DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo' :: TEXT)
);

CREATE TABLE demo."tipoevolucao" (
  "idtipoevolucao" VARCHAR(50) NOT NULL,
  "nome" VARCHAR(150) NOT NULL,
  "ativo" BOOLEAN NOT NULL,
  "updated_at" TIMESTAMP NULL,
  "updated_by" INTEGER NULL,
  "created_at" TIMESTAMP NOT NULL,
  "created_by" INTEGER NOT NULL,
  CONSTRAINT tipoevolucao_pkey PRIMARY KEY (idtipoevolucao)
);

CREATE TABLE demo."relatorio" (
  "idrelatorio" bigserial PRIMARY KEY NOT NULL,
  "nome" VARCHAR(150) NOT NULL,
  "descricao" VARCHAR(250) NOT NULL,
  "tp_relatorio" int4 NOT NULL,
  "sql" TEXT NOT NULL,
  "ativo" BOOLEAN NOT NULL,
  "tp_status" int4 NOT NULL,
  "erro" TEXT NULL,
  "graficos" json NULL,
  "processed_at" TIMESTAMP NULL,
  "processed_by" INTEGER NULL,
  "updated_at" TIMESTAMP NULL,
  "updated_by" INTEGER NULL,
  "created_at" TIMESTAMP NOT NULL,
  "created_by" INTEGER NOT NULL
);

CREATE SEQUENCE demo.prescricao_fkprescricao_seq MINVALUE 0 NO MAXVALUE START 0 NO CYCLE;

CREATE SEQUENCE demo.evolucao_fkevolucao_seq INCREMENT BY 1 MINVALUE 1 NO MAXVALUE START 1 NO CYCLE;

CREATE INDEX demo_checkedindex_idx ON demo.checkedindex ("nratendimento", "fkmedicamento");

CREATE UNIQUE INDEX demo_intervencao_unique ON demo."intervencao" ("idintervencao");

CREATE INDEX demo_intervencao_fkpresmed_idx ON demo."intervencao" ("fkpresmed");

CREATE INDEX demo_intervencao_fkprescricao_idx ON demo."intervencao" ("fkprescricao");

CREATE INDEX demo_intervencao_nratendimento_idx ON demo."intervencao" ("nratendimento");

CREATE INDEX demo_intervencao_idx_status_dtintervencao ON demo."intervencao" USING btree ("status", "dtintervencao");

CREATE INDEX demo_intervencao_fkpresmed_destino_idx ON demo.intervencao USING btree ("fkpresmed_destino");

CREATE UNIQUE INDEX demo_exame_idx ON demo."exame" ("fkexame", "fkpessoa", "tpexame");

CREATE INDEX demo_exame_dtexame_idx ON demo."exame" USING brin ("dtexame") WITH (pages_per_range = 1);

CREATE INDEX demo_exame_fkpessoa_idx ON demo."exame" USING btree ("fkpessoa");

CREATE INDEX demo_pessoa_fkpessoa_idx ON demo."pessoa" USING btree ("fkpessoa");

CREATE UNIQUE INDEX demo_cultura_cab_idx ON demo."cultura_cabecalho" ("idculturacab");

CREATE UNIQUE INDEX demo_cultura_cab_uniq ON demo."cultura_cabecalho" ("fkexame", "fkpessoa", "fkitemexame");

CREATE INDEX demo_cultura_fkitemexame_idx ON demo.cultura USING brin (fkitemexame) WITH (pages_per_range = '1');

CREATE UNIQUE INDEX demo_cultura_unq ON demo."cultura" ("fkexame", "fkitemexame", "fkmedicamento");

CREATE UNIQUE INDEX demo_outlier_idx ON demo."outlier" (
  "fkmedicamento",
  "idsegmento",
  "doseconv",
  "frequenciadia"
);

CREATE INDEX demo_prescricao_fksetor_idx ON demo."prescricao" ("fksetor");

CREATE INDEX demo_prescricao_idsegmento_idx ON demo."prescricao" ("idsegmento");

CREATE INDEX demo_prescricao_nratendimento_idx ON demo."prescricao" ("nratendimento");

CREATE INDEX demo_prescricao_dtprescricao_idx ON demo."prescricao" USING btree ("dtprescricao");

CREATE INDEX demo_prescricao_update_by_idx ON demo."prescricao" ("update_by");

CREATE INDEX demo_prescricao_update_at_idx ON demo."prescricao" USING brin ("update_at") WITH (pages_per_range = 1);

CREATE INDEX demo_prescricao_evolucao_at_idx ON demo."prescricao" ("evolucao_at");

CREATE INDEX demo_prescricao_audit_fkprescricao_idx ON demo."prescricao_audit" ("fkprescricao");

CREATE INDEX demo_prescricao_audit_created_at_idx ON demo."prescricao_audit" USING brin ("created_at") WITH (pages_per_range = 1);

CREATE INDEX demo_prescricao_evolucao_fkprescricao_idx ON demo."prescricao_evolucao" ("fkprescricao");

CREATE INDEX demo_prescricao_evolucao_updated_at_idx ON demo."prescricao_evolucao" USING brin ("updated_at") WITH (pages_per_range = 1);

CREATE INDEX demo_presmed_audit_fkpresmed_idx ON demo."presmed_audit" ("fkpresmed");

CREATE INDEX demo_pessoa_alertadata_idx ON demo."pessoa" USING brin ("alertadata") WITH (pages_per_range = 1);

CREATE INDEX demo_pessoa_dtnascimento_idx ON demo."pessoa" USING brin ("dtnascimento") WITH (pages_per_range = 1);

CREATE INDEX demo_presmed_fkmedicamento_idx ON demo."presmed" ("fkmedicamento", "idsegmento");

CREATE INDEX demo_presmed_fkprescricao_idx ON demo."presmed" ("fkprescricao");

CREATE INDEX demo_presmed_slagrupamento_idx ON demo."presmed" USING brin ("slagrupamento") WITH (pages_per_range = 1);

CREATE UNIQUE INDEX ON demo.prescricaoagg USING btree (
  fkmedicamento,
  fksetor,
  fkunidademedida,
  fkfrequencia,
  dose,
  peso
);

CREATE INDEX ON demo."prescricaoagg" (
  "idsegmento",
  "fkmedicamento",
  "doseconv",
  "frequenciadia"
);

CREATE UNIQUE INDEX demo_medatributos_idx ON demo."medatributos" ("fkmedicamento", "idsegmento");

CREATE UNIQUE INDEX demo_frequencia_idx ON demo."frequencia" ("fkhospital", "fkfrequencia");

CREATE UNIQUE INDEX demo_unidademedida_idx ON demo."unidademedida" ("fkhospital", "fkunidademedida");

CREATE UNIQUE INDEX demo_unidadeconverte_idx ON demo."unidadeconverte" ("idsegmento", "fkmedicamento", "fkunidademedida");

CREATE UNIQUE INDEX demo_segmentosetor_idx ON demo."segmentosetor" ("fkhospital", "fksetor");

CREATE UNIQUE INDEX demo_setor_idx ON demo."setor" ("fkhospital", "fksetor");

CREATE UNIQUE INDEX ON demo."observacao" ("idoutlier", "fkpresmed");

CREATE INDEX ON demo."observacao" ("nratendimento", "fkmedicamento");

CREATE INDEX demo_evolucao_nratendimento_idx ON demo."evolucao" ("nratendimento");

CREATE INDEX demo_evolucao_dtevolucao_idx ON demo."evolucao" USING brin ("dtevolucao") WITH (pages_per_range = 1);

CREATE INDEX demo_evolucao_audit_fkevolucao_idx ON demo.evolucao_audit USING btree (fkevolucao);

CREATE INDEX demo_intervencao_audit_idintervencao_idx ON demo.intervencao_audit USING btree (idintervencao);

CREATE INDEX demo_medatributos_audit_fkmedicamento_idsegmento_idx ON demo.medatributos_audit USING btree (fkmedicamento, idsegmento);

CREATE INDEX demo_pessoa_audit_nratendimento_idx ON demo.pessoa_audit USING btree (nratendimento);

ALTER TABLE
  demo."alergia"
ADD
  CONSTRAINT demo_alergia_uniq_const UNIQUE (fkpessoa, fkmedicamento);

CREATE
OR REPLACE VIEW demo.usuario AS
SELECT
  usuario.idusuario,
  usuario.fkusuario,
  usuario.nome,
  usuario.email,
  usuario.ativo
FROM
  public.usuario
WHERE
  usuario.schema = 'demo';

CREATE
OR REPLACE VIEW demo.schemaconfig AS
SELECT
  schema_name,
  status,
  idschema_config,
  tp_pep
FROM
  schema_config sc
WHERE
  schema_name = 'demo';

CREATE TABLE IF NOT EXISTS demo.presmed_arquivo (LIKE demo.presmed EXCLUDING INDEXES);

CREATE TABLE IF NOT EXISTS demo.presmed_audit_arquivo (LIKE demo.presmed_audit EXCLUDING INDEXES);

CREATE TABLE IF NOT EXISTS demo.prescricao_arquivo (LIKE demo.prescricao EXCLUDING INDEXES);

CREATE TABLE IF NOT EXISTS demo.prescricao_audit_arquivo (LIKE demo.prescricao_audit EXCLUDING INDEXES);

CREATE TABLE IF NOT EXISTS demo.exame_arquivo (LIKE demo.exame EXCLUDING INDEXES);

CREATE TABLE IF NOT EXISTS demo.evolucao_arquivo (LIKE demo.evolucao EXCLUDING INDEXES);

ALTER TABLE
  demo.presmed
ADD
  CONSTRAINT check_origem_valida CHECK (
    origem IN (
      'Medicamentos',
      'Soluções',
      'Proced/Exames',
      'Dietas',
      'Materiais'
    )
  );

ALTER TABLE
  demo.prescricao
ADD
  CONSTRAINT chk_prescricao_nratendimento CHECK (
    nratendimento BETWEEN 0 AND 999999999
  );

ALTER TABLE
  demo.pessoa
ADD
  CONSTRAINT chk_pessoa_nratendimento CHECK (
    nratendimento BETWEEN 0 AND 999999999
  );