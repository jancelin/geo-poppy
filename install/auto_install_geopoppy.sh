#!/bin/sh 
### Commande sauvegarde du dossier
## tar zcvf /home/pi/geopoppy.tar /home/GeoPoppy

### Commande de restauration du dossier
## tar xvfz /home/pi/geopoppy.tar --preserve --same-owner -C /
#___________________________________________________________________
# Commande d'installation
### wget -P /home/pirate wget https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/auto_install_geopoppy.sh; chmod +x /home/pirate/auto_install_geopoppy.sh; sh /home/pirate/auto_install_geopoppy.sh


mkdir /home/pi &&
wget -P /home/pi https://github.com/jancelin/geo-poppy/raw/master/install/geopoppy_sig.tar &&
wget -P /home/pi https://github.com/jancelin/geo-poppy/raw/master/install/geopoppy_base.tar &&
tar xvfz /home/pi/geopoppy_sig.tar --preserve --same-owner -C /  &&
tar xvfz /home/pi/geopoppy_base.tar --preserve --same-owner -C /  &&
cd /home/GeoPoppy&&docker-compose up -d
