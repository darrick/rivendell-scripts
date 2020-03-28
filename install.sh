#!/bin/sh

clear

echo
echo Rivendell complete install script for Raspbian/Debian
echo More information and Raspberry Pi images visit https://github.com/edgeradio993fm
echo More information and source code at rivendellaudio.org
echo

echo We need to download and install a bunch of packages before Rivendell. This process could take a while...
echo

echo Adding Rivendell on Raspberry Pi repo to your system...
echo

wget -qO - https://7edg.org/repo/rivendellpi.key | sudo apt-key add -

sudo echo "deb https://7edg.org/repo buster main" |sudo tee -a /etc/apt/sources.list

echo
echo Making sure your package database is up to date...
echo

sudo apt update -y && sudo apt upgrade -y

echo
echo Installing build tools...
echo

sudo apt install -y libtool m4 automake pkg-config make gcc g++ autofs

echo
echo Installing Rivendell dependencies...
echo

sudo apt install -y libssh-dev libsamplerate0-dev libsndfile1-dev libcdparanoia-dev libid3-3.8.3-dev libcurl4-openssl-dev libpam0g-dev libsoundtouch-dev libasound2-dev libflac++-dev libmp4v2-dev libmad0-dev libtwolame-dev libmp3lame-dev libfaad-dev libqt4-dev libqt4-sql-mysql libexpat1-dev libtag1-dev libjack-jackd2-dev python3-mysqldb libmusicbrainz5-dev libcoverart-dev libcoverart1 libcoverartcc1v5 libdiscid0 libdiscid-dev

export PATH=/sbin:$PATH

echo
echo Installing and configuring Apache2...
echo

sudo apt install -y apache2

sudo a2enmod cgid

sudo systemctl restart apache2

echo
echo Installing and configuring MariaDB...
echo

sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo mysql -e "create database Rivendell;"
sudo mysql -e "grant Select, Insert, Update, Delete, Create, Drop, References, Index, Alter, Create Temporary Tables, Lock Tables on Rivendell.* to rduser@'%' identified by 'letmein';"

echo
echo Making audio storage...
echo

sudo adduser --system --group --home=/var/snd rivendell
sudo adduser $SUDO_USER rivendell
sudo chmod g+w /var/snd

cd /home/$SUDO_USER

echo
echo Downloading Rivendell...
echo

sudo apt install rivendell

sudo ldconfig

echo
echo Downloading default configuration...
echo

sudo wget -O /etc/rd.conf https://7edg.org/rdinstall/rd.conf

sudo a2enconf rd-bin
sudo systemctl restart apache2

echo
echo Creating database...
echo

sudo rddbmgr --create --generate-audio
sudo systemctl start rivendell
sudo systemctl enable rivendell

echo
echo You may need to reboot your Raspberry Pi to complete the install.
echo All done. Enjoy.
