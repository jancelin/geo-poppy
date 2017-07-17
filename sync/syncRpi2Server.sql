---------------------------------
--Synchronisation des données entre Geopoppy et un serveur central
--Julien ANCELIN
--Diffusé sous licence open-source AGPL
---------------------------------

--exemple: select sync.rpi2server('nom_connexion','ip','host','port','user','password','database');

DROP FUNCTION IF EXISTS sync.rpi2server();
CREATE OR REPLACE FUNCTION sync.rpi2server(n text, h text, p integer, u text, pw text, db text ) RETURNS table(f1 boolean) AS
$BODY$
DECLARE
query text :=''; 
BEGIN
--connect dblink remote server
PERFORM dblink_connect(''||n||'','host='||h||' port='||p||' user='||u||' password='||pw||' dbname='||db||'');
raise NOTICE 'connection: %',''||n||'';

	FOR query IN
	--get data and execute INSERT INTO in remote server
	SELECT 'SELECT dblink_exec('''||n||''',''INSERT INTO sync.sauv_data values 
        ('''''||n||''''','''''||ts||''''','''''||schema_bd||''''','''''||tbl||''''','''''||action1||''''','''''||sauv||''''','''''|| pk ||''''')'');
        UPDATE sauv_data SET sync = 1, sync_ts = now() WHERE ts = '''||ts||''';'
	FROM sauv_data
	WHERE sauv_data.sync = 0
	LOOP
	  EXECUTE query;
	  raise NOTICE 'ACTION:  %',query;	--messages logs
	  return next; 				--number of lines
	END LOOP;

--disconnect dblink remote server
PERFORM dblink_disconnect(''||n||'');
raise NOTICE 'déconnection: %',''||n||'';

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;
