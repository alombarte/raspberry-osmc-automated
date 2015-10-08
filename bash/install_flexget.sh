#!/bin/bash
if [ $# != 2 ]
then
	echo "Installs and configures flexget in the system."
	echo "--USAGE: $0 install_path feed"
	echo "e.g: $0 /home/osmc/.raspberry-osmc-automated 'http://showrss.info/rss.php?user_id=51436'"
	exit 0
fi

INSTALLATION_FOLDER=$1
CONFIG_RSS_FEED=$2

# Dependencies:
sudo apt-get install python-pip python-setuptools --yes
# six>=1.9.0 to run flex needed:
sudo pip install six --upgrade
sudo easy_install flexget

# Add FlexGet configuration:
mkdir -p ~/.flexget
mv /home/osmc/.flexget/config.yml /home/osmc/.flexget/config.yml.default
ln -s $INSTALLATION_FOLDER/flexget/config.yml /home/osmc/.flexget/config.yml

# Write user's feed in the .yml
sed -i "s@rss: CONFIG_RSS_FEED@rss: $CONFIG_RSS_FEED@" $INSTALLATION_FOLDER/flexget/config.yml

# Works?
/usr/local/bin/flexget exec

# Subtitles (install both systems):
sudo easy_install periscope
sudo pip install subliminal