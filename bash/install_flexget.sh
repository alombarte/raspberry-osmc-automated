#!/bin/bash
if [ $# != 3 ]
then
	echo "Installs and configures flexget in the system."
	echo "--USAGE: $0 install_path subtitles_language feed"
	echo "e.g: $0 /home/osmc/.raspberry-osmc-automated es 'http://showrss.info/rss.php?user_id=51436'"
	exit 0
fi

INSTALLATION_FOLDER=$1
SUBTITLES_LANGUAGE=$2
CONFIG_RSS_FEED=$(echo "$3" | sed -e 's/[\/&]/\\&/g')

# Dependencies:
sudo apt-get install python-pip python-setuptools --yes
# six>=1.9.0 to run flex needed:
sudo pip install six --upgrade
sudo easy_install flexget

# Add FlexGet configuration:
mkdir -p ~/.flexget
if [ -f /home/osmc/.flexget/config.yml ];
then
    mv /home/osmc/.flexget/config.yml /home/osmc/.flexget/config.yml.default
fi
ln -s "$INSTALLATION_FOLDER/flexget/config.yml" /home/osmc/.flexget/config.yml

echo "Flexget will download content from RSS: $CONFIG_RSS_FEED"

# Write user's feed in the .yml
sed -i "s@rss: CONFIG_RSS_FEED@rss: $CONFIG_RSS_FEED@" "$INSTALLATION_FOLDER/flexget/config.yml"
sed -i "s@SUBTITLES_LANGUAGE@$SUBTITLES_LANGUAGE@" "$INSTALLATION_FOLDER/flexget/config.yml"

# Works?
/usr/local/bin/flexget exec

# Subtitles:
sudo pip install subliminal