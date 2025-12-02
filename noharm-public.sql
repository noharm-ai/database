CREATE TABLE public."usuario" (
  "idusuario" SERIAL PRIMARY KEY NOT NULL,
  "nome" varchar(255) NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "senha" varchar(255) NOT NULL,
  "schema" varchar(25) NOT NULL,
  "fkusuario" varchar(50) DEFAULT NULL,
  "config" json DEFAULT NULL,
  "relatorios" json default null,
  "ativo" bool NOT NULL DEFAULT true
);

create table public."usuario_audit" (
	"idusuario_audit" serial8 not null,
	"tp_audit" smallint not null,
	"idusuario" integer not null,
	"pw_token" text,
	"extra" json,
	"audit_ip" varchar(200),
	"created_at" timestamp not null,
	"created_by" integer not null
);

CREATE TABLE public."substancia" (
  "sctid" bigint NOT NULL,
  "nome" varchar(255) NOT NULL,
  "link" varchar(255) DEFAULT NULL,
  "idclasse" varchar(10) NULL,
  "ativo" boolean DEFAULT true,
  "manejo" jsonb NULL,
  "curadoria" text null,
  "dosemax_adulto" float4 NULL,
	"dosemax_pediatrico" float4 NULL,
	"unidadepadrao" varchar(32) NULL,
	"dosemax_peso_adulto" float4 NULL,
	"dosemax_peso_pediatrico" float4 NULL,
  "renal_adulto" int4 NULL,
	"renal_pediatrico" int4 NULL,
	"hepatico_adulto" int4 NULL,
	"hepatico_pediatrico" int4 NULL,
	"risco_queda" int2 NULL,
	"lactante" varchar(1) NULL,
	"gestante" varchar(1) NULL,
	"plaquetas" int4 NULL,
	"divisor_faixa" float4 NULL,
  "tags" _varchar NULL,
  "update_at" timestamp NULL,
  "update_by" int4 NULL
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
  "nivel" varchar(100),
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
  created_by int4 NULL,
	created_at timestamp NOT NULL,
	fl1_atualiza_indicadores_cpoe bool NOT NULL DEFAULT false,
	fl2_atualiza_indicadores_prescricao bool NOT NULL DEFAULT false,
	fl3_atualiza_prescricaoagg bool NOT NULL DEFAULT false,
	fl3_segmentos _int4 NULL,
	fl4_cria_conciliacao bool NOT NULL DEFAULT false,
  fl5_score_med_novos bool NOT NULL DEFAULT false,
	configuracao jsonb NULL,
	tp_noharm_care int2 NOT NULL DEFAULT 2,
  tp_prescalc int2 NOT NULL DEFAULT 0,
	status int4 NOT NULL DEFAULT 0,
  cpoe bool NOT NULL DEFAULT false,
  integracao_retorno bool NOT NULL DEFAULT false,
	updated_by int4 NULL,
	CONSTRAINT schema_config_pkey PRIMARY KEY (schema_name)
);

create table public."schema_config_audit" (
	"idschema_config_audit" serial8 not null,
  "schema_name" varchar(200) not null,
	"tp_audit" smallint not null,
	"extra" json,
	"created_at" timestamp not null,
	"created_by" integer not null
);

create table public."fila_processamento" (
	"idfila_processamento" bigserial PRIMARY KEY NOT NULL,
	"schema_name" varchar(200) not null,
	"tp_fila_processamento" smallint not null,
	"tp_situacao" smallint not null,
	"configuracao" json not null,
	"updated_at" timestamp null,
	"updated_by" integer null,
	"created_at" timestamp not null,
	"created_by" integer not null
);

CREATE TABLE public."memoria" (
  "idmemoria" SERIAL NOT NULL,
  "tipo" varchar(100) NOT NULL,
  "valor" json NOT NULL,
  "update_at" timestamp NOT NULL DEFAULT NOW(),
  "update_by" integer NOT NULL,
  PRIMARY KEY ("idmemoria", "tipo")
);

create table public."usuario_autorizacao" (
	"idusuario_autorizacao" serial8 not null,
	"idusuario" integer not null,
	"idsegmento" int2,
	"schema_name" varchar(200),
	"created_at" timestamp not null,
	"created_by" integer not null
);

create table public."usuario_extra" (
	"idusuario" integer PRIMARY KEY not null,
	"config" json not null,
	"created_at" timestamp not null,
	"created_by" integer not null
);

create table public."protocolo" (
	"idprotocolo" serial PRIMARY KEY NOT NULL,
	"schema_name" varchar(200),
	"nome" varchar(150) not null,
	"tp_protocolo" smallint not null,
	"tp_situacao" smallint not null,
	"configuracao" json not null,
	"updated_at" timestamp null,
	"updated_by" integer null,
	"created_at" timestamp not null,
	"created_by" integer not null
);

CREATE TABLE public."tb_cid10" (
	"co_cid10" int8 NOT NULL,
	"nu_cid10" varchar(4) NOT NULL,
	"tp_agravo" int8 NOT NULL,
	"no_cid10" varchar(400) NOT NULL,
	"no_cid10_filtro" varchar(400) NOT NULL,
	"st_ativo" int4 NOT NULL,
	"no_sexo" varchar(24) NULL,
	"nu_cid10_filtro" varchar(255) NULL,
	CONSTRAINT tb_cid10_pkey PRIMARY KEY ("co_cid10")
);

CREATE INDEX ON public."usuario_autorizacao" ("idusuario");

CREATE UNIQUE INDEX ON public."substancia" ("sctid");

CREATE UNIQUE INDEX ON public."relacao" ("sctida", "sctidb", "tprelacao");

/**
* CUSTOM TYPES
*/
CREATE TYPE public.PARAMETRO_TYPE AS (nome_schema TEXT, skip_list TEXT [ ], features TEXT [ ]);

CREATE TYPE public.presmed_resultado_type_v2 AS (
	idsegmento int2,
	idoutlier int4,
	origem text,
	sonda bool,
	intravenosa bool,
	aprox bool,
	checado bool,
	frequenciadia float4,
	doseconv float4,
	escorefinal int2,
	periodo int2,
	cpoe_grupo int8,
	nratendimento int8,
	alergia char(1),
	extra jsonb
);

CREATE TYPE public.PRESCRICAOAGG_RESULTADO_TYPE AS (
  idsegmento int2,
  fkfrequencia VARCHAR(200),
  fkunidademedida VARCHAR(200),
  frequenciadia float4,
  doseconv float4,
  peso float4
);

CREATE TYPE public.PRESCRICAO_RESULTADO_TYPE AS (
  idsegmento int2,
  dtvigencia timestamp,
  aggsetor _int4
);

/**
* FUNCTIONS
*/

-- DROP FUNCTION public.complete_presmed_v2(parametro_type, record);

CREATE OR REPLACE FUNCTION public.complete_presmed_v2(p_params parametro_type, p_presmed_origem record)
 RETURNS presmed_resultado_type_v2
 LANGUAGE plpgsql
AS $function$
DECLARE
  PRESMED_RESULTADO public.PRESMED_RESULTADO_TYPE_V2;
  V_DIVISOR float;
  V_USAPESO boolean;
  V_PESO float;
  V_NUMHOSPITAL int;
  V_FKPRESCRICAO_PERIODO bigint[];
  V_PRESCRICAO record;
  V_PRESMED record;
  V_FK_PRESCRICAO_AGG bigint;
  V_CPOE boolean;
BEGIN
  if P_PARAMS.nome_schema is null or P_PARAMS.nome_schema = '' then
    RAISE EXCEPTION 'Parametro invalido: nome_schema';
  end if;

  EXECUTE FORMAT('SET search_path to %s;', P_PARAMS.nome_schema);


  /**
  * VERIFICAR SE HOUVE ALTERACAO
  */
  if 'INSERT_IGNORE' = any(coalesce(P_PARAMS.features, array[]::text[])) then
	  IF P_PRESMED_ORIGEM.idoutlier IS NULL OR P_PRESMED_ORIGEM.doseconv IS NULL THEN
		SELECT * INTO V_PRESMED FROM presmed WHERE fkpresmed = P_PRESMED_ORIGEM.fkpresmed;
		IF FOUND THEN
			IF
				    V_PRESMED.dose            IS NOT DISTINCT FROM P_PRESMED_ORIGEM.dose
				AND V_PRESMED.fkfrequencia    IS NOT DISTINCT FROM P_PRESMED_ORIGEM.fkfrequencia
				AND V_PRESMED.fkmedicamento   IS NOT DISTINCT FROM P_PRESMED_ORIGEM.fkmedicamento
				AND V_PRESMED.fkunidademedida IS NOT DISTINCT FROM P_PRESMED_ORIGEM.fkunidademedida
				AND V_PRESMED.via             IS NOT DISTINCT FROM P_PRESMED_ORIGEM.via
				AND V_PRESMED.horario         IS NOT DISTINCT FROM P_PRESMED_ORIGEM.horario
				AND V_PRESMED.sletapas        IS NOT DISTINCT FROM P_PRESMED_ORIGEM.sletapas
				AND V_PRESMED.dtsuspensao     IS NOT DISTINCT FROM P_PRESMED_ORIGEM.dtsuspensao
			THEN
				RETURN NULL;
			END IF;
		END IF;
	  END IF;
  end if;

  /**
  * PARAMETROS
  */
  V_NUMHOSPITAL := (
    SELECT p.fkhospital FROM prescricao p
    WHERE p.fkprescricao = P_PRESMED_ORIGEM.fkprescricao
  );
  PRESMED_RESULTADO.nratendimento := (select nratendimento from prescricao pp where pp.fkprescricao = P_PRESMED_ORIGEM.fkprescricao limit 1);

  select *
  into V_PRESCRICAO
  from prescricao where fkprescricao = P_PRESMED_ORIGEM.fkprescricao;

  /**
  * ORIGENS
  */
  PRESMED_RESULTADO.origem := (
    select
      case
        when tipo = 'map-origin-drug' then 'Medicamentos'
        when tipo = 'map-origin-solution' then 'Soluções'
        when tipo = 'map-origin-procedure' then 'Proced/Exames'
        when tipo = 'map-origin-diet' then 'Dietas'
        when tipo = 'map-origin-custom' then P_PRESMED_ORIGEM.origem
        else 'Medicamentos'
      end as origem
    from (
      select
        jsonb_array_elements_text(valor::jsonb) valor,
        tipo
      from
        memoria m
      where
        tipo in (
          'map-origin-drug', 'map-origin-solution',
          'map-origin-procedure', 'map-origin-diet',
          'map-origin-custom'
        )
    ) o
    where
      valor = P_PRESMED_ORIGEM.origem
    limit 1
  );

  if PRESMED_RESULTADO.origem is null then
    PRESMED_RESULTADO.origem := 'Medicamentos';
  end if;


  /**
  * VIAS
  */
  IF P_PRESMED_ORIGEM.via in (select jsonb_array_elements_text(valor::jsonb) from memoria m where tipo = 'map-tube') THEN
    PRESMED_RESULTADO.sonda := TRUE;
  END IF;

  IF P_PRESMED_ORIGEM.via in (select jsonb_array_elements_text(valor::jsonb) from memoria m where tipo = 'map-iv') THEN
    PRESMED_RESULTADO.intravenosa := TRUE;
  END IF;

  /**
  * FREQUENCIAS
  */
  -- Medicamentos com Frequência
  IF P_PRESMED_ORIGEM.fkfrequencia IS NOT NULL then
    PRESMED_RESULTADO.frequenciadia := COALESCE(
      (
        SELECT f.frequenciadia FROM frequencia f
        WHERE
          f.fkfrequencia = P_PRESMED_ORIGEM.fkfrequencia
        limit 1
    ),
    P_PRESMED_ORIGEM.frequenciadia
  );
  END IF;

  -- Soluções com Etapa
  IF PRESMED_RESULTADO.frequenciadia IS NULL THEN PRESMED_RESULTADO.frequenciadia := P_PRESMED_ORIGEM.sletapas; END IF;

  -- Medicamentos com Horário
  IF PRESMED_RESULTADO.frequenciadia IS NULL AND P_PRESMED_ORIGEM.horario IS NOT NULL AND PRESMED_RESULTADO.origem = 'Medicamentos' THEN
    PRESMED_RESULTADO.frequenciadia := ( SELECT array_length(string_to_array(trim(P_PRESMED_ORIGEM.horario), ' '), 1) );
    IF P_PRESMED_ORIGEM.horario = 'ACM' THEN PRESMED_RESULTADO.frequenciadia := 44; END IF;
    IF P_PRESMED_ORIGEM.horario = 'SN' THEN PRESMED_RESULTADO.frequenciadia := 33; END IF;
  END IF;

  -- Soluções com Horário (remover)
  IF PRESMED_RESULTADO.frequenciadia IS NULL AND P_PRESMED_ORIGEM.horario IS NOT NULL AND PRESMED_RESULTADO.origem = 'Soluções' THEN
    PRESMED_RESULTADO.frequenciadia := ( SELECT array_length(string_to_array(trim(P_PRESMED_ORIGEM.horario), 'das'), 1)-1 );
  END IF;

  -- Soluções ACM
  IF PRESMED_RESULTADO.frequenciadia IS NULL AND P_PRESMED_ORIGEM.slacm = 'S' AND PRESMED_RESULTADO.origem = 'Soluções' THEN
    PRESMED_RESULTADO.frequenciadia := 44;
  END IF;

  -- Medicamento sem Frequência
  IF PRESMED_RESULTADO.frequenciadia IS NULL THEN
    PRESMED_RESULTADO.frequenciadia := 99;
  END IF;

  /**
  * SEGMENTO
  */
  PRESMED_RESULTADO.idsegmento := (
    SELECT p.idsegmento FROM prescricao p
    WHERE p.fkprescricao = P_PRESMED_ORIGEM.fkprescricao
  );

  V_CPOE := COALESCE(
      (
        SELECT s.cpoe FROM segmento s
        WHERE
          s.idsegmento = PRESMED_RESULTADO.idsegmento
        limit 1
      ),
    'CPOE' = any(coalesce(P_PARAMS.features, array[]::text[]))
  );


  /**
  * DOSE
  */
  PRESMED_RESULTADO.doseconv := (
    SELECT COALESCE (
		  (
        SELECT (P_PRESMED_ORIGEM.dose * u.fator) as doseconv
		    FROM unidadeconverte u
		    WHERE u.idsegmento = PRESMED_RESULTADO.idsegmento
		    AND u.fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
		    AND u.fkunidademedida = P_PRESMED_ORIGEM.fkunidademedida
      )
      , P_PRESMED_ORIGEM.dose
    )
  );

  -- Medicamento com Faixa de Valores para Outliers
  V_DIVISOR := (
    SELECT a.divisor FROM medatributos a
    WHERE a.fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
    AND a.idsegmento = PRESMED_RESULTADO.idsegmento
    AND a.divisor IS NOT NULL
  );

  IF V_DIVISOR IS NOT NULL THEN
    V_PESO := 1;
    V_USAPESO := (
      SELECT a.usapeso FROM medatributos a
      WHERE a.fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
      AND a.idsegmento = PRESMED_RESULTADO.idsegmento
      AND a.divisor IS NOT NULL
    );

    IF V_USAPESO IS TRUE THEN
      V_PESO := (
        SELECT COALESCE (
          (
            SELECT pe.peso FROM pessoa pe
            INNER JOIN prescricao pr ON pr.nratendimento = pe.nratendimento
            WHERE pr.fkprescricao = P_PRESMED_ORIGEM.fkprescricao AND pe.peso > 0
          )
          , 1
        )
      );

    END IF;

    IF V_PESO > 0 AND V_DIVISOR > 0 THEN
      PRESMED_RESULTADO.doseconv := (SELECT CEIL(((PRESMED_RESULTADO.doseconv/V_PESO)/V_DIVISOR)::numeric) * V_DIVISOR);
    END IF;
  END IF;


  /**
  * OUTLIERS
  */
  PRESMED_RESULTADO.idoutlier := (
      SELECT MAX(o.idoutlier) FROM outlier o
      WHERE o.fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
      AND round(o.doseconv::numeric, 2) = round(PRESMED_RESULTADO.doseconv::numeric, 2)
      AND o.frequenciadia = PRESMED_RESULTADO.frequenciadia
      AND o.idsegmento = PRESMED_RESULTADO.idsegmento
  );

  IF PRESMED_RESULTADO.idoutlier IS NULL AND PRESMED_RESULTADO.doseconv > 0 THEN
    -- busca por similaridade
    PRESMED_RESULTADO.idoutlier := (
      	SELECT
        	idoutlier
	    from (
	        SELECT
	          o.idoutlier,
	          1 - ( (o.doseconv * PRESMED_RESULTADO.doseconv + o.frequenciadia * PRESMED_RESULTADO.frequenciadia) / (sqrt( power(o.doseconv,2) + power(o.frequenciadia,2) ) *
				    sqrt( power(PRESMED_RESULTADO.doseconv,2) + power(PRESMED_RESULTADO.frequenciadia,2)) ) ) as cosine,
				    sqrt(power(o.doseconv - PRESMED_RESULTADO.doseconv,2) + power(o.frequenciadia - PRESMED_RESULTADO.frequenciadia,2)) as euclidian
			FROM outlier o
			WHERE
	          o.idsegmento = PRESMED_RESULTADO.idsegmento
			  and o.fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
	          and o.doseconv > 0 and o.frequenciadia > 0
		) as t
	    ORDER BY cosine asc, euclidian asc
	    LIMIT 1
    );

    IF PRESMED_RESULTADO.idoutlier IS not NULL then
      PRESMED_RESULTADO.aprox := true;
    END IF;
  END IF;

  PRESMED_RESULTADO.escorefinal := (
    SELECT COALESCE(escoremanual, escore)
    FROM outlier
    WHERE idoutlier = PRESMED_RESULTADO.idoutlier
  );

  /**
  * CHECADO
  * verifica se o item foi checado anteriormente
  */
  if 'CHECADO' != all(coalesce(P_PARAMS.skip_list, array[]::text[])) then
    if 'CHECADO-COMPLEMENTO' = any(coalesce(P_PARAMS.features, array[]::text[])) then
      PRESMED_RESULTADO.checado := (
          SELECT true FROM checkedindex
          WHERE nratendimento = PRESMED_RESULTADO.nratendimento
          and fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
          AND doseconv = PRESMED_RESULTADO.doseconv
          AND frequenciadia = PRESMED_RESULTADO.frequenciadia
          AND sletapas = COALESCE(P_PRESMED_ORIGEM.sletapas, 0)
          AND slhorafase = COALESCE(P_PRESMED_ORIGEM.slhorafase, 0)
          AND sltempoaplicacao = COALESCE(P_PRESMED_ORIGEM.sltempoaplicacao, 0)
          AND sldosagem = COALESCE(P_PRESMED_ORIGEM.sldosagem, 0)
          AND via = COALESCE(P_PRESMED_ORIGEM.via, '')
          AND horario = COALESCE(left(P_PRESMED_ORIGEM.horario ,50), '')
          and dose = P_PRESMED_ORIGEM.dose
          AND coalesce(complemento, '') = coalesce(MD5(P_PRESMED_ORIGEM.complemento), '')
          LIMIT 1
      );
    else
      PRESMED_RESULTADO.checado := (
          SELECT true FROM checkedindex
          WHERE nratendimento = PRESMED_RESULTADO.nratendimento
          and fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
          AND doseconv = PRESMED_RESULTADO.doseconv
          AND frequenciadia = PRESMED_RESULTADO.frequenciadia
          AND sletapas = COALESCE(P_PRESMED_ORIGEM.sletapas, 0)
          AND slhorafase = COALESCE(P_PRESMED_ORIGEM.slhorafase, 0)
          AND sltempoaplicacao = COALESCE(P_PRESMED_ORIGEM.sltempoaplicacao, 0)
          AND sldosagem = COALESCE(P_PRESMED_ORIGEM.sldosagem, 0)
          AND via = COALESCE(P_PRESMED_ORIGEM.via, '')
          AND horario = COALESCE(left(P_PRESMED_ORIGEM.horario ,50), '')
          and dose = P_PRESMED_ORIGEM.dose
          LIMIT 1
      );
    end if;
  end if;

  /**
  * CALCULO DO PERIODO DE TRATAMENTO
  */
  if 'PERIODO' != all(coalesce(P_PARAMS.skip_list, array[]::text[])) then
  	V_FKPRESCRICAO_PERIODO := (
		select
			array_agg(fkprescricao)
		from
			prescricao
		where
			nratendimento = PRESMED_RESULTADO.nratendimento
			and idsegmento = PRESMED_RESULTADO.idsegmento
			and fkprescricao < P_PRESMED_ORIGEM.fkprescricao
			and dtprescricao > current_date - interval '120' day
	);
    PRESMED_RESULTADO.periodo := (
      with vigencias as (
        select
          prescricao.dtprescricao::date dtinicial,
		  case
            when count(presmed.dtsuspensao) = count(prescricao.dtprescricao) then max(presmed.dtsuspensao)::date -- somente quando todos estao suspensos
            when max(prescricao.dtvigencia)::date > now()::date then now()::date
            else max(prescricao.dtvigencia)::date
          end as dtfinal
        FROM
          presmed
          JOIN prescricao ON prescricao.fkprescricao = presmed.fkprescricao
          JOIN medicamento ON medicamento.fkmedicamento = presmed.fkmedicamento
        WHERE
          prescricao.nratendimento = PRESMED_RESULTADO.nratendimento
          and presmed.fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
          and presmed.fkprescricao = any(V_FKPRESCRICAO_PERIODO)
        group by
          prescricao.dtprescricao
      ),
      dias_prescritos as (
        select
          i::date as dia,
          coalesce((select 1 from vigencias where i::date between dtinicial and dtfinal limit 1), 0) as total
        from
          generate_series((select min(dtinicial) from vigencias), (select max(dtfinal) from vigencias), '1 day'::interval) i
      ),
      dias_prescritos_grupo as (
        select
          dias_prescritos.dia,
          dias_prescritos.total,
          (
            select
              sum(dant.total)
            from
              dias_prescritos dant
            where
              -- definir periodo válido (qtd de dias em que a parada interrompe a contagem)
              dant.dia between (dias_prescritos.dia - interval '1 days')::date and (dias_prescritos.dia - interval '1 days')::date
          ) as anteriores
        from
          dias_prescritos
      )
      select
        case
          -- desconsidera se o intervalo for mair que 1 dia
          when (extract(day from (select dtprescricao from prescricao pp where pp.fkprescricao = P_PRESMED_ORIGEM.fkprescricao limit 1) - max(dia))) > 1 then 0
          else count(*)
        end
      from
        dias_prescritos
      where
        dia >= (
          select
            max(dia)
          from
            dias_prescritos_grupo
          where
            (total = 1 and anteriores = 0) or (total = 1 and anteriores is null)
        )
        and total = 1
    );
  end if;

  /**
  * VERIFICA ALERGIA
  */
  if 'ALERGIA' = any(coalesce(P_PARAMS.features, array[]::text[])) then
	if exists (
		SELECT
			1
		FROM
			alergia a
			inner join medicamento m on a.fkmedicamento = m.fkmedicamento
		WHERE
			(
				m.fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
				or m.sctid = (select sctid from medicamento where fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento LIMIT 1)
			)
			AND a.fkpessoa = V_PRESCRICAO.fkpessoa
			and a.ativo = true
		LIMIT 1
	) then
		PRESMED_RESULTADO.alergia = 'S';
	else
		PRESMED_RESULTADO.alergia = 'N';
	end if;
  end if;

  if V_CPOE then
    if P_PRESMED_ORIGEM.cpoe_nrseq_anterior is null then
      PRESMED_RESULTADO.cpoe_grupo := P_PRESMED_ORIGEM.cpoe_nrseq;
    else
      PRESMED_RESULTADO.cpoe_grupo := (
        select
          coalesce(
            (
              select cpoe_grupo
              from presmed
              where cpoe_nrseq = P_PRESMED_ORIGEM.cpoe_nrseq_anterior
              limit 1
            ), P_PRESMED_ORIGEM.cpoe_nrseq
          )
      );
    END IF;

    -- deschecagem
    if PRESMED_RESULTADO.origem in ('Medicamentos', 'Soluções', 'Proced/Exames') then
    	-- novo item
		if not exists(select fkpresmed from presmed where fkpresmed = P_PRESMED_ORIGEM.fkpresmed) then
			V_FK_PRESCRICAO_AGG := concat(
				to_char(V_PRESCRICAO.dtprescricao, 'YYMMDD'),
				V_PRESCRICAO.idsegmento * 1000000000::bigint + V_PRESCRICAO.nratendimento
			)::bigint;

			-- deschecar se o status for igual a 's'
			-- se possuir a feature NAO_DESCHECAR_FREQ_AGORA e a frequenciadia = 66, não deve executar a deschecagem (adicionado em 06/12/24 - Marcelo)
			if
				(select status from prescricao where fkprescricao = V_FK_PRESCRICAO_AGG) = 's'
				and not ('CPOE_NAO_DESCHECAR_FREQ_AGORA' = any(coalesce(P_PARAMS.features, array[]::text[])) and PRESMED_RESULTADO.frequenciadia = 66)
			then
				update
					prescricao p
				set
					status = '0',
					update_at = now()
				where
					fkprescricao = V_FK_PRESCRICAO_AGG;

				-- search path precisa ser setado novamente, pois houve um reset no comando acima
				EXECUTE FORMAT('SET search_path to %s;', P_PARAMS.nome_schema);


				insert into prescricao_audit (
					tp_audit, nratendimento, fkprescricao, dtprescricao, fksetor,
					total_itens, agregada, concilia, idsegmento, leito, created_at,
					created_by, extra
				)
				values (
					2, V_PRESCRICAO.nratendimento, V_FK_PRESCRICAO_AGG, V_PRESCRICAO.dtprescricao, V_PRESCRICAO.fksetor,
					0, true, V_PRESCRICAO.concilia, V_PRESCRICAO.idsegmento, V_PRESCRICAO.leito, now(),
					0,'{"source": "trigger public.complete_presmed"}'
				);
			end if;

		end if;
	end if;
  end if;

  if 'AUDIT' != all(coalesce(P_PARAMS.skip_list, array[]::text[])) then
    insert into presmed_audit
      (tp_audit, fkpresmed, created_at, created_by, extra)
      values
	  (2, P_PRESMED_ORIGEM.fkpresmed, now(), 0, jsonb_build_object('checado_anteriormente', PRESMED_RESULTADO.checado,'periodo_calculado', PRESMED_RESULTADO.periodo));
  end if;

  RESET search_path;
  RETURN PRESMED_RESULTADO;
END;
$function$
;


----------

CREATE OR REPLACE FUNCTION public.complete_prescricao(p_params parametro_type, p_origem record)
 RETURNS prescricao_resultado_type
 LANGUAGE plpgsql
AS $function$
DECLARE
  V_RESULTADO public.PRESCRICAO_RESULTADO_TYPE;
  V_CPOE boolean;
BEGIN
  if P_PARAMS.nome_schema is null or P_PARAMS.nome_schema = '' then
    RAISE EXCEPTION 'Parametro invalido: nome_schema';
  end if;

  EXECUTE FORMAT('SET search_path to %s;', P_PARAMS.nome_schema);

  V_RESULTADO.idsegmento := (
    SELECT s.idsegmento FROM segmentosetor s
    WHERE s.fksetor = P_ORIGEM.fksetor
    AND s.fkhospital = P_ORIGEM.fkhospital
  );

  V_CPOE := COALESCE(
      (
        SELECT s.cpoe FROM segmento s
        WHERE
          s.idsegmento = V_RESULTADO.idsegmento
        limit 1
      ),
    false
  );

  IF P_ORIGEM.dtprescricao > P_ORIGEM.dtvigencia THEN
    V_RESULTADO.dtvigencia := P_ORIGEM.dtprescricao + interval '10 min';
  else
    V_RESULTADO.dtvigencia := P_ORIGEM.dtvigencia;
  END IF;

  if V_CPOE then
	-- obs: status de prescricao cpoe é atualizado na complete_presmed
	-- status de prescricao NAO cpoe é atualizado no prescalc

	if 'SKIP_CPOE_DEPARTMENT_UPDATE' = any(coalesce(P_PARAMS.skip_list, array[]::text[])) then
		-- atualiza somente o update_at (útil para o atendcalc)
		UPDATE
	      prescricao p
	    set
	      update_at = now()
	    where
	      nratendimento = P_ORIGEM.nratendimento
	      and (
	      		dtprescricao::date = P_ORIGEM.dtprescricao::date
	      		or
	      		dtprescricao::date = P_ORIGEM.dtprescricao::date + interval '1 day'
	      )
	      and agregada is not null;
	else
		-- atualiza prescricao atual e posterior, pois as agregadas cpoe sao geradas sempre 1 dia antes do seu dtprescricao
	    UPDATE
	      prescricao p
	    set
	      aggsetor = array_append(aggsetor, P_ORIGEM.fksetor),
	      fksetor = P_ORIGEM.fksetor,
	      leito = P_ORIGEM.leito,
	      update_at = now()
	    where
	      nratendimento = P_ORIGEM.nratendimento
	      and (
	      		dtprescricao::date = P_ORIGEM.dtprescricao::date
	      		or
	      		dtprescricao::date = P_ORIGEM.dtprescricao::date + interval '1 day'
	      )
	      and agregada is not null;

	end if;
  end if;

  RESET search_path;
  RETURN V_RESULTADO;
END;
$function$
;

------

CREATE
OR REPLACE FUNCTION public.complete_prescricaoagg(
  P_PARAMS public.PARAMETRO_TYPE,
  P_ORIGEM record
) RETURNS public.PRESCRICAOAGG_RESULTADO_TYPE LANGUAGE plpgsql AS $function$
DECLARE
  V_RESULTADO public.PRESCRICAOAGG_RESULTADO_TYPE;
  V_DIVISOR float;
  V_USAPESO boolean;
BEGIN
  if P_PARAMS.nome_schema is null or P_PARAMS.nome_schema = '' then
    RAISE EXCEPTION 'Parametro invalido: nome_schema';
  end if;

  EXECUTE FORMAT('SET search_path to %s;', P_PARAMS.nome_schema);

  /**
  * FREQUENCIA
  */
  IF P_ORIGEM.fkfrequencia IS NOT NULL then
    V_RESULTADO.frequenciadia := COALESCE(
      (
        SELECT
          f.frequenciadia
        FROM
          frequencia f
        where
          f.fkfrequencia = P_ORIGEM.fkfrequencia
        limit 1
			),
			P_ORIGEM.frequenciadia
		);
  else
    V_RESULTADO.frequenciadia = P_ORIGEM.frequenciadia;
	END IF;

	IF P_ORIGEM.fkfrequencia IS NULL THEN
		V_RESULTADO.fkfrequencia = '';
  else
    V_RESULTADO.fkfrequencia = P_ORIGEM.fkfrequencia;
	END IF;

  /**
  * UNIDADE MEDIDA
  */
	IF P_ORIGEM.fkunidademedida IS NULL THEN
		V_RESULTADO.fkunidademedida = '';
  else
    V_RESULTADO.fkunidademedida = P_ORIGEM.fkunidademedida;
	END IF;

  /**
  * PESO
  */
	IF P_ORIGEM.peso IS NULL THEN
		V_RESULTADO.peso = 999;
  else
    V_RESULTADO.peso = P_ORIGEM.peso;
	END IF;

  /**
  * DOSE
  */
  V_RESULTADO.idsegmento = (
    SELECT s.idsegmento FROM segmentosetor s
    WHERE s.fksetor = P_ORIGEM.fksetor
    AND s.fkhospital = P_ORIGEM.fkhospital
  );

	/**
  * DOSE
  */
  V_RESULTADO.doseconv = (
		select
			COALESCE (
				(
					select
						(P_ORIGEM.dose * u.fator) as doseconv
					FROM
						unidadeconverte u
					WHERE
						u.idsegmento = V_RESULTADO.idsegmento
						AND u.fkmedicamento = P_ORIGEM.fkmedicamento
						AND u.fkunidademedida = V_RESULTADO.fkunidademedida
				),
				P_ORIGEM.dose
			)
	);

  -- faixas
	V_DIVISOR := (
    select
      a.divisor
    FROM
      medatributos a
		WHERE
			a.fkmedicamento = P_ORIGEM.fkmedicamento
			AND a.idsegmento = V_RESULTADO.idsegmento
			AND a.divisor IS NOT null
	);

  IF V_DIVISOR IS NOT null and V_DIVISOR > 0 and V_RESULTADO.doseconv is not null THEN
    V_USAPESO := (
      select
        a.usapeso
      FROM
        medatributos a
      WHERE
        a.fkmedicamento = P_ORIGEM.fkmedicamento
        AND a.idsegmento = V_RESULTADO.idsegmento
        AND a.divisor IS NOT null
    );

    IF V_USAPESO IS TRUE THEN
      if V_RESULTADO.PESO > 0 and V_DIVISOR > 0 and V_RESULTADO.peso <> 999 and V_RESULTADO.peso is not null  then
        V_RESULTADO.doseconv := (SELECT CEIL(((V_RESULTADO.doseconv/V_RESULTADO.PESO)/V_DIVISOR)::numeric) * V_DIVISOR);
      else
        V_RESULTADO.doseconv := null;
      END IF;
    else
      V_RESULTADO.doseconv = COALESCE(CEIL(((V_RESULTADO.doseconv+0.1)/V_DIVISOR)::numeric) * V_DIVISOR, V_RESULTADO.doseconv);
    END IF;

  END IF;

  RESET search_path;
  RETURN V_RESULTADO;
END;
$function$;

-------

CREATE
OR REPLACE FUNCTION public.atualiza_prescricao(P_PARAMS public.PARAMETRO_TYPE, P_ORIGEM record) RETURNS public.PRESCRICAO_RESULTADO_TYPE LANGUAGE plpgsql AS $function$
DECLARE
  V_RESULTADO public.PRESCRICAO_RESULTADO_TYPE;
BEGIN
  if P_PARAMS.nome_schema is null or P_PARAMS.nome_schema = '' then
    RAISE EXCEPTION 'Parametro invalido: nome_schema';
  end if;

  EXECUTE FORMAT('SET search_path to %s;', P_PARAMS.nome_schema);

  IF P_ORIGEM.dtprescricao > P_ORIGEM.dtvigencia THEN
		V_RESULTADO.dtvigencia := P_ORIGEM.dtprescricao + interval '10 min';
  else
    V_RESULTADO.dtvigencia := P_ORIGEM.dtvigencia;
	END IF;

	V_RESULTADO.aggsetor := (
	  SELECT array_agg(DISTINCT elem)
	    FROM (
	      SELECT unnest(P_ORIGEM.aggsetor) AS elem
	      UNION ALL
	      SELECT P_ORIGEM.fksetor
	    ) t
  );

  /**
  * REGISTRAR CHECAGEM (utilizado para a flag checado anteriormente)
  */
  IF P_ORIGEM.status = 's' THEN
    INSERT INTO checkedindex
    (
      nratendimento, fkmedicamento, doseconv, frequenciadia, sletapas, slhorafase,
      sltempoaplicacao, sldosagem, dtprescricao, via, horario, dose, complemento
    )
    SELECT
      p.nratendimento, pm.fkmedicamento, pm.doseconv, pm.frequenciadia,
      COALESCE(pm.sletapas, 0), COALESCE(pm.slhorafase, 0),
      COALESCE(pm.sltempoaplicacao, 0), COALESCE(pm.sldosagem, 0),
      p.dtprescricao, COALESCE(pm.via, ''), COALESCE(left(pm.horario ,50), ''),
      pm.dose, MD5(pm.complemento)
    FROM prescricao p
    INNER JOIN presmed pm ON pm.fkprescricao = p.fkprescricao
    WHERE
      p.fkprescricao = P_ORIGEM.fkprescricao
      AND pm.dtsuspensao is null;

    -- limpa registros antigos para forçar revalidação
    DELETE FROM checkedindex WHERE dtprescricao < current_date - 15;
  END IF;

  RESET search_path;
  RETURN V_RESULTADO;
END;
$function$;
