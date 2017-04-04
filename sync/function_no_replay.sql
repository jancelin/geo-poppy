
--------------------------------------------------------------
--Fonction d'exclusion des données multi editées par l'intégrateur durant une meme session d'edition
--La vue no_replay doit être créée avant.
--
--------------------------------------------------------------
DROP FUNCTION no_replay();
CREATE OR REPLACE FUNCTION no_replay() RETURNS table(f1 boolean) AS
$BODY$
DECLARE
req text;
BEGIN
FOR req IN
	SELECT distinct
	'UPDATE sauv_data SET replay = TRUE WHERE ts = '''||n.ts||''';' 	--modifie replay en TRUE
	|| 'UPDATE sauv_data SET no_replay = 1 WHERE ts = '''||n.ts||''';'	--modifie no_replay en 1 : données multi édité
	FROM
	no_replay n
  LOOP
	  EXECUTE req;								--looped query INSERT UPDATE DELETE
	  raise INFO 'ACTION:  %',req;						--messages logs
	  return next;								--number of lines
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
  COST 100
ROWS 1000;

