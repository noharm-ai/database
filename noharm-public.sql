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

/**
* CUSTOM TYPES
*/
CREATE TYPE public.PARAMETRO_TYPE AS (nome_schema TEXT, skip_list TEXT [ ], features TEXT [ ]);

CREATE TYPE public.PRESMED_RESULTADO_TYPE AS (
  nratendimento BIGINT,
  idsegmento int2,
  idoutlier int4,
  origem TEXT,
  sonda BOOLEAN,
  intravenosa BOOLEAN,
  aprox BOOLEAN,
  checado BOOLEAN,
  frequenciadia float4,
  doseconv float4,
  escorefinal int2,
  periodo int2,
  cpoe_grupo int8
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

CREATE
OR REPLACE FUNCTION public.complete_presmed(
  P_PARAMS public.PARAMETRO_TYPE,
  P_PRESMED_ORIGEM record
) RETURNS public.PRESMED_RESULTADO_TYPE LANGUAGE plpgsql AS $function$
DECLARE
  PRESMED_RESULTADO public.PRESMED_RESULTADO_TYPE;
  V_DIVISOR float;
  V_USAPESO boolean;
  V_PESO float;
  V_NUMHOSPITAL int;
BEGIN
  if P_PARAMS.nome_schema is null or P_PARAMS.nome_schema = '' then
    RAISE EXCEPTION 'Parametro invalido: nome_schema'; 
  end if;

  EXECUTE FORMAT('SET search_path to %s;', P_PARAMS.nome_schema);

  /**
  * PARAMETROS
  */
  V_NUMHOSPITAL := (
    SELECT p.fkhospital FROM prescricao p
    WHERE p.fkprescricao = P_PRESMED_ORIGEM.fkprescricao
  );
  PRESMED_RESULTADO.nratendimento := (select nratendimento from prescricao pp where pp.fkprescricao = P_PRESMED_ORIGEM.fkprescricao limit 1);

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
        when tipo = 'map-origin-custom' then PRESMED_RESULTADO.origem
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
          AND f.fkhospital = V_NUMHOSPITAL
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
    PRESMED_RESULTADO.periodo := (
      with vigencias as (
        select
          prescricao.dtprescricao::date dtinicial, 
          case 
            when coalesce(max(presmed.dtsuspensao)::date,  max(prescricao.dtvigencia)::date) > now()::date then now()::date
            else coalesce(max(presmed.dtsuspensao)::date,  max(prescricao.dtvigencia)::date)
          end as dtfinal
        FROM 
          presmed 
          JOIN prescricao ON prescricao.fkprescricao = presmed.fkprescricao 
          JOIN medicamento ON medicamento.fkmedicamento = presmed.fkmedicamento
        WHERE 
          prescricao.nratendimento = PRESMED_RESULTADO.nratendimento
          AND presmed.fkmedicamento = P_PRESMED_ORIGEM.fkmedicamento
          and prescricao.fkprescricao < P_PRESMED_ORIGEM.fkprescricao
          and prescricao.dtprescricao > current_date - interval '120' day
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
          -- desconsidera se o intervalo for mair que 24h
          when (extract(epoch from (select dtprescricao from prescricao pp where pp.fkprescricao = P_PRESMED_ORIGEM.fkprescricao limit 1) - max(dia))/3600) > 24 then 0
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

  if 'CPOE' = any(coalesce(P_PARAMS.features, array[]::text[])) then
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
  end if;

  if 'AUDIT' != all(coalesce(P_PARAMS.skip_list, array[]::text[])) then
    insert into presmed_audit 
      (tp_audit, fkpresmed, created_at, created_by) 
      values 
      (2, P_PRESMED_ORIGEM.fkpresmed, now(), 0);
  end if;
  
  RESET search_path;
  RETURN PRESMED_RESULTADO;
END;
$function$;

----------

CREATE
OR REPLACE FUNCTION public.complete_prescricao(P_PARAMS public.PARAMETRO_TYPE, P_ORIGEM record) RETURNS public.PRESCRICAO_RESULTADO_TYPE LANGUAGE plpgsql AS $function$
DECLARE
  V_RESULTADO public.PRESCRICAO_RESULTADO_TYPE;
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

  IF P_ORIGEM.dtprescricao > P_ORIGEM.dtvigencia THEN
    V_RESULTADO.dtvigencia := P_ORIGEM.dtprescricao + interval '10 min';
  else
    V_RESULTADO.dtvigencia := P_ORIGEM.dtvigencia;
  END IF;

  if 'CPOE' = any(coalesce(P_PARAMS.features, array[]::text[])) then
    UPDATE 
      prescricao p
    set 
      aggsetor = array_append(aggsetor, P_ORIGEM.fksetor),
      fksetor = P_ORIGEM.fksetor,
      leito = P_ORIGEM.leito,
      status = '0',
      update_at = now()
    where 
      nratendimento = P_ORIGEM.nratendimento
      and dtprescricao = P_ORIGEM.dtprescricao::date
      and agregada is not null;
  end if;
  
  RESET search_path;
  RETURN V_RESULTADO;
END;
$function$;

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
          AND f.fkhospital = P_ORIGEM.fkhospital
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
    V_RESULTADO.fkunidademedida = P_ORIGEM.fkfrequencia;
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

	V_RESULTADO.aggsetor = P_ORIGEM.aggsetor || P_ORIGEM.fksetor;
  
  RESET search_path;
  RETURN V_RESULTADO;
END;
$function$;