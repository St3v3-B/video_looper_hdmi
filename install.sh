#!/bin/bash

# Update and upgrade the system
sudo apt update 
sudo apt upgrade -y
sudo apt-get update

# Install necessary packages
sudo apt-get install vlc inotify-tools x11-xserver-utils apache2 php libapache2-mod-php -y

# Set up web server files
cd /var/www/html
sudo rm index.html
sudo wget https://raw.githubusercontent.com/steve0001/loop_video/main/index.php

# Create and set permissions for the uploads and images directories
sudo mkdir /var/www/html/uploads
sudo mkdir /var/www/html/images

# Download background and logo images
cd /var/www/html/images
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/images/background.png
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/images/logo.png
sudo chmod 777 /var/www/html/images
sudo chmod 777 /var/www/html/uploads

# Download the video looping script
sudo mkdir /script
cd /script
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/loop_video.sh
sudo chmod +x loop_video.sh

# Start and enable Apache2 service
sudo systemctl start apache2
sudo systemctl enable apache2

# Add to cron jobs
(crontab -l 2>/dev/null; echo "@reboot export DISPLAY=:0 && /script/loop_video.sh") | crontab -