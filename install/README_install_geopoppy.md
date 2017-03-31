**Géopoppy installation simple et démo pour Raspberry Pi 3**

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859239/41d9eaa6-053f-11e5-93d1-2056c6cff733.png)



* prépare SD: installation de flash

```
sudo apt-get install -y pv curl python-pip unzip hdparm
sudo pip install awscli
curl -O https://raw.githubusercontent.com/hypriot/flash/master/$(uname -s)/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash
```
* insère la sd dans le pc
* flasher la sd avec l'OS Hypriot Blackbeard: Raspbian + Docker (http://blog.hypriot.com/downloads/)

```
flash https://github.com/hypriot/image-builder-rpi/releases/download/v1.2.0/hypriotos-rpi-v1.4.0.img.zip

```
> il est aussi possible  de le télécharger et de remplacer le https://downloads.hypriot... par le chemin du fichier : /home/...
> lien pour plus d'info sur flash: https://github.com/hypriot/flash

* insère la sd dans le raspberry
* connecte l'ethernet
* allume.
* connecte toi en ssh:

```
ssh pirate@"ton ip"
```

> mot de passe : hypriot

* Rebooter, ça permet de redimenssionner la carte sd, et c'est indispensable sinon ça marche pas ensuite (problème session root)

```
sudo reboot
```

----------------------

* Re-connecte toi en ssh:

```
ssh pirate@"ton ip"
```

------------------------
* maintenant passe en root

```
sudo -s
```

* et lance la commande :

```
curl -fsSL https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/auto_install_geopoppy.sh | sh

```

c'est fini, un message à la fin (env 30 min):

> * Redémarer le raspberry pour l'activation du wifi : sudo reboot
> 
> * Connectez-vous ensuite au réseau wifi GeoPoppy_Pi3
> Mot de passe: geopoppy
> Puis tapper l'adresse 172.24.1.1 dans votre navigateur web pour accéder à la démo
> 
> * Connection Data Base avec PgAdminIII ou Qgis sur la même ip, port 5432, login et mot de passe: docker
> * Connection Data Base avec PgAdmin4 interne: activer le container dans 172.24.1.1:9000 et acceder à pgadmin4 172.24.1.1:5050
> * Construire ses projets Qgis dans le répertoire /home/GeoPoppy/lizmap/project pour les rendre accessibles

* redémarrer le raspberry.

```
reboot
```
________________________________________________________________________________

Si pas de service...

* connecte toi en ssh
* lance un :

```
docker-compose up -d
```

Pour refabriquer les containers:

```
docker-compose kill
docker-compose rm
docker-compose up -d
```
_________________________________________________________________________________

Liste des améliorations de GéoPoppy

* utilisation de la dernière version d'Hypriot OS Blackbeard:
     Latest Docker Engine 1.12.1 with Swarm Mode
* utilisation du wifi interne du raspberry pi 3.
* si connection en ethernet il fait borne wifi ouverte sur le web.
* le hotplug eternet fonctionne.
* il contiens l'arborescence de fichier necessaire au fonctionnement de postgresql/postgis et qgis-serveur/lizmap.
* il contiens une base de donnée et un projet démo carto pour tester les fonctionalités.
* il utilise Docker-compose qui permet d'orchestrer ses conteneur grâce à un fichier docker-compose.yml situé dans /home/pirate.
* il contiens les conteneurs :
    * qgis-server 2.14.11LTR lizmap 3.1rc1
    * postgresql 9.5 postgis 2.2
* ...

Amusez-vous bien. Et faites remonter les bugs...

