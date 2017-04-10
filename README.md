
![Installation sur Raspberry pi 3](https://github.com/jancelin/geo-poppy/blob/master/install/README_install_geopoppy.md)

![geo-poppy](https://github.com/jancelin/geo-poppy/blob/master/docs/images/1.png?raw=true)

___________________________________________________________________________________
**Matériel**

Les Matériels retenus pour faire fonctionner les services webSIG sont :

* un Raspberry Pi 3 (ou 2 ou zero ).

> Pourquoi ? Parce que il y a une grande communauté de bidouilleurs, et Debian et Docker fonctionnent très bien sur les puces armhf, donc on peut installer à peu près tous les logiciels présents sur un serveur Linux classique. Prix env 35€

* une carte microSDHC 16 Go classe 10 indice 3. Pour le système d'exploitation et les composants logiciels

> Il y a de la place et ça va vite. Prix env 16€

* Un sense Hat: qui permet de faire quelques commandes de base sur le raspberry sans allumer une console : https://github.com/jancelin/geo-poppy/blob/master/sense-hat/command.md

________________________________________________________________________________

**Programmes:**

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859301/e5f0d6d6-053f-11e5-94ec-e6d9361f1a35.png)

* Ce projet est monté sur linux Debian avec Docker pour les containers logiciels. J'ai fait le choix de partir sur l'image créée par Hypriot (http://blog.hypriot.com/) qui intègre directement les deux tout en étant léger :


**http://blog.hypriot.com/downloads/**


* Pour la base de données, Docker Postgresql et PostGIS. Cette image vient du dépôt kartoza/docker-postgis (https://github.com/kartoza/docker-postgis), et à été quelque peu modifié pour que ça tourne sur un Raspberry.


**https://github.com/jancelin/docker-postgis-rpi**


* Le serveur websig est basé sur Qgis Qgis-server (http://www.qgis.org/fr/site/) et Lizmap (http://www.3liz.com/lizmap.html). J'ai fabriqué une image docker contenant les deux :


**https://github.com/jancelin/rpi-docker-lizmap**


Vous pouvez aussi installer la version docker lizmap sur votre pc ou serveur :

**https://github.com/jancelin/docker-lizmap**

______________________________________________________________________

Comment le fabriquer ?

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/12889497/6c3a926e-ce7f-11e5-8391-de6b205307e2.png)

Nouvelle version: 
Méthode rapide seulement pour Rasberry Pi 3 

***https://github.com/jancelin/geo-poppy/blob/master/install/README_install_geopoppy.md***


Installation détaillée sur:

***https://github.com/jancelin/geo-poppy/wiki***

____________________________________________________________________________

Julien ANCELIN / UE INRA de Saint Laurent de la Prée
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>

INRA ![INRA](https://github.com/jancelin/geo-poppy/blob/master/docs/images/INRA_logo_small.jpg)

