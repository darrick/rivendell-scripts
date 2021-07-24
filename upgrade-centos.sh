#!/bin/sh

clear

echo ; echo "Rivendell update script for CentOS" ; echo

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

# Updating the apt database
echo ; echo "Updating your package database and installing the latest Rivendell" ; echo

sudo yum update rivendell -y

# Update services
echo ; echo "Restarting Rivendell services..." ; echo
sudo ldconfig
sudo systemctl restart rivendell

# Prompt for database upgrade
if whiptail --yesno "Rivendell has now been upgraded. Only update your database on your Rivendell server(s). Not your playout and workstations. Do you want to update the database?" 20 60 ;then
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

