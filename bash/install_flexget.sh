#!/bin/bash
source settings.cfg

# Dependencies:
sudo apt-get install python-pip python-setuptools --yes
# six>=1.9.0 to run flex needed:
sudo pip install six --upgrade
sudo easy_install flexget

# Add FlexGet configuration:
mkdir ~/.flexget
ln -s $INSTALLATION_FOLDER/flex/config.yml /home/osmc/.flexget/config.yml

# Write user's feed in the .yml
sed -i "@rss: CONFIG_RSS_FEED@rss: $CONFIG_RSS_FEED@" $INSTALLATION_FOLDER/flex/config.yml

# Works?
flexget -V
