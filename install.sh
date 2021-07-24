#!/bin/sh

clear

echo ; echo "Rivendell complete install script for Raspbian/Debian" ; echo "For more information visit https://github.com/edgeradio993fm" ; echo "More information and source code at rivendellaudio.org" ; echo

# Checking if rivendell package is installed
if dpkg -l | grep -qw rivendell
  then
    echo "Package rivendell is already installed" ; echo "Update your installation using: sudo apt update -y && sudo apt upgrade -y"
  else

echo ; echo "We need to download and install a bunch of packages before Rivendell. This process could take a while..." ; echo

# Debian multimedia repository
echo ; echo "Adding Debian Multimedia repository to your system..." ; echo

if grep -R -q "deb http://deb-multimedia.org buster main non-free" "/etc/apt/sources.list"
  then 
    echo "Reopsitory already added. Skipping..."
  else
    cd ~ && wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb && sudo sudo dpkg -i deb-multimedia-keyring_2016.8.1_all.deb && rm -r deb-multimedia-keyring_2016.8.1_all.deb && sudo echo "deb http://deb-multimedia.org buster main non-free" |sudo tee -a /etc/apt/sources.list
fi

# Check for old rivendell repository
echo ; echo "Checking for the old repository and removing if needed..." ; echo

if sudo sed -i '/7edg/d' /etc/apt/sources.list
  then 
    echo "Done!"
#  else
#    echo "No old repository found. Continuing..."
fi

# Rivendell repository
echo ; echo "Adding Rivendell on ARM repository to your system..." ; echo

if test -f /etc/apt/sources.list.d/7edg-rivendell-arm.list
  then 
    echo "Reopsitory already added. Skipping..."
  else
    curl -1sLf 'https://dl.cloudsmith.io/public/7edg/rivendell-arm/setup.deb.sh' | sudo -E distro=debian bash
fi

# Updating the apt database
echo ; echo "Making sure your package database is up to date..." ; echo

sudo apt update -y

# Install build tools
echo ; echo "Installing build tools..." ; echo

sudo apt install -y libtool m4 automake pkg-config make gcc g++ autofs

# Install Rivendell dependencies
echo ; echo "Installing Rivendell dependencies..." ; echo

sudo apt install -y libssh-dev libsamplerate0-dev libsndfile1-dev libcdparanoia-dev libid3-3.8.3-dev libcurl4-openssl-dev libpam0g-dev libsoundtouch-dev libasound2-dev libflac++-dev libmp4v2-dev libmad0-dev libtwolame-dev libmp3lame-dev libfaad-dev libqt4-dev libqt4-sql-mysql libexpat1-dev libtag1-dev libjack-jackd2-dev python3-mysqldb libmusicbrainz5-dev libcoverart-dev libcoverart1 libcoverartcc1v5 libdiscid0 libdiscid-dev

# Set path
export PATH=/sbin:$PATH

# Install Apache2 web server
echo ; echo "Installing and configuring Apache2..." ; echo

if dpkg -l | grep -qw apache2
  then
    echo "Package apache2 is already installed. Skipping..." ; echo
  else
	sudo apt install -y apache2
fi

# Enable Apache2 mods
sudo a2enmod cgid
sudo systemctl restart apache2

# Install MariaDB server
echo ; echo "Installing and configuring MariaDB..." ; echo

if dpkg -l | grep -qw mariadb-server
  then
    echo "Package mariadb-server is already installed. Skipping..." ; echo
  else
	sudo apt install -y mariadb-server
	sudo systemctl start mariadb
	sudo systemctl enable mariadb
fi

# Create audio storage and add current user as owner
echo "Making audio storage..." ; echo

if [ -d /var/snd ]
  then
    echo "Audio storage already exists. Skipping..."
  else
    sudo adduser --system --group --home=/var/snd rivendell ; sudo adduser $SUDO_USER rivendell ; sudo chmod g+w /var/snd
fi

# Install Rivendell
echo ; echo "Downloading Rivendell..." ; echo

sudo apt install rivendell

# Refresh linked libraries
sudo ldconfig

# Download the default Rivendell configuration file
echo ; echo "Downloading default configuration..." ; echo

if [ -f /etc/rd.conf ]
  then
    echo "Configuration already exists. Skipping..." ; echo
  else
    sudo wget -O /etc/rd.conf https://7edg.org/rdinstall/rd.conf
fi

# Enable the Rivendell Apache2 extentions
sudo a2enconf rd-bin
sudo systemctl restart apache2

# Create the database and populate tables
echo ; echo "Creating database and populating database tables..." ; echo

if [ -d /var/lib/mysql/Rivendell ]
  then
    echo "Database already exists. Skipping..."
  else
    sudo mysql -e "create database Rivendell;" ; sudo mysql -e "grant Select, Insert, Update, Delete, Create, Drop, References, Index, Alter, Create Temporary Tables, Lock Tables on Rivendell.* to rduser@'%' identified by 'letmein'"
    sudo rddbmgr --create --generate-audio
fi

# Start the Rivendell daemons and enable the service
sudo systemctl start rivendell
sudo systemctl enable rivendell

# Auto generate the default soundcard profile for Rivendell
sudo rdalsaconfig --autogen

echo ; echo "You may need to reboot to complete the install." ; echo All done. Enjoy.
fi
