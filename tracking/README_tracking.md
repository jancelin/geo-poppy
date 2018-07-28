
**Tracking pour GéoPoppy permet, en branchant une antenne GNSS sur le raspberry, de relever des données de localisation directement en base de données.**

Etapes:

* Créer une table "trame" dans la base geopoppy Postgresql delivré lors de l'installation initiale: 
https://github.com/jancelin/geo-poppy/blob/dev/tracking/trame.sql

* brancher une antenne GNSS en USB sur le Raspberry Pi. L'antenne doit sortir une trame NMEA

* rajouter dans le docker-compose.yml le nouveau sevice:
https://github.com/jancelin/geo-poppy/blob/dev/tracking/docker-compose.yml

* lancer le container quand vous souhaitez effectué un tracking de position:
```
docker-compose up -d tracking
```

* pour arrêter le tracking:
```
docker-compose stop tracking
```

> il est possible de gérer le démarage/arrêt directement dans portainer: http://172.24.1.1:9000

* les données sont enregistrés toute les 10 secondes, disponibles dans la base postgresql geopoppy, table trame via Qgis ou lizmap
