#!/bin/sh

clear

echo Rivendell 3.2.0 update script for Raspbian/Debian
echo More information and Raspberry Pi images visit edgeradio.org.au
echo More information and source code at rivendellaudio.org
echo

if [ "$EUID" -ne 0 ]
  then echo "Please run this script as sudo/root user."
  exit
fi

#yes or no install question
while true
do
 read -r -p "Are you sure you want to update your install to Rivendell 3.2.0? It will take a couple of hours. [Y/n] " input

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

cd ~

echo Downloading Rivendell 3.2.0

wget  https://github.com/ElvishArtisan/rivendell/releases/download/v3.2.0/rivendell-3.2.0.tar.gz

echo Extracting files...

tar xf rivendell-3.2.0.tar.gz

cd rivendell-3.1.0

echo Generating Configuration

sudo ./autogen.sh

echo Configuring Rivendell Install...

sudo ./configure --libexecdir=/var/www/rd-bin --sysconfdir=/etc/apache2/conf-available --disable-docbook

echo Compiling Rivendell...

sudo make

echo Installing Rivendell...

sudo make install

sudo ldconfig

#ask for reboot
while true
do
read -r -p "Rivendell 3.2.0 is now installed. Do you want to update the database? [Y/n] " input

case $input in
     [yY][eE][sS]|[yY])
echo "Modifying Rivendell database"
	sudo rddbmgr --modify ;;
     [nN][oO]|[nN])
#echo "No"
	break ;;
	*)
echo "Invalid input..."
;;
esac
done

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
