sudo apt update 
sudo apt upgrade -y
sudo apt-get update
sudo apt-get install vlc inotify-tools x11-xserver-utils apache2 php libapache2-mod-php -y
sudo mkdir /var/www/html/uploads
sudo chmod 777 /var/www/html/uploads
sudo systemctl start apache2
sudo systemctl enable apache2
chmod +x loop_video.sh




@reboot export DISPLAY=:0 && /home/steve/loop_video.sh