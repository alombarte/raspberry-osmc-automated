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

# Stop daemon to edit settings, otherwise they are rewritten:
sudo /etc/init.d/transmission-daemon stop

# Change downloading dirs from/var/lib/transmission-daemon/ to folders with space:
sudo sed -i 's@/var/lib/transmission-daemon/downloads@/home/osmc/Downloads@' /etc/transmission-daemon/settings.json
sudo sed -i 's@/var/lib/transmission-daemon/Downloads@/home/osmc/Downloads/Incomplete@' /etc/transmission-daemon/settings.json
echo "Transmission access is allowed to range: $NETWORK_RANGE"
sudo sed -i "s@\"rpc-whitelist\": \"127.0.0.1\"@\"rpc-whitelist\": \"127.0.0.1,$NETWORK_RANGE\"@" /etc/transmission-daemon/settings.json
sudo sed -i "s@\"rpc-whitelist\": \"127.0.0.1\"@\"rpc-whitelist\": \"127.0.0.1,$NETWORK_RANGE\"@" /home/osmc/.config/transmission-daemon/settings.json

# Previous access doesn't seem to be enough in some reported cases.
# Enable access to the GUI from inside the network:
cat <<EOF | sudo tee -a /etc/default/transmission-daemon
# Enable access to the GUI from inside the network:
START_STOP_OPTIONS='--allowed "127.*,10.*,192.168.*,172.16.*,172.17.*,172.18.*,172.19.*,172.20.*,172.21.*,172.22.*,172.23.*,172.24.*,172.25.*,172.26.*,172.27.*,172.28.*,172.29.*,172.30.*,172.31.*,169.254.*"'
EOF


# Run transmission as "osmc" user to avoid permission problems.
# Add a local file in case transmission is updated the .conf is not lost.
sudo mkdir -p /etc/systemd/system/transmission-daemon.service.d/
cat <<EOF | sudo tee /etc/systemd/system/transmission-daemon.service.d/local.conf
[Service]
User = osmc
EOF

sudo systemctl daemon-reload

# Start daemon
sudo /etc/init.d/transmission-daemon start