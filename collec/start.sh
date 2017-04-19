#!/bin/bash

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

exec /usr/sbin/apachectl -D FOREGROUND
