#!/bin/bash

### BEGIN INIT INFO
# Provides:          scriptname
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
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


sleep 60
LIST=$(docker ps -aq)
for CONTAINER in $LIST
do

  if [ "x${CONTAINER}" == "x" ]; then
    echo "UNKNOWN - Container ID or Friendly Name Required"
    #exit 3
  fi

  if [ "x$(which docker)" == "x" ]; then
    echo "UNKNOWN - Missing docker binary"
    #exit 3
  fi

  docker info > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "UNKNOWN - Unable to talk to the docker daemon"
    #exit 3
  fi

  RUNNING=$(docker inspect --format="{{.State.Running}}" $CONTAINER 2> /dev/null)

  if [ $? -eq 1 ]; then
    echo "UNKNOWN - $CONTAINER does not exist."
    #exit 3
  fi

  if [ "$RUNNING" == "false" ]; then
    echo "CRITICAL - $CONTAINER is not running."
    docker-compose down --remove-orphans &&
    docker-compose up -d
    #exit 2
  fi

  RESTARTING=$(docker inspect --format="{{.State.Restarting}}" $CONTAINER)

  if [ "$RESTARTING" == "true" ]; then
    echo "WARNING - $CONTAINER state is restarting."
    #exit 1
  fi

  STARTED=$(docker inspect --format="{{.State.StartedAt}}" $CONTAINER)
  NETWORK=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $CONTAINER)

  echo "OK - $CONTAINER is running. IP: $NETWORK, StartedAt: $STARTED"
  
done
exit