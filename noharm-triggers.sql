-------------------------------------
-------- UPDATE SELF TABLES --------
-------------------------------------

CREATE OR REPLACE FUNCTION demo.complete_presmed()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
  DIVISOR float;
  USAPESO boolean;
  PESO float;
  NUMHOSPITAL int;
BEGIN

  IF pg_trigger_depth() = 1 then
  
    -- lista de origens configuradas pela interface
    NEW.origem := (
  		select 
        case 
          when tipo = 'map-origin-drug' then 'Medicamentos'
          when tipo = 'map-origin-solution' then 'Soluções'
          when tipo = 'map-origin-procedure' then 'Proced/Exames'
          when tipo = 'map-origin-diet' then 'Dietas'
          when tipo = 'map-origin-custom' then NEW.origem
          else 'Medicamentos' 			
        end as origem
      from (
        select 
          jsonb_array_elements_text(valor::jsonb) valor,
          tipo 
        from 
          demo.memoria m 
        where 
          tipo in (
            'map-origin-drug', 'map-origin-solution', 
            'map-origin-procedure', 'map-origin-diet',
            'map-origin-custom'
          )
      ) o
      where 
        valor = NEW.origem
      limit 1
  	);
  
  	if NEW.origem is null then
  		NEW.origem := 'Medicamentos';
  	end if;

    -- lista de vias configuradas pela interface
    IF NEW.via in (select jsonb_array_elements_text(valor::jsonb) from demo.memoria m where tipo = 'map-tube') THEN
           NEW.sonda := TRUE;
    END IF; 
   
   -- lista de vias configuradas pela interface
    IF NEW.via in (select jsonb_array_elements_text(valor::jsonb) from demo.memoria m where tipo = 'map-iv') THEN
           NEW.intravenosa := TRUE;
    END IF; 

    NUMHOSPITAL := (
        SELECT p.fkhospital FROM demo.prescricao p
        WHERE p.fkprescricao = NEW.fkprescricao
    );

    -- Medicamentos com Frequência
    IF NEW.fkfrequencia IS NOT NULL then
	    NEW.frequenciadia := COALESCE(
	    	(
		        SELECT f.frequenciadia FROM demo.frequencia f
		        WHERE f.fkfrequencia = NEW.fkfrequencia
	           	AND f.fkhospital = NUMHOSPITAL
			),
			new.frequenciadia
		);
    END IF;

    -- Soluções com Etapa
    IF NEW.frequenciadia IS NULL THEN NEW.frequenciadia := NEW.sletapas; END IF;

    -- Medicamentos com Horário
    IF NEW.frequenciadia IS NULL AND NEW.horario IS NOT NULL AND NEW.origem = 'Medicamentos' THEN
          NEW.frequenciadia := ( SELECT array_length(string_to_array(trim(NEW.horario), ' '), 1) );
          IF NEW.horario = 'ACM' THEN NEW.frequenciadia := 44; END IF;
          IF NEW.horario = 'SN' THEN NEW.frequenciadia := 33; END IF;
    END IF;

    -- Soluções com Horário
    IF NEW.frequenciadia IS NULL AND NEW.horario IS NOT NULL AND NEW.origem = 'Soluções' THEN
          NEW.frequenciadia := ( SELECT array_length(string_to_array(trim(NEW.horario), 'das'), 1)-1 );
    END IF;

    -- Soluções ACM
    IF NEW.frequenciadia IS NULL AND NEW.slacm = 'S' AND NEW.origem = 'Soluções' THEN
          NEW.frequenciadia := 44;
    END IF;

    -- Medicamento sem Frequência
    IF NEW.frequenciadia IS NULL THEN
          NEW.frequenciadia := 99;
    END IF;

    NEW.idsegmento := (
        SELECT p.idsegmento FROM demo.prescricao p
        WHERE p.fkprescricao = NEW.fkprescricao
    );

    NEW.doseconv := ( SELECT COALESCE (
		(SELECT (NEW.dose * u.fator) as doseconv
		FROM demo.unidadeconverte u
		WHERE u.idsegmento = NEW.idsegmento
		AND u.fkmedicamento = NEW.fkmedicamento 
		AND u.fkunidademedida = NEW.fkunidademedida )
    , NEW.dose ) );


    -- Medicamento com Faixa de Valores para Outliers
    DIVISOR := (SELECT a.divisor FROM demo.medatributos a
                WHERE a.fkmedicamento = NEW.fkmedicamento 
                  AND a.idsegmento = NEW.idsegmento
                  AND a.divisor IS NOT NULL);

    IF DIVISOR IS NOT NULL THEN

      PESO := 1;

      USAPESO := (SELECT a.usapeso FROM demo.medatributos a
                  WHERE a.fkmedicamento = NEW.fkmedicamento 
                    AND a.idsegmento = NEW.idsegmento
                    AND a.divisor IS NOT NULL);

      IF USAPESO IS TRUE THEN

        PESO := ( SELECT COALESCE (
          ( SELECT pe.peso FROM demo.pessoa pe
          INNER JOIN demo.prescricao pr ON pr.nratendimento = pe.nratendimento
          WHERE pr.fkprescricao = NEW.fkprescricao AND pe.peso > 0 )
          , 1 ) );

      END IF;

      IF PESO > 0 AND DIVISOR > 0 THEN
        NEW.doseconv := (SELECT CEIL(((NEW.doseconv/PESO)/DIVISOR)::numeric) * DIVISOR);
      END IF;

    END IF;


    -- Define Outliers para os Medicamentos

    NEW.idoutlier := (
        SELECT MAX(o.idoutlier) FROM demo.outlier o 
        WHERE o.fkmedicamento = NEW.fkmedicamento
        AND o.doseconv = NEW.doseconv
        AND o.frequenciadia = NEW.frequenciadia
        AND o.idsegmento = NEW.idsegmento
    );

    IF NEW.idoutlier IS NULL AND NEW.doseconv > 0 THEN
        NEW.idoutlier := (SELECT demo.similaridade(
    		NEW.idsegmento,
    		NEW.fkmedicamento,
    		NEW.doseconv, 
    		NEW.frequenciadia));
        IF NEW.idoutlier IS not NULL then
          NEW.aprox := true;
        END IF;
    END IF;

    NEW.escorefinal := (
        SELECT COALESCE(escoremanual, escore)
        FROM demo.outlier
        WHERE idoutlier = NEW.idoutlier
    );

    NEW.checado := (
        SELECT true FROM demo.checkedindex
        WHERE nratendimento = (select nratendimento from demo.prescricao pp where pp.fkprescricao = NEW.fkprescricao limit 1)
        and fkmedicamento = NEW.fkmedicamento
        AND doseconv = NEW.doseconv
        AND frequenciadia = NEW.frequenciadia
        AND sletapas = COALESCE(NEW.sletapas, 0)
        AND slhorafase = COALESCE(NEW.slhorafase, 0)
        AND sltempoaplicacao = COALESCE(NEW.sltempoaplicacao, 0)
        AND sldosagem = COALESCE(NEW.sldosagem, 0)
        AND via = COALESCE(NEW.via, '')
        AND horario = COALESCE(left(NEW.horario ,50), '')
        and dose = NEW.dose
        LIMIT 1
    );

    NEW.periodo := (
        SELECT count(distinct(pr2.dtprescricao::date)) FROM demo.presmed p2
        INNER JOIN demo.prescricao pr2 ON pr2.fkprescricao < NEW.fkprescricao
          AND pr2.nratendimento = (select nratendimento from demo.prescricao pp where pp.fkprescricao = NEW.fkprescricao limit 1)
          AND pr2.fkprescricao = p2.fkprescricao 
        WHERE p2.fkmedicamento = NEW.fkmedicamento
        AND pr2.dtprescricao > current_date - interval '30' day
    );

    -- periodo CPOE
    -- busca quantidade de dias anteriores à prescricao atual
    /*
    NEW.periodo := (
      select 
        coalesce(sum(case when end_date - ini_date = 0 then 1 else end_date - ini_date end), 0) as periodo
      from (
        select 
          ini_date, max(end_date) as end_date
        from (
          select
            distinct
            max(dtprescricao::date) as ini_date,
            case 
							when coalesce(max(presmed.dtsuspensao)::date,  max(prescricao.dtvigencia)::date) > now()::date then now()::date
							else coalesce(max(presmed.dtsuspensao)::date,  max(prescricao.dtvigencia)::date)
						end as end_date
          FROM demo.presmed 
            JOIN demo.prescricao ON prescricao.fkprescricao = presmed.fkprescricao 
          WHERE 
            prescricao.nratendimento = (select nratendimento from demo.prescricao pp where pp.fkprescricao = NEW.fkprescricao limit 1)
            AND presmed.fkmedicamento = NEW.fkmedicamento
            and prescricao.fkprescricao < NEW.fkprescricao
          GROUP BY prescricao.dtprescricao, presmed.frequenciadia, presmed.dose, presmed.fkunidademedida 
        ) periodos
        group by 
          ini_date
      ) periodo_agrupado
      where
        end_date - ini_date >= 0
    );
    */

   -- Trecho do caso CPOE
   /*if new.cpoe_nrseq_anterior is null then
   		new.cpoe_grupo := new.cpoe_nrseq;
   else
   		NEW.cpoe_grupo := (
   			select coalesce((select cpoe_grupo  
   			from demo.presmed
   			where cpoe_nrseq = new.cpoe_nrseq_anterior
   			limit 1), new.cpoe_nrseq)
   		);
   END IF;*/

   INSERT INTO demo.presmed (fkprescricao, fkpresmed, fkfrequencia, fkmedicamento, 
	   fkunidademedida, dose, frequenciadia, via, idsegmento, doseconv, idoutlier, escorefinal,
	   origem, dtsuspensao, horario, complemento, aprox, checado, periodo,
	   slagrupamento, slacm, sletapas, slhorafase, sltempoaplicacao, sldosagem, sltipodosagem, 
       alergia, sonda, intravenosa, cpoe_grupo, cpoe_nrseq, cpoe_nrseq_anterior)
  
   VALUES (NEW.fkprescricao, NEW.fkpresmed, NEW.fkfrequencia, NEW.fkmedicamento, 
	   NEW.fkunidademedida, NEW.dose, NEW.frequenciadia, NEW.via, NEW.idsegmento, NEW.doseconv, NEW.idoutlier, NEW.escorefinal,
	   NEW.origem, NEW.dtsuspensao, NEW.horario, NEW.complemento, NEW.aprox, NEW.checado, NEW.periodo,
	   NEW.slagrupamento, NEW.slacm, NEW.sletapas, NEW.slhorafase, NEW.sltempoaplicacao, NEW.sldosagem, 
       NEW.sltipodosagem, NEW.alergia, NEW.sonda, NEW.intravenosa, NEW.cpoe_grupo, NEW.cpoe_nrseq, NEW.cpoe_nrseq_anterior)
       ON CONFLICT (fkpresmed) 
         DO UPDATE SET dtsuspensao = NEW.dtsuspensao,
         frequenciadia = NEW.frequenciadia,
         periodo = NEW.periodo,
         checado = NEW.checado,
         idoutlier = NEW.idoutlier,
         doseconv = NEW.doseconv,
         escorefinal = NEW.escorefinal;
      
    RETURN NULL;
 ELSE
    RETURN NEW;
 END IF; 

END;$BODY$;

ALTER FUNCTION demo.complete_presmed()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_presmed ON demo.presmed;
		     
CREATE TRIGGER trg_complete_presmed
    BEFORE INSERT 
    ON demo.presmed
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_presmed();

--------

CREATE OR REPLACE  FUNCTION demo.complete_prescricao()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
   IF pg_trigger_depth() = 1 then
	NEW.idsegmento = (
		SELECT s.idsegmento FROM demo.segmentosetor s
		WHERE s.fksetor = NEW.fksetor
		AND s.fkhospital = NEW.fkhospital
	);

	IF NEW.dtprescricao > NEW.dtvigencia THEN
		NEW.dtvigencia := NEW.dtprescricao + interval '10 min';
	END IF;

	UPDATE demo.prescricao p
	set aggsetor = array_append(aggsetor, NEW.fksetor),
	fksetor = NEW.fksetor,
	leito = NEW.leito,
	status = '0'
	where nratendimento = NEW.nratendimento
	and dtprescricao = NEW.dtprescricao::date
	and agregada is not null;
	
        INSERT INTO demo.prescricao (fkhospital, fkprescricao, fkpessoa, nratendimento, fksetor, dtprescricao, idsegmento, 
				     leito, prontuario, dtvigencia, prescritor, agregada, indicadores, aggsetor, aggmedicamento, 
				     concilia, convenio, dtatualizacao) 
            VALUES (NEW.fkhospital, NEW.fkprescricao, NEW.fkpessoa, NEW.nratendimento, NEW.fksetor, NEW.dtprescricao, NEW.idsegmento, 
		    NEW.leito, NEW.prontuario, NEW.dtvigencia, NEW.prescritor, NEW.agregada, NEW.indicadores, NEW.aggsetor, NEW.aggmedicamento, 
		    NEW.concilia, NEW.convenio, NEW.dtatualizacao)
            ON CONFLICT (fkprescricao)
            DO UPDATE SET fkpessoa = NEW.fkpessoa,
                    fksetor = NEW.fksetor,
                    dtprescricao = NEW.dtprescricao,
                    idsegmento = NEW.idsegmento,
                    dtatualizacao = NEW.dtatualizacao
	       WHERE demo.prescricao.status <> 's';

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;  
END;$BODY$;

ALTER FUNCTION demo.complete_prescricao()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_prescricao ON demo.prescricao;
		     
CREATE TRIGGER trg_complete_prescricao
    BEFORE INSERT 
    ON demo.prescricao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_prescricao();

--------

CREATE OR REPLACE  FUNCTION demo.atualiza_escore_presemed()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
    IF NEW.status = 's' THEN

        INSERT INTO demo.checkedindex
            (
              nratendimento, fkmedicamento, doseconv, frequenciadia, sletapas, slhorafase,
              sltempoaplicacao, sldosagem, dtprescricao, via, horario, dose
            )
            SELECT p.nratendimento, pm.fkmedicamento, pm.doseconv, pm.frequenciadia, 
            COALESCE(pm.sletapas, 0), COALESCE(pm.slhorafase, 0), 
            COALESCE(pm.sltempoaplicacao, 0), COALESCE(pm.sldosagem, 0),
            p.dtprescricao, COALESCE(pm.via, ''), COALESCE(left(pm.horario ,50), ''),
            pm.dose
            FROM demo.prescricao p
            INNER JOIN demo.presmed pm ON pm.fkprescricao = p.fkprescricao 
            WHERE p.status = 's'
            AND p.fkprescricao = NEW.fkprescricao
            AND pm.dtsuspensao is null;

        DELETE FROM demo.checkedindex
            WHERE dtprescricao < current_date - 15;

    END IF;
    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.atualiza_escore_presemed()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_atualiza_escore_presemed ON demo.prescricao;
		     
CREATE TRIGGER trg_atualiza_escore_presemed
    AFTER UPDATE
    ON demo.prescricao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.atualiza_escore_presemed();

--------

CREATE OR REPLACE FUNCTION demo.complete_prescricaoagg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

    IF NEW.frequenciadia IS NULL AND NEW.fkfrequencia IS NOT NULL THEN
            NEW.frequenciadia := (
                SELECT f.frequenciadia FROM demo.frequencia f
                WHERE f.fkfrequencia = NEW.fkfrequencia
            );
    END IF;
   
   IF NEW.peso IS NULL THEN
   		NEW.peso = 999;
   END IF;

    NEW.idsegmento = ( SELECT COALESCE (NEW.idsegmento, (
        SELECT s.idsegmento FROM demo.segmentosetor s
        WHERE s.fksetor = NEW.fksetor
        AND s.fkhospital = NEW.fkhospital)
    ) );

    NEW.doseconv = ( SELECT COALESCE (
		(SELECT (NEW.dose * u.fator) as doseconv
		FROM demo.unidadeconverte u
		WHERE u.idsegmento = NEW.idsegmento 
		AND u.fkmedicamento = NEW.fkmedicamento 
		AND u.fkunidademedida = NEW.fkunidademedida )
    , NEW.dose ) );
   
   IF pg_trigger_depth() = 1 then

        INSERT INTO demo.prescricaoagg
            (fkhospital, fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, frequenciadia, peso, contagem, doseconv)
            VALUES(NEW.fkhospital, NEW.fksetor, NEW.fkmedicamento, NEW.fkunidademedida, NEW.fkfrequencia, NEW.dose, NEW.frequenciadia, NEW.peso, NEW.contagem, NEW.doseconv)
        ON CONFLICT (fksetor, fkmedicamento, fkunidademedida, fkfrequencia, dose, peso)
         DO UPDATE SET contagem = NEW.contagem, doseconv = NEW.doseconv, idsegmento = NEW.idsegmento, frequenciadia = NEW.frequenciadia;

      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   

END;$BODY$;

ALTER FUNCTION demo.complete_prescricaoagg()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_prescricaoagg ON demo.prescricaoagg;

CREATE TRIGGER trg_complete_prescricaoagg
    BEFORE INSERT 
    ON demo.prescricaoagg
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_prescricaoagg();

--------

CREATE OR REPLACE FUNCTION demo.complete_frequencia()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

    IF NEW.frequenciadia IS NULL AND NEW.frequenciahora IS NOT NULL AND NEW.frequenciahora <> 0 THEN
            NEW.frequenciadia := 24 / NEW.frequenciahora;
    END IF;

   IF pg_trigger_depth() = 1 then
      INSERT INTO demo.frequencia (fkhospital, fkfrequencia, nome, frequenciadia, frequenciahora) 
            VALUES(NEW.fkhospital, NEW.fkfrequencia, NEW.nome, NEW.frequenciadia, NEW.frequenciahora)
         ON CONFLICT (fkhospital, fkfrequencia)
         DO NOTHING;
      RETURN NULL;
   ELSE
      RETURN NEW;
   END IF;   

END;$BODY$;

ALTER FUNCTION demo.complete_frequencia()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_frequencia ON demo.frequencia;
		     
CREATE TRIGGER trg_complete_frequencia
    BEFORE INSERT 
    ON demo.frequencia
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_frequencia();

-------------------------------------
-------- UPDATE CHILD TABLES --------
-------------------------------------

CREATE OR REPLACE FUNCTION demo.popula_presmed_by_frequencia()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
    UPDATE demo.presmed pm
        SET frequenciadia = NEW.frequenciadia
    WHERE pm.fkfrequencia = NEW.fkfrequencia;
    -- AND pm.escorefinal IS NULL;
    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.popula_presmed_by_frequencia()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_popula_presmed_by_frequencia ON demo.frequencia;
		     
CREATE TRIGGER trg_popula_presmed_by_frequencia
    AFTER INSERT 
    ON demo.frequencia
    FOR EACH ROW
    EXECUTE PROCEDURE demo.popula_presmed_by_frequencia();

--------

CREATE OR REPLACE FUNCTION demo.propaga_idsegmento()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
   
    UPDATE demo.prescricao p
        SET idsegmento = NEW.idsegmento
        WHERE p.fksetor = NEW.fksetor
        AND p.fkhospital = NEW.fkhospital
        AND (p.status IS null or p.status = '0')
        AND p.dtprescricao > current_date - 2;
       
    UPDATE demo.presmed pm
        SET idsegmento = NEW.idsegmento
        WHERE pm.fkprescricao in (
            SELECT p.fkprescricao FROM demo.prescricao p
            WHERE p.idsegmento = NEW.idsegmento
            AND p.dtprescricao > current_date - 2
            );
        -- AND pm.escorefinal IS NULL;

    UPDATE demo.prescricaoagg pa
        SET idsegmento = NEW.idsegmento
            WHERE pa.fksetor = NEW.fksetor
            AND pa.fkhospital = NEW.fkhospital;

    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.propaga_idsegmento()
    OWNER TO postgres;
		     
DROP TRIGGER IF EXISTS trg_propaga_idsegmento ON demo.segmentosetor;

CREATE TRIGGER trg_propaga_idsegmento
    AFTER INSERT
    ON demo.segmentosetor
    FOR EACH ROW
    EXECUTE PROCEDURE demo.propaga_idsegmento();

    --------

CREATE OR REPLACE FUNCTION demo.deleta_idsegmento()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

    UPDATE demo.presmed pm
        SET idsegmento = NULL
        WHERE pm.fkprescricao in (
            SELECT p.fkprescricao FROM demo.prescricao p
            WHERE p.fksetor = NEW.fksetor
            AND p.fkhospital = NEW.fkhospital
            AND p.dtprescricao > current_date - 2
            );   
        -- AND pm.escorefinal IS NULL;
   
    UPDATE demo.prescricao p
        SET idsegmento = NULL
        WHERE p.fksetor = NEW.fksetor
        AND p.fkhospital = NEW.fkhospital
        AND p.dtprescricao > current_date - 2
        AND (p.status IS null or p.status = '0');
       
    UPDATE demo.prescricaoagg pa
        SET idsegmento = NULL
            WHERE pa.fksetor = NEW.fksetor
            AND pa.fkhospital = NEW.fkhospital;

    RETURN OLD;
END;$BODY$;

ALTER FUNCTION demo.deleta_idsegmento()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_deleta_idsegmento ON demo.segmentosetor;
		     
CREATE TRIGGER trg_deleta_idsegmento
    BEFORE DELETE
    ON demo.segmentosetor
    FOR EACH ROW
    EXECUTE PROCEDURE demo.deleta_idsegmento();

-----------------

CREATE OR REPLACE  FUNCTION demo.atualiza_divisor()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

      UPDATE demo.prescricaoagg pa
        SET doseconv = ( SELECT COALESCE (
          ( SELECT (pa.dose * un.fator) as doseconv
            FROM demo.unidadeconverte un
            WHERE un.fkmedicamento = pa.fkmedicamento
            AND un.fkunidademedida = pa.fkunidademedida
            AND un.idsegmento = NEW.idsegmento) 
          , pa.dose) )
        WHERE pa.fkmedicamento = NEW.fkmedicamento
        AND pa.idsegmento = NEW.idsegmento;

    IF NEW.divisor IS NOT NULL THEN  

      IF NEW.usapeso = true THEN 

        UPDATE demo.prescricaoagg pa
          SET doseconv = COALESCE ( CEIL((((pa.doseconv+0.1)/pa.peso)/NEW.divisor)::numeric) * NEW.divisor, pa.doseconv)
          WHERE pa.fkmedicamento = NEW.fkmedicamento
          AND pa.idsegmento = NEW.idsegmento
          AND pa.peso != 999 and pa.peso >= 0.5
          AND doseconv is not null;

        UPDATE demo.prescricaoagg pa
          SET doseconv = NULL
          WHERE pa.fkmedicamento = NEW.fkmedicamento
          AND pa.idsegmento = NEW.idsegmento
          AND (pa.peso = 999 or pa.peso < 0.5 or pa.peso IS NULL);

      ELSE

        UPDATE demo.prescricaoagg pa
          SET doseconv = COALESCE ( CEIL(((pa.doseconv+0.1)/NEW.divisor)::numeric) * NEW.divisor, pa.doseconv)
          WHERE pa.fkmedicamento = NEW.fkmedicamento
          AND pa.idsegmento = NEW.idsegmento
          AND doseconv is not null;

      END IF;

    END IF;

    RETURN NULL;
END;$BODY$;

ALTER FUNCTION demo.atualiza_divisor()
    OWNER TO postgres;
    
DROP TRIGGER IF EXISTS trg_atualiza_divisor_on_insert ON demo.medatributos;

CREATE TRIGGER trg_atualiza_divisor_on_insert
    AFTER INSERT
    ON demo.medatributos
    FOR EACH ROW
    EXECUTE PROCEDURE demo.atualiza_divisor();
    
DROP TRIGGER IF EXISTS trg_atualiza_divisor_on_update ON demo.medatributos;

CREATE TRIGGER trg_atualiza_divisor_on_update
    AFTER UPDATE
    ON demo.medatributos
    FOR EACH ROW
    WHEN (OLD.divisor IS DISTINCT FROM NEW.divisor) 
    EXECUTE PROCEDURE demo.atualiza_divisor();

CREATE OR REPLACE FUNCTION demo.insert_update_evolucao()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
 TEST_EXISTS int8;
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

-----------------

CREATE OR REPLACE FUNCTION demo.similaridade (p_idsegmento int2, p_fkmedicamento int8, p_doseconv float4, p_frequenciadia float4)
    RETURNS int4
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE r_idoutlier int4 default null;
BEGIN

	SELECT (idoutlier) INTO r_idoutlier
	from 
	(	
		SELECT o.idoutlier,
			1 - ( (o.doseconv * p_doseconv + o.frequenciadia * p_frequenciadia) / (sqrt( power(o.doseconv,2) + power(o.frequenciadia,2) ) *
			sqrt( power(p_doseconv,2) + power(p_frequenciadia,2)) ) ) as cosine,
			sqrt(power(o.doseconv - p_doseconv,2) + power(o.frequenciadia - p_frequenciadia,2)) as euclidian
		FROM demo.outlier o
		WHERE o.idsegmento = p_idsegmento
		and o.fkmedicamento = p_fkmedicamento
    and o.doseconv > 0 and o.frequenciadia > 0
	) as t
	ORDER BY cosine asc, euclidian asc
	LIMIT 1;
	
    RETURN r_idoutlier;
END;$BODY$;

ALTER FUNCTION demo.similaridade(int2, int8, float4, float4)
    OWNER TO postgres;

--------

CREATE OR REPLACE  FUNCTION demo.complete_intervencao_cpoe()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

		NEW.fksetor = (
		    SELECT fksetor FROM demo.prescricao p
		    WHERE p.nratendimento = NEW.nratendimento
		    ORDER BY p.dtprescricao
            LIMIT 1
		);	

      RETURN NEW;

END;$BODY$;

ALTER FUNCTION demo.complete_intervencao_cpoe()
    OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_complete_intervencao_cpoe ON demo.intervencao;
		     
CREATE TRIGGER trg_complete_intervencao_cpoe
    BEFORE INSERT 
    ON demo.intervencao
    FOR EACH ROW
    EXECUTE PROCEDURE demo.complete_intervencao_cpoe();

--------
