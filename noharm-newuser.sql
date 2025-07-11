-- usar somente para testes automatizados

CREATE USER demo_user WITH PASSWORD 'demo_user' CONNECTION LIMIT 10;
ALTER ROLE demo_user SET statement_timeout = 10000;
GRANT CONNECT ON DATABASE postgres TO demo_user;
GRANT USAGE ON SCHEMA demo TO demo_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO demo_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA demo TO demo_user;
GRANT SELECT ON TABLE demo.usuario, demo.prescricao_audit, demo.presmed_audit TO demo_user;
GRANT DELETE ON TABLE demo.checkedindex TO demo_user;
GRANT INSERT ON TABLE public.bulletin, demo.prescricao_audit, demo.presmed_audit TO demo_user;
GRANT USAGE, SELECT ON SEQUENCE public.bulletin_idbulletin_seq TO demo_user;

CREATE USER api_user WITH PASSWORD 'userapi'; -- necessário para os testes automatizados
CREATE USER noharmcare WITH PASSWORD 'noharmcare'; -- necessário para os testes automatizados

GRANT USAGE ON SCHEMA demo TO api_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO api_user;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA demo TO api_user;
GRANT DELETE ON demo.segmentosetor TO api_user;
GRANT DELETE ON demo.outlier TO api_user;
GRANT SELECT, INSERT, DELETE ON TABLE demo.checkedindex TO api_user;
GRANT SELECT, UPDATE, INSERT, DELETE ON demo.prescricaoagg TO api_user;