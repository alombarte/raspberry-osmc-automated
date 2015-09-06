#!/bin/bash

if [ $# != 1 ]
then
	echo "Creates the folder structure in the external device."
	echo "--USAGE: $0 path"
	echo "-- e.g: $0 /media/USB"
	exit 0
fi

EXTERNAL_STORAGE=$1
mkdir -p $EXTERNAL_STORAGE/{Downloads/Incomplete,Movies,Music,Pictures,"TV Shows"}

echo "Deleting default OSMC folders."
# Delete default OSMC media folders in ~home and put symlinks to the USB.
sudo rmdir /home/osmc/{Movies,Music,Pictures,"TV Shows"}
echo "Recreating folders but pointing to the external storage"
ln -s $EXTERNAL_STORAGE/{Downloads,Movies,Music,Pictures,"TV Shows"} ~/

# The home directory `/home/omsc` now looks like this:
# 
# 	lrwxrwxrwx 1 osmc osmc 25 Sep  4 18:54 Downloads -> /media/KINGSTON/Downloads
# 	lrwxrwxrwx 1 osmc osmc 22 Sep  4 18:54 Movies -> /media/KINGSTON/Movies
# 	lrwxrwxrwx 1 osmc osmc 21 Sep  4 18:54 Music -> /media/KINGSTON/Music
# 	lrwxrwxrwx 1 osmc osmc 24 Sep  4 18:54 Pictures -> /media/KINGSTON/Pictures
# 	lrwxrwxrwx 1 osmc osmc 24 Sep  4 18:54 TV Shows -> /media/KINGSTON/TV Shows
	