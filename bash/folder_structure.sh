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