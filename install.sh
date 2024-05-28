#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status
set -o pipefail # Ensure any command in a pipeline that fails will cause the script to fail

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y
sudo apt-get update

# Install necessary packages
sudo apt-get install -y vlc inotify-tools x11-xserver-utils apache2 php libapache2-mod-php

# Clean up old files
echo "Cleaning up old files..."
sudo rm -rf /var/www/html/uploads /var/www/html/images /var/www/html/index.html /script /var/www/html/config.txt

# Set up web server files
cd /var/www/html
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/index.php

# Create and set permissions for the uploads and images directories
sudo mkdir -p /var/www/html/uploads
sudo mkdir -p /var/www/html/images

# Download background and logo images
cd /var/www/html/images
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/images/background.png
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/images/logo.png
sudo chmod 777 /var/www/html/images
sudo chmod 777 /var/www/html/uploads


# Create the empty config.txt file
CONFIG_FILE="/var/www/html/config.txt"
echo "Creating empty config.txt file..."
sudo touch $CONFIG_FILE
sudo chmod 644 $CONFIG_FILE
sudo chmod 777 /var/www/html/config.txt

# Download the video looping script
sudo mkdir -p /script
cd /script
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/loop_video.sh
sudo chmod +x loop_video.sh

# Modify PHP configuration
PHP_INI_FILE="/etc/php/8.2/apache2/php.ini"
PHP_INI_DIR=$(dirname "$PHP_INI_FILE")

if [ -f "$PHP_INI_FILE" ]; then
    # Ensure the directory and the file have writable permissions
    sudo chmod u+w "$PHP_INI_DIR"
    sudo chmod u+w "$PHP_INI_FILE"

    # Attempt to modify the file
    sudo sed -i 's/^upload_max_filesize = [0-9]\+M/upload_max_filesize = 8192M/' "$PHP_INI_FILE" || { echo "Failed to update upload_max_filesize"; exit 1; }
    sudo sed -i 's/^post_max_size = [0-9]\+M/post_max_size = 8192M/' "$PHP_INI_FILE" || { echo "Failed to update post_max_size"; exit 1; }

    # Revert permissions to read-only for security
    sudo chmod u-w "$PHP_INI_FILE"
    sudo chmod u-w "$PHP_INI_DIR"
else
    echo "PHP configuration file not found: $PHP_INI_FILE"
    exit 1
fi

# Restart Apache2 service to apply changes
sudo systemctl restart apache2

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

echo "Installation complete."