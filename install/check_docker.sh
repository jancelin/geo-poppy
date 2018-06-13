#!/bin/bash
# Author: Erik Kristensen
# Email: erik@erikkristensen.com
# License: MIT
# Nagios Usage: check_nrpe!check_docker_container!_container_id_

# Modified by Julien ANCELIN for docker-compose
# Usage: ./check_docker.sh 
#
# List all container in a docker-compose 
# and If one or more is exit, it do a docker-compose down and up
### INSTALLATION
### pour installer mettre le fichier dans un répertoire ex: /home/pirate/check_docker.sh
### rendre executable: chmod +x /home/pirate/check_docker.sh
### editer le rc.local pour lancer le script au demarage: sudo nano /etc/rc.local
### rajouter avant le exit0 dans /etc/rc.local : /home/pirate/check_docker.sh
### ou le lancer à la main, attention il y a un sleep de 40 secondes: /home/pirate/check_docker.sh

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
