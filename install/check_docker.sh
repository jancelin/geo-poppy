#!/bin/bash
# Author: Erik Kristensen
# Email: erik@erikkristensen.com
# License: MIT
# Nagios Usage: check_nrpe!check_docker_container!_container_id_

# Modified by Julien ANCELIN for docker-compose 
# List all container in a docker-compose and If one or more is exit then it restart all container.

### INSTALLATION AUTO > need internet
# wget --no-check-certificate -N -O /home/pirate/check_docker.sh https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/check_docker.sh
# sudo chmod +x /home/pirate/check_docker.sh
# sudo wget --no-check-certificate -N -O /etc/systemd/system/Cdocker.service https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/Cdocker.service
# sudo systemctl enable Cdocker.service

### INSTALLATION MANUELLE
### pour installer mettre le fichier dans un répertoire ex: /home/pirate/check_docker.sh
### rendre executable: chmod +x /home/pirate/check_docker.sh
### Rajouter le fichier Cdocker.service (https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/Cdocker.service) dans /etc/systemd/system/
### Activer le service au démarrage du raspberry: sudo systemctl enable Cdocker.service
### Et si besoin il est possible de le lancer à la main pour vérifier son fonctonnement (attention il y a un sleep de 40 secondes): sudo systemctl start Cdocker.service

#set -x
sleep 40
LIST=$(docker ps -aq)
for CONTAINER in $LIST
do

  RUNNING=$(docker inspect --format="{{.State.Running}}" $CONTAINER )

  if [ "$RUNNING" = "false" ]; then
    echo "CRITICAL - $CONTAINER is not running."
    docker-compose -f /home/pirate/docker-compose.yml down --remove-orphans &&
    docker-compose -f /home/pirate/docker-compose.yml up -d
    exit
  fi

  RESTARTING=$(docker inspect --format="{{.State.Restarting}}" $CONTAINER)

  if [ "$RESTARTING" = "true" ]; then
    echo "WARNING - $CONTAINER state is restarting."
    #exit 1
  fi

  STARTED=$(docker inspect --format="{{.State.StartedAt}}" $CONTAINER)
  NETWORK=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $CONTAINER)

  echo "OK - $CONTAINER is running. IP: $NETWORK, StartedAt: $STARTED"
  
done
exit
