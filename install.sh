#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status
set -o pipefail # Ensure any command in a pipeline that fails will cause the script to fail

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Update and upgrade the system
echo -e "${YELLOW}Updating and upgrading the system...${NC}"
sudo apt update
sudo apt upgrade -y
sudo apt-get update

# Install necessary packages
echo -e "${YELLOW}Installing necessary packages...${NC}"
sudo apt-get install -y vlc inotify-tools x11-xserver-utils apache2 php libapache2-mod-php

# Clean up old files
echo -e "${YELLOW}Cleaning up old files...${NC}"
sudo rm -rf /var/www/html/uploads /var/www/html/images /var/www/html/index.html /script /var/www/html/config.txt

# Set up web server files
echo -e "${YELLOW}Setting up web server files...${NC}"
cd /var/www/html
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/index.php

# Create and set permissions for the uploads and images directories
echo -e "${YELLOW}Creating and setting permissions for the uploads and images directories...${NC}"
sudo mkdir -p /var/www/html/uploads
sudo mkdir -p /var/www/html/images

# Download background and logo images
echo -e "${YELLOW}Downloading background and logo images...${NC}"
cd /var/www/html/images
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/images/background.png
sudo wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/images/logo.png
sudo chmod 777 /var/www/html/images
sudo chmod 777 /var/www/html/uploads

# Create the empty config.txt file
CONFIG_FILE="/var/www/html/config.txt"
echo -e "${YELLOW}Creating empty config.txt file...${NC}"
sudo touch $CONFIG_FILE
sudo chmod 777 $CONFIG_FILE

# Download the video looping script as user pi
echo -e "${YELLOW}Downloading the video looping script as user pi...${NC}"
mkdir -p /home/pi/script
cd /home/pi/script
wget https://raw.githubusercontent.com/St3v3-B/video_looper_hdmi/main/loop_video.sh
sudo chmod +x loop_video.sh

# Create the empty vlc_script.log file
LOG_FILE="/home/pi/script/vlc_script.log"
echo -e "${YELLOW}Creating empty vlc_script.log file...${NC}"
sudo touch $LOG_FILE
sudo chmod 777 $LOG_FILE

# Modify PHP configuration
PHP_INI_FILE="/etc/php/8.2/apache2/php.ini"
PHP_INI_DIR=$(dirname "$PHP_INI_FILE")

echo -e "${YELLOW}Modifying PHP configuration...${NC}"
if [ -f "$PHP_INI_FILE" ]; then
    # Ensure the directory and the file have writable permissions
    sudo chmod u+w "$PHP_INI_DIR"
    sudo chmod u+w "$PHP_INI_FILE"

    # Attempt to modify the file
    sudo sed -i 's/^upload_max_filesize = [0-9]\+M/upload_max_filesize = 8192M/' "$PHP_INI_FILE" || { echo -e "${RED}Failed to update upload_max_filesize${NC}"; exit 1; }
    sudo sed -i 's/^post_max_size = [0-9]\+M/post_max_size = 8192M/' "$PHP_INI_FILE" || { echo -e "${RED}Failed to update post_max_size${NC}"; exit 1; }

    # Revert permissions to read-only for security
    sudo chmod u-w "$PHP_INI_FILE"
    sudo chmod u-w "$PHP_INI_DIR"
else
    echo -e "${RED}PHP configuration file not found: $PHP_INI_FILE${NC}"
    exit 1
fi

# Restart Apache2 service to apply changes
echo -e "${YELLOW}Restarting Apache2 service to apply changes...${NC}"
sudo systemctl restart apache2

# Start and enable Apache2 service
echo -e "${YELLOW}Starting and enabling Apache2 service...${NC}"
sudo systemctl start apache2
sudo systemctl enable apache2

# Add to cron jobs to run loop_video.sh at reboot as user pi
echo -e "${YELLOW}Adding to cron jobs to run loop_video.sh at reboot as user pi...${NC}"
CRON_JOB="@reboot export DISPLAY=:0 && /home/pi/script/loop_video.sh"
(crontab -u pi -l 2>/dev/null | grep -Fq "$CRON_JOB") || (crontab -u pi -l 2>/dev/null; echo "$CRON_JOB") | crontab -u pi -

# Confirm that the crontab was updated successfully
if crontab -u pi -l | grep -Fq "$CRON_JOB"; then
    echo -e "${GREEN}Cron job added successfully.${NC}"
else
    echo -e "${RED}Failed to add cron job.${NC}"
fi

echo -e "${GREEN}Installation complete.${NC}"
