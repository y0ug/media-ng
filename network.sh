#!/bin/sh
docker network create --attachable --opt 'com.docker.network.bridge.name=bridge-media'\
  --opt 'com.docker.network.bridge.enable_ip_masquerade=false'\
  --subnet=172.20.0.0/16 \
  bridge-media

sudo ip addr add 192.168.100.25/32 dev ens33
sudo iptables -t nat -A POSTROUTING -s 172.20.0.0/16 ! -o bridge-media -j SNAT --to-source 192.168.100.25

#docker network create --attachable \
#  --subnet=192.168.100.0/24 \
#  --ip-range=192.168.100.24/29 \
#  --gateway 192.168.100.1 \
#  --aux-address="myserver=192.168.100.24" \
#  -d macvlan \
#  -o parent=ens33 \
#  dmz
#
#sudo ip link add dmz-docker-net link ens33 type macvlan mode bridge
#sudo ip link set dmz-docker-net up
#sudo ip addr add 192.168.100.24/29 dev dmz-docker-net
