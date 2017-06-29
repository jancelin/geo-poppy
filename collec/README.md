
COLLEC RPI
============

FROM Irstea/collec pour une utilisation sur le terrain en mode déconnecté 

**https://github.com/Irstea/collec**


INSTALLATION sur RASPBERRY PI 3 from scratch
------------

* Télécharger RASPBIAN jessie Lite : https://downloads.raspberrypi.org/raspbian_lite_latest

* Flasher raspbian jessie sur une Micro SD avec ETCHER: https://etcher.io/

* Insérer la micro SD dans le raspberry pi3, connecter un cable ethernet, allumer.

* Se connecter en ssh au raspberry

```
ssh pi@raspberry.local
```

> MDP: raspberry

* Installer docker engine: https://docs.docker.com/engine/installation/

```
  sudo apt-get update
  sudo apt-get install curl 
  curl -fsSL https://get.docker.com/ | sh
  sudo systemctl enable docker
  sudo service docker start
  sudo groupadd docker
  sudo usermod -aG docker $USER
```

* Installer docker compose: https://docs.docker.com/compose/install/

```
sudo apt-get install python-pip
sudo pip install docker-compose
```

* Créer le répertoire de stockage des données

```
mkdir /home/pirate/collec/postgres_data_collec_auto
```

* Récupérer le fichier docker-compose.yml sur /home/pi

```
wget --no-check-certificate -P /home/pi https://raw.githubusercontent.com/jancelin/geo-poppy/master/collec/docker-compose.yml
```

* Enfin lancer l'installation

```
docker-compose up -d
```

* Attendre 2 minutes que la base soit généré et se rendre sur https://raspberry.local/collec-feature_metadata pour accéder à la démo.

> Login: admindemo

> MDP: admin_007

--------------------------------------------------------------------------------

COLLEC
============
Collec est un logiciel destiné à gérer les collections d'échantillons prélevés sur le terrain.

Écrit en PHP, il fonctionne avec une base de données Postgresql. Il est bâti autour de la notion d'objets, qui sont identifiés par un numéro unique. Un objet peut être de deux types : soit un container (aussi bien un site, un bâtiment, une pièce, un congélateur, une caisse...) qu'un échantillon. 
Un type d'échantillon peut être rattaché à un type de container, quand les deux notions se superposent (le flacon contenant le résultat d'une pêche est à la fois un container et l'échantillon lui-même).
Un objet peut se voir attacher plusieurs identifiants métiers différents, des événements, ou des réservations.
Un échantillon peut être subdivisé en d'autres échantillons (du même type ou non). Il peut contenir plusieurs éléments identiques (notion de sous-échantillonnage), comme des écailles de poisson indifférenciées.
Un échantillon est obligatoirement rattaché à un projet. Les droits de modification sont attribués au niveau du projet.

Fonctionnalités principales
---------------------------
- Entrée/sortie du stock de tout objet (un container peut être placé dans un autre container, comme une boite dans une armoire, une armoire dans une pièce, etc)
- possibilité de générer des étiquettes avec ou sans QRCODE
- gestion d'événements pour tout objet
- réservation de tout objet
- lecture par scanner (douchette) des QRCODE, soit objet par objet, soit en mode batch (lecture multiple, puis intégration des mouvements en une seule opération)
- lecture individuelle des QRCODES par tablette ou smartphone (testé, mais pas très pratique pour des raisons de performance)
- ajout de photos ou de pièces jointes à tout objet

Sécurité
--------
- logiciel homologué à Irstea, résistance à des attaques opportunistes selon la nomenclature de l'OWASP (projet ASVS), mais probablement capable de répondre aux besoins du niveau standard
- identification possible selon plusieurs modalités : base de comptes interne, annuaire ldap, ldap - base de données (identification mixte), via serveur CAS, ou par délégation à un serveur proxy d'identification, comme LemonLDAP, par exemple
- gestion des droits pouvant s'appuyer sur les groupes d'un annuaire LDAP

Licence
-------
Logiciel diffusé sous licence AGPL

Copyright
---------
La version 1.0 a été déposée auprès de l'Agence de Protection des Programmes sous le numéro IDDN.FR.001.470013.000.S.C.2016.000.31500

