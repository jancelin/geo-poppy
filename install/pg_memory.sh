#!/bin/bash
#http://www.adminlost.com/2016/05/postgresql-optimisation-shmmax-shmall/
page_size=`getconf PAGE_SIZE`
phys_pages=`getconf _PHYS_PAGES`
shmall=`expr $phys_pages / 2`
shmmax=`expr $shmall \* $page_size`
echo kernel.shmmax = $shmmax
echo kernel.shmall = $shmall
sysctl -w kernel.shmmax=$shmmax
sysctl -w kernel.shmall=$shmall
