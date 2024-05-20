CREATE USER demo_user WITH PASSWORD 'demo_user';
GRANT CONNECT ON DATABASE postgres TO demo_user;
GRANT USAGE ON SCHEMA demo TO demo_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO demo_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA demo TO demo_user;
GRANT SELECT ON TABLE demo.usuario, demo.prescricao_audit, demo.presmed_audit TO demo_user;
GRANT DELETE ON TABLE demo.checkedindex TO demo_user;
GRANT INSERT ON TABLE public.bulletin, demo.prescricao_audit, demo.presmed_audit TO demo_user;
GRANT USAGE, SELECT ON SEQUENCE public.bulletin_idbulletin_seq TO demo_user;

-- na base de produção já tem o api_user, descomentar trecho abaixo APENAS se for criar um banco do ZERO
CREATE USER api_user WITH PASSWORD 'userapi'; -- necessário para os testes automatizados
CREATE USER noharmcare WITH PASSWORD 'noharmcare'; -- necessário para os testes automatizados
-- GRANT CONNECT ON DATABASE postgres TO api_user;
-- GRANT SELECT, UPDATE ON ALL TABLES IN SCHEMA public TO api_user;
-- GRANT USAGE ON SCHEMA public TO api_user;

GRANT USAGE ON SCHEMA demo TO api_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO api_user;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA demo TO api_user;
GRANT DELETE ON demo.segmentosetor TO api_user;
GRANT DELETE ON demo.outlier TO api_user;
GRANT SELECT, INSERT, DELETE ON TABLE demo.checkedindex TO api_user;
GRANT SELECT, UPDATE, INSERT, DELETE ON demo.prescricaoagg TO api_user;

-- descomentar trecho abaixo APENAS se for criar um banco do ZERO (estes recursos não existem no ambiente de teste automatizado)
/*GRANT USAGE ON SCHEMA demo TO readnoharm;
GRANT SELECT ON ALL TABLES IN SCHEMA demo TO readnoharm;

GRANT USAGE ON SCHEMA demo TO noharm_care;
GRANT SELECT, UPDATE ON demo.evolucao TO noharm_care;

GRANT USAGE ON SCHEMA demo TO batch_reports_noharm;
GRANT SELECT ON ALL TABLES IN SCHEMA demo TO batch_reports_noharm;
GRANT UPDATE ON demo.intervencao TO batch_reports_noharm;

GRANT USAGE ON SCHEMA demo TO nifi_user;
GRANT SELECT, UPDATE, INSERT, DELETE ON demo.prescricaoagg TO nifi_user;
GRANT SELECT, UPDATE, INSERT ON demo.medatributos TO nifi_user;
GRANT SELECT, INSERT ON demo.prescricao_arquivo, demo.presmed_arquivo, demo.exame_arquivo TO nifi_user;
GRANT SELECT, DELETE ON demo.prescricao, demo.presmed, demo.exame TO nifi_user;
GRANT INSERT, UPDATE ON demo.prescricao TO nifi_user;
GRANT UPDATE ON demo.presmed TO nifi_user;
GRANT SELECT ON ALL TABLES IN SCHEMA demo TO nifi_user;

GRANT USAGE ON SCHEMA hsc_test TO demo_user;
GRANT SELECT ON TABLE hsc_test.medatributos, hsc_test.motivointervencao TO demo_user;

insert into public.schema_config (schema_name, created_at) values ('demo', now());

INSERT INTO demo.segmento (nome, status) values ('Adulto', 0) on conflict do nothing;

--Adicionar na tabela nomedocliente.memoria:
INSERT INTO demo.memoria (tipo, valor, update_at, update_by) 
VALUES('getnameurl', '{"value":"https://demo.getname.noharm.ai/patient-name/{idPatient}", "multiple": "https://demo.getname.noharm.ai/patient-name/multiple"}'::json, now(), 0)
on conflict do nothing;

--Revisar as origens quando o cliente não for Tasy
INSERT INTO demo.memoria (tipo, valor, update_at, update_by) VALUES
('features', '["MICROMEDEX", "CONCILIATION", "NOHARMCARE"]'::json, now(), 0),
('map-origin-drug', '["Medicamentos"]'::json, now(), 0),
('map-origin-solution', '["Solu\u00e7\u00f5es"]'::json, now(), 0),
('map-origin-procedure', '["Proced/Exames"]'::json, now(), 0),
('map-origin-diet', '["Dietas"]'::json, now(), 0)
on conflict do nothing;
*/
