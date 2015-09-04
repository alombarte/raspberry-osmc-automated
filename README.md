Setup of a **media center** ([OSMC](https://osmc.tv/)) with **automated downloads** ([Transmission](http://www.transmissionbt.com/) + [Flex](http://flexget.com/)) in the background for new TV Shows, films or whatever you want. It's able to configure tasks to automate anything! 

All the magic possible thanks to **OSMC (media center)+ Transmission (torrent downloads) + Flex (automated taks)**


The main idea is to avoid any manual intervention to watch  your preferred shows, just sit and watch TV.


## Requirements
- A running OSMC ([Download](https://osmc.tv/download/) here).
- Hardware: A Raspberry Pi (1 or 2), Vero or Apple TV
- An account in [ShowRSS](https://showrss.info/) or similar RSS service that configures your own feed.
 
 
Tested on OSMC [**release 2015.08-1**](https://osmc.tv/download/images/)


## What you get:
- A mediacenter that works with your TV remote
- Your preferred TV Shows as soon as they are available
- All files when downloaded in their right folder structure
- Automatic subtitles in your language if you need them

Apart from the OSMC, you have the following remote services:

Service  | URL  | User / Password
-------- | ---- | -----------
Transmission GUI | http://$OSMC_HOST:9091 | transmission / transmission
Kodi Remote | http://$OSMC_HOST/ | None
Open SSH | ssh $OSMC_HOST |  osmc/osmc (`sudo` is available)

**Samba** is not installed. Is not necessary at all since the machine downloads everything. Punctual transfers can be done with `scp`. Raspberry has low RAM and the less services the better (Kodi already consumes a lot of RAM)

## Assumptions

When referring to `OSMC_HOST` this is the IP of your Rasperry. e.g:

	OSMC_HOST=192.168.1.135
	
# Setup

From your local machine:

  	
    OSMC_HOST=192.168.1.135
    # Copy SSH key to OSMC server
    cat ~/.ssh/id_rsa.pub | ssh osmc@$OSMC_HOST 'mkdir -p ~/.ssh; umask 077; cat >>~/.ssh/authorized_keys'
    
Now SSH to the server:

    ssh osmc@$OSMC_HOST

# Prepare your folder structure
Omit this section if you want to keep all your data in `/home/osmc` with the current mounted disk.

I store all the data in a memory stick. As long as the USB media keeps the same name you can use as many as you want. I don't even change `fstab`.

Example folder is `/media/KINGSTON` which is the default auto mount location of the 64GB Kingston stick I use (18€).

	
	STORAGE_FOLDER=/media/KINGSTON

	mkdir -p $STORAGE_FOLDER/{Downloads/Incomplete,Movies,Music,Pictures,"TV Shows"}

	# Delete default folders in home and put symlinks to the USB.
	sudo rm -fri $STORAGE_FOLDER/{Downloads,Movies,Music,Pictures,"TV Shows"}
	ln -s $STORAGE_FOLDER/{Downloads,Movies,Music,Pictures,"TV Shows"} ~/

The home directory `/home/omsc` looks like this:

	lrwxrwxrwx 1 osmc osmc 25 Sep  4 18:54 Downloads -> /media/KINGSTON/Downloads
	lrwxrwxrwx 1 osmc osmc 22 Sep  4 18:54 Movies -> /media/KINGSTON/Movies
	lrwxrwxrwx 1 osmc osmc 21 Sep  4 18:54 Music -> /media/KINGSTON/Music
	lrwxrwxrwx 1 osmc osmc 24 Sep  4 18:54 Pictures -> /media/KINGSTON/Pictures
	lrwxrwxrwx 1 osmc osmc 24 Sep  4 18:54 TV Shows -> /media/KINGSTON/TV Shows
	
- Downloads is for manually added torrents to Transmission
- TV Shows is where all episodes are downloaded to with the structure `TV Shows/Show name/Season 1/Episode Name`



# FlexGet
    sudo apt-get install python-pip python-setuptools
    # Avoids: pkg_resources.VersionConflict: (six 1.8.0 (/usr/lib/python2.7/dist-packages), Requirement.parse('six>=1.9.0'))
    sudo pip install six --upgrade
    sudo easy_install flexget
    flexget -V
    mkdir ~/.flexget
    cat <<EOF > /home/osmc/.flexget/config.yml
tasks:
  # downloading task
  download-rss:
    rss: http://showrss.info/rss.php?user_id=51436&hd=2&proper=1
    # fetch all the feed series
    all_series: yes
    # use transmission to download the torrents
    transmission:
      host: localhost
      port: 9091
      username: transmission
      password: transmission
  # sorting task
  sort-files:
    find:
      # directory with the files to be sorted
      path: /home/osmc/Downloads/
      # fetch all avi, mkv and mp4 files, skips the .part files (unfinished torrents)
      regexp: '.*\.(avi|mkv|mp4)$'
    accept_all: yes
    seen: local
    # this is needed for the episode names
    thetvdb_lookup: yes
    all_series:
      # for some reason all_series rejects all episodes here, even with seen: local, so parse_only must be added
      parse_only: yes
    # TVDB doesn't recognise "Adventure Time with Finn and Jake" so you must add such exceptions here manually
    series:
      - Adventure Time
    move:
      # this is where the series will be put
      to: /home/osmc/TV Shows/{{ tvdb_series_name }}
      # save the file as "Series Name - SxxEyy - Episode Name.ext"
      filename: '{{ tvdb_series_name }} - {{ series_id }} - {{ tvdb_ep_name }}{{ location | pathext }}'
EOF
    
# Samba (TODO)

    sudo apt-get install samba

    sudo vi /etc/samba/smb.conf
    # Change read only to no in [homes] section to write cosmic home folder
    # read only = no

    sudo smbpasswd osmc
    
# Transmission

    sudo apt-get install transmission-daemon
    sudo apt-get install python-transmissionrpc

    sudo /etc/init.d/transmission-daemon stop
    sudo vi /etc/transmission-daemon/settings.json
    
    sudo adduser debian-transmission osmc
    
    
    # Add the IPs connecting to http://192.168.1.135:9091/
    # "rpc-whitelist": "127.0.0.1,192.168.1.*",
    # Change downloading dirs from/var/lib/transmission-daemon/ to folders with space:
    sudo sed -i 's@/var/lib/transmission-daemon/downloads@/home/osmc/Downloads@' /etc/transmission-daemon/settings.json
    sudo sed -i 's@/var/lib/transmission-daemon/Downloads@/home/osmc/Downloads/Incomplete@' /etc/transmission-daemon/settings.json
    sudo /etc/init.d/transmission-daemon start
    
    
    
    CRON
    
	sudo apt-get install cron
	crontab -e
	# ADD:
	# @hourly /usr/local/bin/flexget --cron execute
	#@reboot /usr/local/bin/flexget daemon start -d

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

