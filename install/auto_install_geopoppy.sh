#!/bin/sh 
### Commande sauvegarde du dossier
## tar zcvf /home/pirate/geopoppy.tar /home/GeoPoppy

### Commande de restauration du dossier
## tar xvfz /home/pirate/geopoppy.tar --preserve --same-owner -C /
#___________________________________________________________________
# Commande d'installation
### wget -P /home/pirate wget -P /home/pirate https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/auto_install_geopoppy.sh && chmod +x /home/pirate/auto_install_geopoppy.sh && sh /home/pirate/auto_install_geopoppy.sh

wget -P /home/pirate https://github.com/jancelin/geo-poppy/raw/master/install/geopoppy_sig.tar &&
wget -P /home/pirate https://github.com/jancelin/geo-poppy/raw/master/install/geopoppy_base.tar &&
tar xvfz /home/pirate/geopoppy_sig.tar --preserve --same-owner -C /  &&
tar xvfz /home/pirate/geopoppy_base.tar --preserve --same-owner -C /  &&
cd /home/GeoPoppy&&docker-compose up -d
