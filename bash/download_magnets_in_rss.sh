#!/bin/bash
# This script adds to transmission anything inside a <link> tag starting with "magnet" in the provided URL.

if [ $# != 1 ]
then
	echo "Adds all magnets inside a ShowRSS URL to transmission"
	echo "--USAGE: $0 \"http://showrss.info/show/117.rss\""
	exit 0
fi

for magnet in $(wget -q -O- "$1" | grep -oPm1 "(?<=<link>)[^<]+" | grep magnet | sort | uniq)
do
    echo "Adding magnet $magnet"	
    transmission-remote -a "$magnet"
done


