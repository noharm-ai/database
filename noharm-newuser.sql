CREATE USER readall WITH PASSWORD 'readall';
GRANT CONNECT ON DATABASE postgres TO readall;

GRANT USAGE ON SCHEMA demo TO readall;
GRANT SELECT ON ALL TABLES IN SCHEMA demo TO readall;

GRANT USAGE ON SCHEMA public TO readall;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readall;

CREATE USER onlydemo WITH PASSWORD 'onlydemo';
GRANT CONNECT ON DATABASE postgres TO onlydemo;
GRANT USAGE ON SCHEMA demo TO onlydemo;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO onlydemo;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA demo TO onlydemo;

CREATE USER apiuser WITH PASSWORD 'userapi';
GRANT CONNECT ON DATABASE postgres TO apiuser;
GRANT USAGE ON SCHEMA demo, public TO apiuser;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO apiuser;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO apiuser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA demo TO apiuser;
GRANT DELETE ON demo.segmentosetor TO apiuser;
GRANT DELETE ON demo.outlier TO apiuser;