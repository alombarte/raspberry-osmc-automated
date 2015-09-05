if [ $# != 1 ]
then
	echo "Installation of raspberry-osmc-automated"
	echo "--USAGE: $0 install_path"
	exit 0
fi

INSTALLATION_FOLDER=$1
SETTINGS_FILE="$INSTALLATION_FOLDER/bash/settings.cfg"
SOURCE="https://github.com/alombarte/raspberry-osmc-automated/archive/master.zip"

echo "Downloading source from $SOURCE..."
curl -L -O $SOURCE && \
unzip master.zip && \
mv raspberry-osmc-automated-master $INSTALLATION_FOLDER && \
rm master.zip

if [ ! -f $SETTINGS_FILE ]; then
	echo "Download failed. File $SETTINGS_FILE does not exist"
	echo "Aborting..."
	exit 0
fi

echo "Source downloaded sucessfully to $INSTALLATION_FOLDER"