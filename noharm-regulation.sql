-- tabela principal que armazena todas as solicitações
CREATE TABLE demo."reg_solicitacao" (
  -- principais
  "fkreg_solicitacao" bigint PRIMARY KEY NOT NULL ,
  "nratendimento" bigint NOT NULL,
  "fkpessoa" bigint not null,
  "dtsolicitacao" timestamp not null,
  "fkreg_tipo_solicitacao" bigint NOT NULL,

  -- extra pep
  "risco" smallint null,
  "cid" bigint,
  "atendente" varchar(250),
  "atendente_crm" integer,
  "justificativa" text,

  -- extra interno
  "etapa" smallint not null,
  "dtagendamento" timestamp,
  "dttransporte" timestamp,

  --controle
  "created_at" timestamp DEFAULT NOW(),
  "created_by" integer,
  "updated_at" timestamp DEFAULT NOW(),
  "updated_by" integer
);


-- tabela que armaze as movimentacoes da solicitacao
CREATE TABLE demo."reg_movimentacao" (
  "idreg_movimentacao" serial8 PRIMARY KEY not null,
  "fkreg_solicitacao" bigint not null,
  "etapa_origem" smallint not null,
  "etapa_destino" smallint not null,
  "acao" smallint not null,
  "dados" json not null,

  --controle
  "created_at" timestamp DEFAULT NOW(),
  "created_by" integer
);


-- tabela para armazenar os tipos de solicitacao (Ex. Consulta em cardiologista)
CREATE TABLE demo."reg_tipo_solicitacao" (
  "fkreg_tipo_solicitacao" bigint PRIMARY KEY NOT NULL,
  "nome" varchar(250) not null,
  "status" smallint not null,

  "created_at" timestamp DEFAULT NOW(),
  "created_by" integer,
  "updated_at" timestamp DEFAULT NOW(),
  "updated_by" integer
);