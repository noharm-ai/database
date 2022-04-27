CREATE USER onlydemo WITH PASSWORD 'onlydemo';
GRANT CONNECT ON DATABASE postgres TO onlydemo;
GRANT USAGE ON SCHEMA demo TO onlydemo;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO onlydemo;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA demo TO onlydemo;
GRANT SELECT ON TABLE demo.usuario TO onlydemo;
GRANT DELETE ON TABLE demo.checkedindex TO onlydemo;
GRANT INSERT ON TABLE public.bulletin TO onlydemo;
GRANT USAGE, SELECT ON SEQUENCE public.bulletin_idbulletin_seq TO onlydemo;

-- na base de produção já tem o api_user, descomentar trecho abaixo APENAS se for criar um banco do ZERO
--CREATE USER api_user WITH PASSWORD 'userapi';
--GRANT CONNECT ON DATABASE postgres TO api_user;
--GRANT SELECT, UPDATE ON ALL TABLES IN SCHEMA public TO api_user;
--GRANT USAGE ON SCHEMA public TO api_user;

GRANT USAGE ON SCHEMA demo TO api_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO api_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA demo TO api_user;
GRANT DELETE ON demo.segmentosetor TO api_user;
GRANT DELETE ON demo.outlier TO api_user;
GRANT SELECT, INSERT, DELETE ON TABLE demo.checkedindex TO api_user;
