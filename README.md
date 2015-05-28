Welcome to the rpi-docker-lizmap wiki!

Sorry for the English. This wiki is for the moment in French.

-------------------------------------------------------------------------------
Tout d'abord à quoi ça sert ce truc?

> Le but est de disposer d'un serveur websig sans web et sans prise de courant.

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859283/b57c4a6c-053f-11e5-8376-d9525aa7153c.png)

______________________________________________________________________

Mais pour quoi faire?

> * Imaginons que nous voulons cartographier et quantifier la population de coquelicot et de bleuet sur une zone de 1200 km2.

> * Que nous ne disposons pas de couverture réseau (wifi ou 3G/4G) sur cette zone.

> * Que nous souhaitons utiliser la même technologie que notre Serveur cartographique centralisé afin de faciliter les transferts de données et de ne former les utilisateurs/intégrateurs qu'à une même méthode de saisie.

> * Que des non géomaticiens (Stagiaire, Technicien, Main d'oeuvre, ...) puissent être autonome dans la saisie des données en 10 min.

> * Que ce serveur carto soit autonome, petit, léger, simple d'utilisation pour être emmené dans la poche ou un sac à dos.

> * Que la visualisation et l'intégration des données se fasse sur une tablette, smartphone, pc; sans client lourd, et en wifi direct.

> * Que les données soit synchronisées vers une base centrale quand le serveur dispose d'une connexion sécurisé en ethernet.


___________________________________________________________________________________
**Matériel**

Les Matériels retenus pour faire fonctionner les services webSIG sont:

* un Raspberry Pi 2.

> Pourquoi? Parceque il y a une grande communauté de bidouilleur, et debian et Docker fonctionnent très bien sur les puces armhf, donc on peut installer à peut près tout les logiciels présent sur un serveur linux classique. Prix env= 35€

* un dongle wifi Edimax. Pour communiquer avec le raspberry en wifi : EW-7811Un

> c'est petit, pas cher, ça marche bien pour du wifi direct avec peut de paramétrage côté serveur. prix env= 11 €

* une carte microSDHC 16 Go classe 10 indice 3. Pour le système d'exploitation et les composants logiciels

> Il y a de la place et ça va vite. prix env = 16€

* batterie usb 10400 mAh. Pour alimenter l'ensemble. Ca Fonctionne aussi avec un allume cigare voiture, un port usb,....

> prix env= 45€

Un global, avec les cables, adapteurs pour env: 110€, 62€ si pas besoin de batterie.

________________________________________________________________________________

**Programmes:**

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859283/b57c4a6c-053f-11e5-8376-d9525aa7153c.png)


* Ce projet est monté sur linux Debian avec Docker pour les containers logiciels. J'ai fait le choix de partir sur l'image crée par Hypriot (http://blog.hypriot.com/) qui intègre directement les deux tout en étant léger:

```
http://blog.hypriot.com/downloads/
```

* Pour la base de données, Docker Postgresql et postgis. Cette image viens du dépôt  kartoza/docker-postgis (https://github.com/kartoza/docker-postgis), et à été quelque peut modifié pour que ça tourne sur un Raspberry. J' ai également rajouté Slony (http://www.slony.fr/) pour la réplication master slave avec le serveur central:

```
https://github.com/jancelin/docker-postgis-rpi
```

* Le serveur websig est basé sur Qgis Qgis-server (http://www.qgis.org/fr/site/) et Lizmap  (http://www.3liz.com/lizmap.html). J'ai fabriqué une image docker contenant les deux:

```
https://github.com/jancelin/rpi-docker-lizmap
```

Vous pouvez aussi installer la version docker lizmap sur votre pc ou serveur: https://github.com/jancelin/docker-lizmap


____________________________________________________________________________






