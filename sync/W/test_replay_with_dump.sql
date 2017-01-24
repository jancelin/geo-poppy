delete from sauv_data;

--db_serveur connect to one or more GeoPoppy for dumping data on his sauv_data table
SELECT
dblink_connect('geo','host=0.0.0.0 port=5401
 user=geomatik
 password=geomatik
 dbname=framboise_entomo');

INSERT INTO sauv_data 
SELECT * from dblink('geo', 'select * from sauv_data;') as t(integrateur text, ts timestamp with time zone, schema_bd text, tbl text, action1 text, sauv json, pk text);

SELECT dblink_disconnect('geo');

select replay();
