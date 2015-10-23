Setup of a **media center**  with **automated episode/film downloads** in the background.

- [OSMC](https://osmc.tv/) for the mediacenter, interacting with your own TV remote.
- [Transmission](http://www.transmissionbt.com/) to download torrents
- [Flex](http://flexget.com/) to automate the episode search and download

Watch TV as soon shows are released without doing anything.


## Requirements
- A running OSMC ([Download and install](https://osmc.tv/download/) here, easy as hell to install).
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

	
# Installation
In order to start the installation just SSH to your fresh OSMC installation in the raspeberry:

	ssh osmc@YOUR_OSMC_IP

Then the installation starts by copy-pasting this line:

	bash <(curl -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -s 'https://raw.githubusercontent.com/alombarte/raspberry-osmc-automated/master/install.sh') /home/osmc/.raspberry-osmc-automated
		
The installation script will download all necessary files and will configure the raspberry for you. During the installation process you will be asked for your `RSS feed` URL, your IP and the mountpoint of your external storage (if any).

**Your mediacenter is ready!**

### Getting the RSS feed
If you don't have a RSS you can sign up in a free service like [ShowRSS](http://showrss.info). Once you have done it add some TV Shows to your feed and then get the link by clicking ["Generate" in the feeds section](https://showrss.info/?cs=feeds) 


## Extending the configuration
If you want to tweak on the existing installation, this might help you a little bit. To begin with, all the configuration variables you chose during installation are saved in `/home/osmc/.raspberry-osmc-automated/bash/settings.cfg`. Don't change them because it doesn't have any effect, they are used only during the installation and are there for informative purposes afterwards.

The following paths assume you installed the application under `/home/osmc/.raspberry-osmc-automated`
### Changing the automation of TV Shows
The Real magic happens by configuring this task. The default task downloads all episodes to `/home/osmc/TV Shows`, it uses a structure like `TV Shows/Show name/Season 1/Episode Name`

For any changes edit the file:

	/home/osmc/.raspberry-osmc-automated/flex/config.yml
	
Then execute flexget to see if it's working (the flexget daemon might need to be restarted):

	/usr/local/bin/flexget exec
	
#### Subtitles
All jobs executed by flexget related with `TV Shows` try to download the subtitle in the language you chose during installation. There are 2 different attempts 2 download subtitles:

- Just after an episode is downloaded: Flexget will use the `periscope` tool to get the associate subtitle. This operation might fail if you are downloading a just aired episode and the subtitles have not been written yet.
- In order to complete any missing subtitles, everyday a cron job runs at `6:30 am` trying to complete them.

If you ever need to change the subtitle language you need to edit 2 files:

- `	/home/osmc/.raspberry-osmc-automated/flex/config.yml` and change the 2 letter code (e.g `es`) in the following line: `exec:  /usr/local/bin/periscope -l es ....`
- In the crontab with the command `crontab -e` and look for the line executed at 6:30am

### Crontab
If you want to change the frequency of the feed checking, add, or remove jobs just execute:

	crontab -e

### SSH without password:
If you want to stop typing the password every time you SSH to the Raspberry Pi do the following in your Mac/Linux:

	# Put here your raspberry IP, e.g:
	OSMC_HOST=192.168.1.10
	
	# Copy SSH key to OSMC server
	cat ~/.ssh/id_rsa.pub | ssh osmc@$OSMC_HOST 'mkdir -p ~/.ssh; umask 077; cat >>~/.ssh/authorized_keys'


### Broken locales?
If you see this message on every login:

	-bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)`
   
This is a possible fix:

    sudo locale-gen "en_US.UTF-8"
    sudo dpkg-reconfigure locales
    # Choose en_US.UTF-8

## To-do
- Spotify plugin
- Youtube plugin

