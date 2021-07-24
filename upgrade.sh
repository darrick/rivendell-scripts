#!/bin/sh

clear

echo ; echo "Rivendell update script for Raspbian/Debian ARM devices" ; echo

if [ "$EUID" -ne 0 ]
  then echo "Please run this script as sudo/root user."
  exit
fi

# Prompt for upgrade
if whiptail --yesno "Are you sure you want to update your Rivendell install the the latest version?" 20 60 ;then
    echo Yes
else
    echo No
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

sudo apt update

# Install Rivendell
echo ; echo "Downloading Rivendell update..." ; echo

sudo apt --only-upgrade install rivendell

# Update services
echo ; echo "Restarting Rivendell services..." ; echo
sudo ldconfig
sudo systemctl restart rivendell

# Prompt for database upgrade
if whiptail --yesno "Rivendell has now been upgraded. Only update your database on your Rivendell servers. Not your playout and workstations. Do you want to update the database?" 20 60 ;then
    echo Yes
	sudo rddbmgr --modify
else
    echo No
fi

# Prompt for reboot
if whiptail --yesno "It's recommended you reboot you computer to finalise any chages. In most cases you do not need to reboot. If you experience difficulties you can reboot at a later time. Would you like to reboot now?" 20 60 ;then
    echo Yes
	sudo reboot
else
    echo No
fi

echo Update complete.

