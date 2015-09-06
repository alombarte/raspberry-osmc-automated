#!/bin/bash

if [ $# != 1 ]
then
	echo "Installs transmission and gives permissions to access from a network range"
	echo "--USAGE: $0 'network_range'"
	echo "-- e.g: $0 '192.168.*.*'"
	exit 0
fi

NETWORK_RANGE=$1

sudo apt-get install transmission-daemon python-transmissionrpc --yes

# add transmission user to OSMC group:
sudo adduser debian-transmission osmc

# Stop daemon to edit settings, otherwise they are rewritten:
sudo /etc/init.d/transmission-daemon stop

# Change downloading dirs from/var/lib/transmission-daemon/ to folders with space:
sudo sed -i 's@/var/lib/transmission-daemon/downloads@/home/osmc/Downloads@' /etc/transmission-daemon/settings.json
sudo sed -i 's@/var/lib/transmission-daemon/Downloads@/home/osmc/Downloads/Incomplete@' /etc/transmission-daemon/settings.json
echo "Transmission access is allowed to range: $NETWORK_RANGE"
sudo sed -i "s@\"rpc-whitelist\": \"127.0.0.1\"@\"rpc-whitelist\": \"127.0.0.1,$NETWORK_RANGE\"@" /etc/transmission-daemon/settings.json

sudo /etc/init.d/transmission-daemon start