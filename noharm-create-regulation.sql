-- tabela principal que armazena todas as solicitações
CREATE TABLE demo."reg_solicitacao" (
  -- principais
  "fkreg_solicitacao" bigint PRIMARY KEY NOT NULL ,
  "nratendimento" bigint NOT NULL,
  "fkpessoa" bigint not null,
  "fksetor" bigint not null,
  "dtsolicitacao" timestamp not null,
  "fkreg_tipo_solicitacao" bigint NOT NULL,

  -- extra pep
  "risco" smallint null,
  "cid" varchar(400) null,
  "atendente" varchar(250) null,
  "atendente_registro" varchar(200) null,
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

-- tabela para armazenar conteúdos extras da solicitacao
CREATE TABLE demo."reg_solicitacao_atributo" (
  "idreg_solicitacao_atributo" serial8 PRIMARY KEY NOT NULL ,
  "fkreg_solicitacao" bigint NOT NULL,
  "tp_solicitacao_atributo" smallint not null,
  "tp_status" smallint not null,
  "valor" jsonb not null,

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
  "template" json not null,

  --controle
  "created_at" timestamp DEFAULT NOW(),
  "created_by" integer
);


-- tabela para armazenar os tipos de solicitacao (Ex. Consulta em cardiologista)
CREATE TABLE demo."reg_tipo_solicitacao" (
  "fkreg_tipo_solicitacao" bigint PRIMARY KEY NOT NULL,
  "nome" varchar(250) not null,
  "status" smallint not null,
  "tp_tipo" smallint not null,

  "created_at" timestamp DEFAULT NOW(),
  "created_by" integer,
  "updated_at" timestamp DEFAULT NOW(),
  "updated_by" integer
);
