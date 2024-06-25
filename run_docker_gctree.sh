#!/bin/bash
port=$1;
name=$2;

sudo docker run -it \
-v /home/hieu:/home/hieu -v /media:/media -v /mnt:/mnt -p ${port}:8787 -e PASSWORD=genov4 --name ${name} -e USERID=1004 -e GROUPID=1005 \
tronghieunguyen/gctree:latest bash
