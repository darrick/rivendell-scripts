#!/bin/sh

clear

echo
echo Rivendell Github install Script for Raspbian/Debian
echo More information and Raspberry Pi images visit edgeradio.org.au
echo More information and source code at rivendellaudio.org
echo

#check for root user
if [ "$(id -u)" != "0" ]; then
	echo "You need to run this script as sudo/root."
	exit 1
fi

#yes or no install question
while true
do
 read -r -p "Are you sure you want to install the latest Rivendell github? It will take a couple of hours. [Y/n] " input

 case $input in
     [yY][eE][sS]|[yY])
 #echo "Yes"
	break ;;
     [nN][oO]|[nN])
 echo "Okay. Maybe next time."
       exit ;;
     *)
 echo "Invalid input..."
 ;;
 esac
done

echo
echo We need to download and install a bunch of packages before Rivendell. This process could take a while...
echo

echo Making sure your package database is up to date...

sudo apt update

echo Installing build tools...

sudo apt install -y libtool m4 automake pkg-config make gcc g++

echo Installing Rivendell dependencies...

sudo apt install -y libssh-dev libsamplerate0-dev libsndfile1-dev libcdparanoia-dev libid3-3.8.3-dev libcurl4-openssl-dev libpam0g-dev libsoundtouch-dev libasound2-dev libflac++-dev libmp4v2-dev libmad0-dev libtwolame-dev libmp3lame-dev libfaad-dev libqt4-dev libqt4-sql-mysql libexpat1-dev libtag1-dev libjack-jackd2-dev

export PATH=/sbin:$PATH

echo Installing and configuring Apache2...

sudo apt install -y apache2

sudo a2enmod cgid

sudo systemctl restart apache2

echo Installing and configuring MariaDB...

sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo mysql -e "create database Rivendell;"
sudo mysql -e "grant Select, Insert, Update, Delete, Create, Drop, References, Index, Alter, Create Temporary Tables, Lock Tables on Rivendell.* to rduser@'%' identified by 'letmein';"

echo Making audio storage...

sudo adduser --system --group --home=/var/snd rivendell
sudo adduser $SUDO_USER rivendell
sudo chmod g+w /var/snd

cd /home/$SUDO_USER

echo Downloading Rivendell

git clone https://github.com/ElvishArtisan/rivendell.git

cd rivendell

echo Generating Configuration...

sudo ./autogen.sh

echo Configuring Rivendell Install...

sudo ./configure --libexecdir=/var/www/rd-bin --sysconfdir=/etc/apache2/conf-available --disable-docbook

echo Compiling Rivendell...

sudo make

echo Installing Rivendell...

sudo make install

sudo ldconfig

sudo cp conf/rd.conf-sample /etc/rd.conf

sudo a2enconf rd-bin
sudo systemctl reload apache2

sudo rddbmgr --create --generate-audio
sudo systemctl start rivendell
sudo systemctl enable rivendell

#ask for reboot
while true
do
read -r -p "It's recommended your reboot you computer to finalise any chages. Would you like to do that now? [Y/n] " input

case $input in
     [yY][eE][sS]|[yY])
echo "Rebooting..."
	sudo reboot ;;
     [nN][oO]|[nN])
#echo "No"
	break ;;
	*)
echo "Invalid input..."
;;
esac
done

echo All done. Enjoy.
