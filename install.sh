#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status
set -o pipefail # Ensure any command in a pipeline that fails will cause the script to fail

# Update and upgrade the system
sudo apt update 
sudo apt upgrade -y
sudo apt-get update

# Install necessary packages
sudo apt-get install -y vlc inotify-tools x11-xserver-utils apache2 php libapache2-mod-php

# Set up web server files
cd /var/www/html
sudo rm -f index.html
sudo wget https://raw.githubusercontent.com/steve0001/loop_video/main/index.php

# Create and set permissions for the uploads and images directories
sudo mkdir -p /var/www/html/uploads
sudo mkdir -p /var/www/html/images

# Download background and logo images
cd /var/www/html/images
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/images/background.png
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/images/logo.png
sudo chmod 777 /var/www/html/images
sudo chmod 777 /var/www/html/uploads

# Download the video looping script
sudo mkdir -p /script
cd /script
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/loop_video.sh
sudo chmod +x loop_video.sh

# Start and enable Apache2 service
sudo systemctl start apache2
sudo systemctl enable apache2

# Add to cron jobs to run loop_video.sh at reboot
CRON_JOB="@reboot export DISPLAY=:0 && /script/loop_video.sh"
(crontab -l 2>/dev/null | grep -Fq "$CRON_JOB") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# Confirm that the crontab was updated successfully
if crontab -l | grep -Fq "$CRON_JOB"; then
    echo "Cron job added successfully."
else
    echo "Failed to add cron job."
fi