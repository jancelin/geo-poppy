
**Géo Poppy est expérimental, la mise en production demande donc des compétences en bricolage...**


Tout d'abord à quoi ça sert ce truc ?

> Le but est de disposer d'un serveur websig sans web et sans prise de courant.

Méthode rapide d'installation pour Rasberry Pi 3 

***https://github.com/jancelin/geo-poppy/blob/master/install/README_install_geopoppy.md***

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859283/b57c4a6c-053f-11e5-8376-d9525aa7153c.png)

______________________________________________________________________

Mais pour quoi faire ?

> * Imaginons que nous voulons cartographier et quantifier la population de coquelicots et de bleuets sur une zone de 1200 km2.

> * Que nous ne disposons pas de couverture réseau (wifi ou 3G/4G) sur cette zone.

> * Que nous souhaitons utiliser la même technologie que notre serveur cartographique centralisé afin de faciliter les transferts de données et de ne former les utilisateurs/intégrateurs qu'à une même méthode de saisie.

> * Que des non géomaticiens (stagiaire, technicien, main d'œuvre...) puissent être autonomes dans la saisie des données en 10 min.

> * Que ce serveur carto soit autonome, petit, léger, simple d'utilisation pour être emmené dans la poche ou un sac à dos.

> * Que la visualisation et l'intégration des données se fassent sur une tablette, smartphone, pc ; sans client lourd, et en wifi direct.

> * Que les données soit synchronisées vers une base centrale quand le serveur dispose d'une connexion sécurisée en ethernet.

___________________________________________________________________________________
**Matériel**

Les Matériels retenus pour faire fonctionner les services webSIG sont :

* un Raspberry Pi 2 ou 3.

> Pourquoi ? Parce que il y a une grande communauté de bidouilleurs, et Debian et Docker fonctionnent très bien sur les puces armhf, donc on peut installer à peu près tous les logiciels présents sur un serveur Linux classique. Prix env 35€

* un dongle wifi Edimax (pour le raspberry pi2). Pour communiquer avec le Raspberry en wifi : EW-7811Un

> C'est petit, pas cher, ça marche bien pour du wifi direct avec peu de paramétrage côté serveur. Prix env 11 €

* une carte microSDHC 16 Go classe 10 indice 3. Pour le système d'exploitation et les composants logiciels

> Il y a de la place et ça va vite. Prix env 16€

* batterie usb 10400 mAh. Pour alimenter l'ensemble. Fonctionne aussi avec un allume-cigare voiture, un port USB...

> Prix env= 45€

Un global, avec les câbles, adaptateurs pour env 110€, 62€ sans batterie.

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

Nouvelle version: 
Méthode rapide seulement pour Rasberry Pi 3 

***https://github.com/jancelin/geo-poppy/blob/master/install/README_install_geopoppy.md***


Installation détaillée sur:

***https://github.com/jancelin/geo-poppy/wiki***

![geo-poppy-wiki](https://cloud.githubusercontent.com/assets/6421175/12889497/6c3a926e-ce7f-11e5-8391-de6b205307e2.png)


____________________________________________________________________________

Julien ANCELIN
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>
