#!/bin/bash

# Install cron
sudo apt-get install cron --yes

# Crontab content
cat <<EOF > extra_lines
@reboot /usr/local/bin/flexget daemon start -d
@hourly /usr/local/bin/flexget --cron execute
@hourly wget --header='Content-Type: application/json' --post-data='{"method": "VideoLibrary.Scan", "id":5,"jsonrpc":"2.0"}' http://localhost/jsonrpc -O /dev/null
EOF

echo "Adding lines to user crontab:"
cat extra_lines

# Save current crontab
crontab -l > crontab_content
# Append extra lines
cat extra_lines >> crontab_content
crontab crontab_content

# Cleaning
rm crontab_content extra_lines


