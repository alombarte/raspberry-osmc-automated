[![Circle CI](https://circleci.com/gh/alombarte/raspberry-osmc-automated.svg?style=svg)](https://circleci.com/gh/alombarte/raspberry-osmc-automated)

Setup of a **media center**  with **automated episode downloads** in the background.

These are the applications this setup configures and automates for you:

- [OSMC](https://osmc.tv/) the operating system for the mediacenter, interacting with your own TV remote.
- [Transmission](http://www.transmissionbt.com/) to download torrents
- [Flex](http://flexget.com/) to automate jobs and such as the episode search, download, add subtitles or keep the house clean
- [Subliminal](https://github.com/Diaoul/subliminal) to integrate subtitles in your language
- Cronjobs, several of them to keep everything working in background

Watch TV as soon shows are released without doing anything.


## Requirements
- A running OSMC ([Download and install](https://osmc.tv/download/) here, easy as hell to install).
- Hardware: A Raspberry Pi (1 or 2), Vero or Apple TV
- An account in [ShowRSS](https://showrss.info/) or similar feed service that configures your own feed.

This setup has been tested in the latest OSMC at the moment of writing: [**release 2015.08-1**](https://osmc.tv/download/images/) (there is a new version now, should work)

## Features
After the installation you get a mediacenter operated from your TV remote. All your selected TV Shows are puctually downloaded in their correct folder with its subtitles, and the filesystem is kept clean and organized, no maintenance to do. Some of the features are:

- Operation from the remote, no mouse nor keyboard needed.
- The setup of your preferred TV Shows taken from ShowRSS or any other feed of your interest.
- All downloads automated, moved to the right folder structure when completed and using real episode names and season information (taken from TheTVDB).
- Automatic download of subtitles and retry of failed ones every hour.
- Downloads folder and transmission tasks always clean.
- Updated Kodi library with TV Shows covers and art cover.
- [optional] Delete shows that have been already seen to save storage

The following services can be used remotely:

Service  | Access  | User / Password
-------- | ---- | -----------
Transmission web client | http://$OSMC_HOST:9091 | transmission / transmission
Kodi Web (Remote) | http://$OSMC_HOST/ | None
Open SSH | ssh osmc@$OSMC_HOST |  osmc/osmc (`sudo` is available)

**Samba** is not installed, all my downloads go to an external storage (USB) that I can carry everywhere. Think that the Raspberry is not a regular PC and you can hit memory limits easily, the less services you put the better. Occasional transfers can be easily done using `scp myfile osmc@$OSMC_HOST`.


# Installation
In order to start the installation just SSH to your fresh OSMC installation in the raspeberry:

	ssh osmc@YOUR_OSMC_IP

Then the installation starts by copy-pasting this line:

	bash <(curl -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -s 'https://raw.githubusercontent.com/alombarte/raspberry-osmc-automated/master/install.sh') /home/osmc/.raspberry-osmc-automated  2>&1 | tee installation.log

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

- Just after an episode is downloaded: Flexget will use the `subliminal` tool to get the associate subtitle. This operation might fail if you are downloading a just aired episode and the subtitles have not been written yet.
- In order to complete any missing subtitles, every hour a cron job tries to download missing ones.

If post-install you ever need to change the subtitle language you need to edit 2 files:

- `	/home/osmc/.raspberry-osmc-automated/flex/config.yml` and change the 2 letter code (e.g `es`) in the following line: `exec:  subliminal download -l es ....`
- In the crontab with the command `crontab -e` and look for the line invoking `subliminal`

##### Using your addic7ed account
If you have an account in `addic7ed` you can pass your credentials in the aforementioned places adding the flag `--addic7ed YOURUSER YOURPASSWORD`. E.g:

	/usr/local/bin/subliminal --addic7ed YOURUSER YOURPASSWORD download -l es -s "/home/osmc/TV Shows/"

### Crontab
If you want to change the frequency of the feed checking, add, or remove jobs just execute:

	crontab -e

#### Deleting seen shows
In the crontab there is a commented job that deletes TV shows that are marked as seen by Kodi after 1 month. If you want to enable this feature just uncomment the line in the crontab and save.

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

### Other utils
#### Download all magnets in RSS feed.
The system keeps track of your series feed and downloads periodically all files found but you might need from time to time to parse and extract from another one (e.g: first day you download a new serie).
There is a bash script that adds in your transmission all magnets found:

	bash /home/osmc/.raspberry-osmc-automated/bash/download_magnets_in_rss.sh http://showrss.info/show/117.rss

The previous call would add to Transmission all magnets available for the serie.

## Spotify and Youtube
The spotify plugin doesn't come preinstalled. If you have a Premium account you will be able to install it using `bash/spotify.sh`.

The Youtube plugin can be installed manually from the Add-on repository browser.
