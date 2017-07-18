# Sync

Sync est un module développé en SQL au dessus de Postgres 9.5 minimum pour faciliter la synchronisation de bases de données terrains (multiples) avec une base serveur. Les bases de données partagent le même schéma. 
Il ne s'agit pas de réplication de données comme fait SLONY (http://www.slony.info/), mais de fusion de données multi-sources (ici les bases de données terrain). 

## Comment ça marche

Sync historise dans le schema **sync** dans une table **sync.sauv_data** via un trigger toutes les modifications faites sur les bases terrain. 

Il garde la modifications et les métadonnées sur cette modification : 
- le nom qui identifie la base du terrain qui sera un traceur de la base de données de provenance : **integrateur**
- le timestamp avec time zone : **ts**
- le nom du schema surveillé : **schema_bd**
- le nom de la table : **tbl**
- l'action (update, delete, insert) : **ACTION1**
- nom de la PK sur la table modifiée: **pk**
- il encapsule le tuple qui a été modifié en json : **sauv**
- il renseigne un attribut **replay** : FALSE avant analyse des éventuels conflits, TRUE ensuite
- il renseigne un attribut **no_replay** :
    - passe à NULL si c'est une mise à jour (la dernière) qui doit être intégrée.
    - passe à 1 si c'est des mises à jours intervenants sur un objet édité plusieurs fois par le même utilisateur sur la même base terrain. On ne veut traiter que les dernières mises à jour d'un utilisateur.
    - passe à 2 quand il y a un conflit, c'est à dire une mise à jour par plusieurs utilisateurs sur le même objet (repéré par le triplet <schema_bd, tbl, pk>).
- il renseigne un attribut mis à jour lors de l'édition manuelle des conflits : **supprime_data** qui vaut TRUE si c'est une donnée qu'on ne souhaite pas garder à la fusion, FALSE sinon


## En pratique

Initialiser l'environnement : créer la table **sauv_data**, les triggers et les vues afférentes. 

1. Exécuter **sync_geopoppy.sql** sur votre base de données terrain (sur un ou plusieur GeoPoppy)
2. Exécuter  **sync_server.sql** qui crée 3 vues et 3 fonctions (sur le serveur central):  
    - **sync.replay** contient les lignes qui seront finalement intégrées dans la base de données serveur
    - **sync.no_replay** contient les lignes qui ne seront pas jouées du fait de l'édition multiple d'une même entité par le même utilisateur (contrôle sur integrateur).
    - **sync.conflict** contient les lignes qui ne seront pas jouées du fait de l'édition multiple d'une même entité par différents utilisateurs (contrôle sur integrateur) et qui présentent donc un conflit. La vue conflit peut être éditée par l'utilisateur pour résoudre les conflits en passant supprime_data à une valeur true pour toutes les valeurs qu'on ne souhaite pas garder pour la fusion. 

## En production sur votre serveur : 

1. Récupérer les mises à jour des bases terrain par un lien (db_link) vers ces bases de données : elles sont copiées dans sauv_data.
Exemple pour deux bases terrain 'terrain1' et 'terrain2' ayant chacune un utilisateur différent 'user1' et 'user2'
``` 
-- Première BDD terrain1
SELECT
dblink_connect('linkterrain1','host=127.0.0.1 port=5432
 user=user1
 password=postgres
 dbname=terrain1');
-- "OK"

INSERT INTO sauv_data 
SELECT * from dblink('linkterrain1', 'select ''linkterrain1'', ts, schema_bd, tbl, action1, sauv, pk from sauv_data;') as t( integrateur text, ts timestamp with time zone, schema_bd text, tbl text, action1 text, sauv json, pk text);
-- Query returned successfully: one row affected, 11 msec execution time.

SELECT dblink_disconnect('linkterrain1');


-- Deuxième BDD terrain2

SELECT
dblink_connect('linkterrain2','host=127.0.0.1 port=5432
 user=user2
 password=postgres
 dbname=terrain2');
-- "OK"

INSERT INTO sauv_data 
SELECT * from dblink('linkterrain2', 'select ''linkterrain2'', ts, schema_bd, tbl, action1, sauv, pk from sauv_data;') as t( integrateur text, ts timestamp with time zone, schema_bd text, tbl text, action1 text, sauv json, pk text);
-- Query returned successfully: one row affected, 11 msec execution time.

SELECT dblink_disconnect('linkterrain2');

```

2. Jouer no_replay() 
``` 
select sync.no_replay();
```

3. Vérifier et résoudre à la main les conflits : ouvrir la vue conflict et modifier supprime_data à true pour les valeurs à ne pas garder.

4. Jouer replay()
``` 
select sync.replay();
```



## Licence

Logiciel diffusé sous licence open-source AGPL


