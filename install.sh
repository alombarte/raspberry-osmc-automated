#!/bin/bash

# You can execute this script with:
# bash <(curl -s https://raw.githubusercontent.com/alombarte/raspberry-osmc-automated/master/install.sh) /home/osmc/.raspberry-osmc-automated

if [ $# != 1 ]
then
	echo "Installation of raspberry-osmc-automated"
	echo "--USAGE: $0 install_path"
	exit 0
fi

if [ "root" = $(whoami) ]; then
	echo "Do not run this script as root. The sudo command will be used when needed."
	exit 0
fi
			
INSTALLATION_FOLDER=$1
SETTINGS_FILE="$INSTALLATION_FOLDER/bash/settings.cfg"
SAMPLE_RSS_FEED="http://showrss.info/rss.php?user_id=51436&hd=2&proper=1"


echo "Starting installation in path $INSTALLATION_FOLDER"
echo "Press ENTER to proceed or CTRL+C to abort"
echo "--------------------------------------------------"
readkey CONFIRM

# DOWNLOAD TARBALL
bash <(curl -s https://raw.githubusercontent.com/alombarte/raspberry-osmc-automated/master/bash/download_tarball.sh) $INSTALLATION_FOLDER

# Add installation path to settings
echo "INSTALLATION_FOLDER=$INSTALLATION_FOLDER" >> $SETTINGS_FILE

# Ask user for default paths
echo "--------------------------------------------------"
echo "Take a few seconds to customize your installation."
echo ""
echo "Paste your RSS feed URL below or press ENTER to use sample"
echo "E.g: : $SAMPLE_RSS_FEED"
read CONFIG_RSS_FEED
if [ "$CONFIG_RSS_FEED" == "" ] ; then
	CONFIG_RSS_FEED=$SAMPLE_RSS_FEED
	echo "No RSS provided, using sample feed $CONFIG_RSS_FEED"
fi
# Add RSS feed to settings
echo "CONFIG_RSS_FEED=\"$CONFIG_RSS_FEED\"" >> $SETTINGS_FILE

# Confirm IP
IP_GUESS=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127.0.0.1)
echo ""
echo "This box IP seems to be: $IP_GUESS"
echo "Press ENTER to validate or type the correct one"
read IP
if [ "$IP" == "" ] ; then
	IP=$IP_GUESS
fi
IP_RANGE=$(echo $IP | sed -r 's/([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)[0-9]{1,3}/\1*/')
echo "OSMC_HOST=\"$IP\"" >> $SETTINGS_FILE
echo "TRANSMISSION_WHITELIST_RANGE=\"$IP_RANGE\"" >> $SETTINGS_FILE

echo ""
echo "Are you storing content on a external storage? If so, what is the mountpoint? (e.g: /media/KINGSTON)"
echo "Press ENTER to skip, or write the path now:"
read EXTERNAL_STORAGE
if [ "$EXTERNAL_STORAGE" == "" ] || [ ! -d $EXTERNAL_STORAGE ] ; then
	echo "No valid storage given, omitting..."
else
	bash $INSTALLATION_FOLDER/bash/folder_structure.sh $EXTERNAL_STORAGE
	echo "EXTERNAL_STORAGE=\"$EXTERNAL_STORAGE\"" >> $SETTINGS_FILE
fi
echo "--------------------------------------------------"
# INSTALLATION BEGIN
echo "All set. INSTALLING..."

# Add write permission to osmc group. We will add other users in this group
chmod -R 775 /home/osmc

bash $INSTALLATION_FOLDER/bash/install_transmission.sh $IP_RANGE
bash $INSTALLATION_FOLDER/bash/install_flexget.sh
bash $INSTALLATION_FOLDER/bash/install_crontab.sh
bash $INSTALLATION_FOLDER/bash/user_profile.sh

echo "--------------------------------------------------"
echo "              Installation complete!"
echo "--------------------------------------------------"
echo "The following services are also available from your network *:"
echo ""
echo "Transmission web client"
echo "- http://$IP:9091 (credentials: transmission / transmission)"
echo ""
echo "Kodi Web"
echo "- http://$IP"
echo ""
echo "--------------------------------------------------"


