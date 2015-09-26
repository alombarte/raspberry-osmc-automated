#!/bin/bash

# Packages not needed by the system, but useful
PACKAGES=(git vim sendmail)

echo "The following packages are NOT needed by the mediacenter."
echo "Press 'y' to install if you'll need the package or any other key to discard it:"
for pkg in ${PACKAGES[@]}
do
	read -p "- Install $pkg? [y/N] " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	    sudo apt-get install $pkg --yes
	fi
done
