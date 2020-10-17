#!/bin/bash
HOST=8.8.8.8

ping -c1 $HOST 1>/dev/null 2>/dev/null
SUCCESS=$?

if [ $SUCCESS -eq 0 ]
then
  echo "$HOST has replied"
  su - postgres -c "psql oio -c \" select sync.auto_replay(1);\""
  exit
else
  echo "$HOST didn't reply"
  exit
fi
#EOF
