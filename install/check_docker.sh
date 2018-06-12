#!/bin/bash
### BEGIN INIT INFO
# Provides:          chech_docker
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Description courte
# Description:       Description longue
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
