Setup of a **media center**  with **automated episode/film downloads** in the background.

- [OSMC](https://osmc.tv/) for the mediacenter through your own TV remote.
- [Transmission](http://www.transmissionbt.com/) to download torrents
- [Flex](http://flexget.com/) to automate the episode search and download

Watch TV as soon shows are released without doing anything.


## Requirements
- A running OSMC ([Download and install](https://osmc.tv/download/) here, easy as hell).
- Hardware: A Raspberry Pi (1 or 2), Vero or Apple TV
- An account in [ShowRSS](https://showrss.info/) or similar feed service that configures your own feed.
 
This setup has been tested in the latest OSMC at the moment of writing: [**release 2015.08-1**](https://osmc.tv/download/images/)


## What you get...
- A mediacenter that works with your TV remote
- Your preferred TV Shows as soon as they are available
- All files when downloaded in their right folder structure
- Automatic subtitles in your language if you need them
- All the content can be in a USB to carry it anywhere

Apart from the OSMC, you have the following remote services:

Service  | Access  | User / Password
-------- | ---- | -----------
Transmission web client | http://$OSMC_HOST:9091 | transmission / transmission
Kodi Web (Remote) | http://$OSMC_HOST/ | None
Open SSH | ssh osmc@$OSMC_HOST |  osmc/osmc (`sudo` is available)

**Samba** is not installed. Is not necessary at all since the machine downloads everything. Punctual transfers can be done with `scp`. Raspberry has low RAM and the less services the better (Kodi already consumes a lot of RAM)

## Assumptions

When referring to `OSMC_HOST` this is the IP of your Rasperry. e.g:

	OSMC_HOST=192.168.1.135
	
# Installation

## SSH without password:
From your local machine (outside the raspberry):

  	# Put here your raspberry IP:
    OSMC_HOST=192.168.1.135
    
    # Copy SSH key to OSMC server
    cat ~/.ssh/id_rsa.pub | ssh osmc@$OSMC_HOST 'mkdir -p ~/.ssh; umask 077; cat >>~/.ssh/authorized_keys'
    
Now SSH to the server without password:

    ssh osmc@$OSMC_HOST

Now clone or download this project (or copy the folder) to `/home/omsc/.raspberry-osmc-automated`. If you change the path make sure to adjust the future steps in this readme. This can be done with:

	INSTALLATION_FOLDER=/home/osmc/.raspberry-osmc-automated
	
	wget https://github.com/alombarte/raspberry-osmc-automated/archive/master.zip -O raspberry-osmc-automated-master.zip
	unzip raspberry-osmc-automated-master.zip
	mv raspberry-osmc-automated-master $INSTALLATION_FOLDER
	rm raspberry-osmc-automated-master.zip
	
	
# Folder structure
Omit this section if you want to keep all your data in `/home/osmc` with the current mounted disk (make sure it has enough space). Make sure all services **have write permissions** to the `/home/osmc` folder.

I store all the data in a memory stick. As long as the USB media keeps the same name you can use as many as you want. I don't even change `fstab`. You can mount your own external hard disk too.

The example folder is `/media/KINGSTON` which is the default auto mount location of the 64GB Kingston stick I use (18€).

	# Put here the storage location
	EXTERNAL_STORAGE=/media/KINGSTON

	mkdir -p $EXTERNAL_STORAGE/{Downloads/Incomplete,Movies,Music,Pictures,"TV Shows"}

	# Delete default OSMC media folders in ~home and put symlinks to the USB.
	sudo rm -fri $EXTERNAL_STORAGE/{Downloads,Movies,Music,Pictures,"TV Shows"}
	ln -s $EXTERNAL_STORAGE/{Downloads,Movies,Music,Pictures,"TV Shows"} ~/
	
	# Add write permission to cosmic group. We will add other users in this group
	chmod -R 775 /home/osmc

The home directory `/home/omsc` looks like this:

	lrwxrwxrwx 1 osmc osmc 25 Sep  4 18:54 Downloads -> /media/KINGSTON/Downloads
	lrwxrwxrwx 1 osmc osmc 22 Sep  4 18:54 Movies -> /media/KINGSTON/Movies
	lrwxrwxrwx 1 osmc osmc 21 Sep  4 18:54 Music -> /media/KINGSTON/Music
	lrwxrwxrwx 1 osmc osmc 24 Sep  4 18:54 Pictures -> /media/KINGSTON/Pictures
	lrwxrwxrwx 1 osmc osmc 24 Sep  4 18:54 TV Shows -> /media/KINGSTON/TV Shows
	
### Purpose of the folders:

- `Downloads` is for **manually added** torrents to Transmission only. Otherwise, the automated jobs will put the downloads in the right category.
- `TV Shows` is where all episodes will be downloaded (using the structure `TV Shows/Show name/Season 1/Episode Name`)
- The rest seems obvious


# Install and configure Transmission

Just pass to the bash your network range, e.g: `192.168.1.*`

	bash ~/raspberry-osmc-automated/bash/install_transmission.sh "192.168.1.*"


## Install and configure FlexGet
FlexGet is installed through PIP. 

    sudo apt-get install python-pip python-setuptools

    # Avoids: pkg_resources.VersionConflict: (six 1.8.0 (/usr/lib/python2.7/dist-packages), Requirement.parse('six>=1.9.0'))
    sudo pip install six --upgrade
    
    sudo easy_install flexget
    
    # Should work, otherwise check dependencies:
    flexget -V
    
### Automation of the TV Shows task
The Real magic happens by configuring this task. Edit the file `/home/osmc/.raspberry-osmc-automated/flex/config.yml` and at least change the `rss` attribute, writing your own RSS feed from ShowRSS or similar.

When the file is saved:

    mkdir ~/.flexget
    ln -s /home/osmc/.raspberry-osmc-automated/flex/config.yml /home/osmc/.flexget/config.yml
    
**CAUTION**: `.yaml` file cannot contain tabs. Respect indentation using spaces.
    
Execute flex get to see ifit's working:

	/usr/local/bin/flexget exec
    
## Setup the crontab
Now is where everything is automated. Install the cron:
    
	sudo apt-get install cron

Now add two lines in the crontab.

	crontab -e
	
And add the following:
	
	@hourly /usr/local/bin/flexget --cron execute
	@reboot /usr/local/bin/flexget daemon start -d

# Setup finished!

# Miscellaneous things

#### Broken locales
If you see this message on every login:

	-bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)`
   
Possible fix:

    sudo locale-gen "en_US.UTF-8"
    sudo dpkg-reconfigure locales
    # Choose en_US.UTF-8

#### Force color prompt

Edit your `.bashrc` and uncomment, or for the lazy:

	sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc

#### Default editor
Set vi/nano/other default editor

	echo "export EDITOR=vi" >> ~/.bash_aliases	
	
# Not needed
	sudo apt-get install sqlite3

	sqlite> select * from seen_entry;
	sqlite> delete from seen_entry;

