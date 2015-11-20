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
sudo sed -i "s@\"rpc-whitelist\": \"127.0.0.1\"@\"rpc-whitelist\": \"127.0.0.1,$NETWORK_RANGE\"@" /var/lib/transmission-daemon/info/settings.json
sudo sed -i "s@\"rpc-whitelist\": \"127.0.0.1\"@\"rpc-whitelist\": \"127.0.0.1,$NETWORK_RANGE\"@" /home/osmc/.config/transmission-daemon/settings.json

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