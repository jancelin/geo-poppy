Welcome to the rpi-docker-lizmap wiki!

Sorry for the English. This wiki is for the moment in French but all docker use are in english.

-------------------------------------------------------------------------------
Tout d'abord à quoi ça sert ce truc?

> Le but est de disposer d'un serveur websig sans web et sans prise de courant.

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859283/b57c4a6c-053f-11e5-8376-d9525aa7153c.png)

______________________________________________________________________

Comment le Fabriquer ?

> https://github.com/jancelin/geo-poppy/wiki

______________________________________________________________________

Mais pour quoi faire ?

> * Imaginons que nous voulons cartographier et quantifier la population de coquelicot et de bleuet sur une zone de 1200 km2.

> * Que nous ne disposons pas de couverture réseau (wifi ou 3G/4G) sur cette zone.

> * Que nous souhaitons utiliser la même technologie que notre Serveur cartographique centralisé afin de faciliter les transferts de données et de ne former les utilisateurs/intégrateurs qu'à une même méthode de saisie.

> * Que des non géomaticiens (stagiaire, technicien, main d'œuvre, ...) puissent être autonome dans la saisie des données en 10 min.

> * Que ce serveur carto soit autonome, petit, léger, simple d'utilisation pour être emmené dans la poche ou un sac à dos.

> * Que la visualisation et l'intégration des données se fasse sur une tablette, smartphone, pc ; sans client lourd, et en wifi direct.

> * Que les données soit synchronisées vers une base centrale quand le serveur dispose d'une connexion sécurisé en ethernet.

___________________________________________________________________________________
**Matériel**

Les Matériels retenus pour faire fonctionner les services webSIG sont :

* un Raspberry Pi 2.

> Pourquoi ? Parce que il y a une grande communauté de bidouilleur, et Debian et Docker fonctionnent très bien sûr les puces armhf, donc on peut installer à peu près tout les logiciels présent sur un serveur Linux classique. Prix env 35€

* un dongle wifi Edimax. Pour communiquer avec le raspberry en wifi : EW-7811Un

> c'est petit, pas cher, ça marche bien pour du wifi direct avec peu de paramétrage côté serveur. Prix env 11 €

* une carte microSDHC 16 Go classe 10 indice 3. Pour le système d'exploitation et les composants logiciels

> Il y a de la place et ça va vite. Prix env  16€

* batterie usb 10400 mAh. Pour alimenter l'ensemble. Fonctionne aussi avec un allume-cigare voiture, un port USB, ...

> prix env= 45€

Un global, avec les câbles, adaptateurs pour env 110€, 62€ si pas besoin de batterie.

________________________________________________________________________________

**Programmes:**

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859301/e5f0d6d6-053f-11e5-94ec-e6d9361f1a35.png)

* Ce projet est monté sur linux Debian avec Docker pour les containers logiciels. J'ai fait le choix de partir sur l'image crée par Hypriot (http://blog.hypriot.com/) qui intègre directement les deux tout en étant léger :

'''
http://blog.hypriot.com/downloads/
'''

* Pour la base de données, Docker Postgresql et postgis. Cette image vient du dépôt kartoza/docker-postgis (https://github.com/kartoza/docker-postgis), et à été quelque peu modifié pour que ça tourne sur un Raspberry.

'''
https://github.com/jancelin/docker-postgis-rpi
'''

* Le serveur websig est basé sur Qgis Qgis-server (http://www.qgis.org/fr/site/) et Lizmap (http://www.3liz.com/lizmap.html). J'ai fabriqué une image docker contenant les deux :

'''
https://github.com/jancelin/rpi-docker-lizmap
'''

Vous pouvez aussi installer la version docker lizmap sur votre pc ou serveur : https://github.com/jancelin/docker-lizmap

____________________________________________________________________________

Julien ANCELIN ( julien.ancelin@stlaurent.lusignan.inra.fr) 05/2015 INRA 

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>
