#!/bin/bash
if [ $# != 1]
then
	echo "Installs the crontab"
	echo "--USAGE: $0 2_letter_code_subtitles_language"
	echo "e.g: $0 es (Cron will download subtitles in Spanish)"
	exit 0
fi
# Install cron
sudo apt-get install cron --yes

# Crontab content
cat <<EOF > extra_lines
@reboot /usr/local/bin/flexget daemon start -d
@hourly /usr/local/bin/flexget --cron execute
@hourly wget --header='Content-Type: application/json' --post-data='{"method": "VideoLibrary.Scan", "id":5,"jsonrpc":"2.0"}' http://localhost/jsonrpc -O /dev/null
# Delete images, text files and existing subtitles. Then delete any empty dir in Downloads.
@hourly find /home/osmc/Downloads/. \( -name "*.jpg" -o -name "*.png" -o -name "*.txt" -o -name "*.nfo" -o -name "*.srt" \) -delete && find /home/osmc/Downloads/. -type d -empty -delete
# Download all missing subtitles every morning 6:30am
30 6 * * * /usr/local/bin/subliminal download -l SUBTITLES_LANGUAGE -s "/home/osmc/TV Shows/
EOF

echo "Adding lines to user crontab:"
sed -i "s/SUBTITLES_LANGUAGE/$1/" extra_lines
cat extra_lines

# Save current crontab content
crontab -l > crontab_content
# Append extra lines
cat extra_lines >> crontab_content
crontab crontab_content

# Cleaning
rm crontab_content extra_lines


