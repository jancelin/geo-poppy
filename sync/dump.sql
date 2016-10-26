SELECT
dblink_connect('geo','host=172.24.1.1 port=5432
 user=docker
 password=docker
 dbname=framboise_entomo');

INSERT INTO sauv_data 
SELECT * from dblink('geo', 'select * from sauv_data;') as t(integrateur text, ts timestamp with time zone, schema_bd text, tbl text, action1 text, sauv json, pk text);

SELECT dblink_disconnect('geo');
