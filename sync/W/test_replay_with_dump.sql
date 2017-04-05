
delete from sauv_data;

--db_serveur connect to one or more GeoPoppy for dumping data on his sauv_data table
SELECT
dblink_connect('geo1','host=0.0.0.0 port=5432
 user=geomatik
 password=geomatik
 dbname=framboise_entomo');

INSERT INTO sauv_data 
SELECT * from dblink('geo1', 'select  ''geo1'', ts, schema_bd, tbl, action1, sauv, pk from sauv_data;') as t( integrateur text, ts timestamp with time zone, schema_bd text, tbl text, action1 text, sauv json, pk text);

SELECT dblink_disconnect('geo1');

SELECT
dblink_connect('geo2','host=0.0.0.0 port=5432
 user=geomatik
 password=geomatik
 dbname=framboise_entomo');

INSERT INTO sauv_data 
SELECT * from dblink('geo2', 'select  ''geo2'', ts, schema_bd, tbl, action1, sauv, pk from sauv_data;') as t(integrateur text, ts timestamp with time zone, schema_bd text, tbl text, action1 text, sauv json, pk text);

SELECT dblink_disconnect('geo2');


select no_replay();
-- vérifier les conflits et les résoudres: view "conflict"
select replay();
