**Géopoppy installation simple et démo pour Raspberry Pi 3**

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859239/41d9eaa6-053f-11e5-93d1-2056c6cff733.png)



* prépare SD: télécharge et installe flash

```
sudo apt-get install -y pv curl python-pip unzip hdparm
sudo pip install awscli
curl -O https://raw.githubusercontent.com/hypriot/flash/master/$(uname -s)/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash
```

* flasher la sd avec l'OS Hypriot: Raspbian + Docker (http://blog.hypriot.com/downloads/)

```
flash https://downloads.hypriot.com/hypriotos-rpi-v1.0.0.img.zip  << USERINPUT
mmcblk0
yes
USERINPUT

```


----------------------

* insère la sd dans le raspberry
* connecte l'ethernet
* allume.
* connecte toi en ssh (attention l'utilisateur à changé):

```
ssh pirate@"ton ip"
```

mot de passe : hypriot

------------------------
* maintenant passe en root

```
sudo -s
```

* et lance la commande :

```
wget --no-check-certificate -P /home/pirate wget https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/auto_install_geopoppy.sh; chmod +x /home/pirate/auto_install_geopoppy.sh; sh /home/pirate/auto_install_geopoppy.sh
```

c'est fini, un message à la fin (env 40-50 min):

> * Redémarer le raspberry pour l'activation du wifi : sudo reboot
> 
> * Connectez-vous ensuite au réseau wifi GeoPoppy_Pi3
> Mot de passe: geopoppy
> Puis tapper l'adresse 172.24.1.1 dans votre navigateur web pour accéder à la démo
> 
> * Connection Data Base avec PgAdminIII ou Qgis sur la même ip, port 5432, login et mot de passe: docker
> * Construire ses projets Qgis dans le répertoire /home/GeoPoppy/lizmap/project pour les rendre accessibles

* redemarer le raspberry.

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

Et tes conteneurs se refabriqueront automatiquement.

_________________________________________________________________________________

Liste des améliorations de GéoPoppy

* utilisation de la dernière version d'Hypriot OS: "Barbossa".
      * Linux kernel 4.4.10
      * Docker Engine 1.11.1
      * Docker Compose 1.7.1
      * Docker Machine 0.7.0
      * Docker Swarm 1.2.2
      * Cluster-Lab 0.2.12
      device-init 0.1.7
* utilisation du wifi interne du raspberry pi 3.
* si connection en ethernet il fait borne wifi ouverte sur le web.
* le hotplug eternet fonctionne.
* il contiens l'arborescence de fichier necessaire au fonctionnement de postgresql/postgis et qgis-serveur/lizmap.
* il contiens une base de donnée et un projet démo carto pour tester les fonctionalités.
* il utilise Docker-compose qui permet d'orchestrer ses conteneur grâce à un fichier docker-compose.yml situé dans /home/pirate.
* il contiens les conteneurs :
    * qgis-server 2.14.4 lizmap 3.0.1
    * postgresql 9.5 postgis 2.2
* ...

Amusez-vous bien. Et faites remonter les bugs...

