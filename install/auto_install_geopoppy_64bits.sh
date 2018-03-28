#!/bin/sh 
#set -e
# Commande d'installation
### curl -fsSL https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/auto_install_geopoppy.sh | sh

wget --no-check-certificate -P /home/pirate https://raw.githubusercontent.com/jancelin/rpi_wifi_direct/master/raspberry_pi3/install_wifi_direct_rpi3.sh; chmod +x /home/pirate/install_wifi_direct_rpi3.sh; bash -x /home/pirate/install_wifi_direct_rpi3.sh &&
wget --no-check-certificate -O /home/pirate/docker-compose.yml https://raw.githubusercontent.com/jancelin/geo-poppy/master/docker-compose-arm64.yml &&
docker-compose up -d &&
sleep 30
echo " "
echo "* Redémarrer le raspberry pour l'activation du wifi : sudo reboot"
echo " "
echo "* Connectez-vous ensuite au réseau wifi GeoPoppy_Pi3"
echo " Mot de passe: geopoppy"
echo " Puis tapper l'adresse https://172.24.1.1 dans votre navigateur web pour accéder à la démo"
echo " "
echo "* Connection Data Base avec PgAdminIII ou Qgis 172.24.1.1:5432, base: geopoppy , login et mot de passe: docker"
echo "* Déposer ses projets Qgis ici:  http://172.24.1.1:8000/fs/mnt/fs/files/qgis/ 
echo " "
echo " en wifi direct: "
echo " 172.24.1.1                >> lizmap / qgiserver "
echo " 172.24.1.1:5432           >> postgresql "
echo " http://172.24.1.1:9000    >> portainerio : renseigner un mot de passe a la premiere connection + section locale"
echo " http://172.24.1.1:8000/fs/mnt/fs/files/qgis/    >> cloudmanager: dépot de fichier: login admin mdp admin"
echo " "
echo "Julien ANCELIN "
echo "https://github.com/jancelin/geo-poppy"
