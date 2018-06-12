#!/bin/bash
### BEGIN INIT INFO
# Provides: check_docker.sh #Le nom de votre script
# Required-Start:    $remote_fs $syslog #Je ne sais pas du tout ce que c'est
# Required-Stop:     $remote_fs $syslog #Même problème
# Default-Start:     2 3 4 5 #J'ai rien compris sur ces niveaux
# Default-Stop:      0 1 6 #J'ai simplement compris que c'est les niveaux qui restent
# Short-Description: refabriquer les services si il sont en exit àprès un reboot
# Description: # Une description complète ici
### END INIT INFO
# Author: Erik Kristensen
# Email: erik@erikkristensen.com
# License: MIT
# Nagios Usage: check_nrpe!check_docker_container!_container_id_

# Modified by Julien ANCELIN for docker-compose
# Usage: ./check_docker.sh 
#
# List all container in a docker-compose 
# and If one or more is exit, it do a docker-compose down and up
# 

#BEFORE:
# 
# sudo nano /etc/init.d/check_docker
# sudo chmod +x /etc/init.d/check_docker
# sudo update-rc.d check_docker defaults 80 

#set -x
sleep 40
LIST=$(docker ps -aq)
for CONTAINER in $LIST
do

  RUNNING=$(docker inspect --format="{{.State.Running}}" $CONTAINER )

  if [ "$RUNNING" = "false" ]; then
    echo "CRITICAL - $CONTAINER is not running."
    docker-compose down --remove-orphans &&
    docker-compose up -d
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
