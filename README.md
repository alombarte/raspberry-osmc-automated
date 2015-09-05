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

	
# Installation
In order to start the installation just SSH to your fresh OSMC installation in the raspeberry:

	ssh osmc@YOUR_OSMC_IP

Then the installation starts by copy-pasting this line:

	bash <(curl -s https://raw.githubusercontent.com/alombarte/raspberry-osmc-automated/master/install.sh) /home/osmc/.raspberry-osmc-automated
		
The installation script will download all necessary files and will configure the raspberry for you. During the installation process you will be asked for your `RSS feed` URL, your IP and the mountpoint of your external storage (if any).

### Getting the RSS feed
If you don't have a RSS you can sign up in a free service like [ShowRSS](http://showrss.info). Once you have done it add some TV Shows to your feed and then get the link by clicking ["Generate" in the feeds section](https://showrss.info/?cs=feeds) 


	
## To-do
- Spotify plugin
- Youtube plugin

