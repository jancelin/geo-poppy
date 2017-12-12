!/bin/bash
# script write by Julien ANCELIN / INRA

DATABASE="plantation"
DUMP="/var/lib/postgresql/9.5/plantation.sql"

## docker exec root_postgis_1 sh -c "su postgres -c 'createdb -O docker -T template_postgis $DATABASE'" &&
docker exec root_postgis_1 sh -c "su postgres -c 'psql $DATABASE -f $DUMP'" 
