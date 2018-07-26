#!/bin/bash
#check /dev/ttyUSB*

USB= ls -l /dev/tty* | grep 'dialout' | rev | cut -d " " -f1 | rev | grep 'USB'
echo $USB
