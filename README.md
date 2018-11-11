
**GeoPoppy est un outil numérique OpenSource LowCost pour l'acquisition et la consultation de données géolocalisées**


![geo-poppy](https://raw.githubusercontent.com/jancelin/geo-poppy/master/docs/images/geopoppy_2.png)

[![Try in PWD](https://cdn.rawgit.com/play-with-docker/stacks/cff22438/assets/images/button.png)](http://play-with-docker.com?stack=https://raw.githubusercontent.com/jancelin/geo-poppy/master/windowsTablette/docker-compose.yml)

**![Lien vers la procédure d'installation sur Raspberry pi 3](https://github.com/jancelin/geo-poppy/wiki/2.-Installation)**


![geo-poppy](https://github.com/jancelin/geo-poppy/blob/master/docs/images/1.png?raw=true)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>

___________________________________________________________________________________
**Matériel**

Les Matériels retenus pour faire fonctionner les services webSIG sont :

* un Raspberry Pi 3 (ou 2 ou zero ).

> Pourquoi ? Parce que il y a une grande communauté de bidouilleurs, et Debian et Docker fonctionnent très bien sur les puces armhf, donc on peut installer à peu près tous les logiciels présents sur un serveur Linux classique. Prix env 35€

* une carte microSDHC 16 Go classe 10 indice 3. Pour le système d'exploitation et les composants logiciels

> Il y a de la place et ça va vite. Prix env 16€

* En option un sense Hat: qui permet de faire quelques commandes de base sur le raspberry sans allumer une console : https://github.com/jancelin/geo-poppy/blob/master/sense-hat/command.md

________________________________________________________________________________

**CommentComment le fabriquer ?**
 
 ![geoPoppy](https://raw.githubusercontent.com/jancelin/geo-poppy/master/docs/images/geopoppy_schema_1.png) Méthode rapide pour Rasberry Pi 3 
 
 ***https://github.com/jancelin/geo-poppy/wiki/2.-Installation*** __________________________________________________________
__________________ 

**Programmes:**

![geo-poppy](https://raw.githubusercontent.com/jancelin/geo-poppy/master/docs/images/docker_container.png)


* Ce projet est monté sur linux Debian avec Docker pour les containers logiciels. L'image créée par Hypriot intègre directement les deux:

**http://blog.hypriot.com/downloads/**


* Pour la base de données, Docker Postgresql et PostGIS. Cette image vient du dépôt kartoza/docker-postgis (https://github.com/kartoza/docker-postgis), et à été quelque peu modifié pour que ça tourne sur un Raspberry.


**https://github.com/jancelin/docker-postgis-rpi**


* Le serveur websig est basé sur Qgis Qgis-server (http://www.qgis.org/fr/site/) et Lizmap (http://www.3liz.com/lizmap.html). J

**https://github.com/jancelin/docker-qgis-server**

**https://github.com/jancelin/docker-lizmap**


____________________________________________________________________________

Julien ANCELIN / UE INRA de Saint Laurent de la Prée
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>

 ![INRA](https://github.com/jancelin/geo-poppy/blob/master/docs/images/INRA_logo_small.jpg)
