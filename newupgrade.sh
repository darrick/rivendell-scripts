#!/bin/bash

clear

# Colour settings
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

cat << "EOF"
                                                                                             
,------. ,--.                           ,--.       ,--.,--.      ,---.  ,------. ,--.   ,--. 
|  .--. '`--',--.  ,--.,---. ,--,--,  ,-|  | ,---. |  ||  |     /  O  \ |  .--. '|   `.'   | 
|  '--'.',--. \  `'  /| .-. :|      \' .-. || .-. :|  ||  |    |  .-.  ||  '--'.'|  |'.'|  | 
|  |\  \ |  |  \    / \   --.|  ||  |\ `-' |\   --.|  ||  |    |  | |  ||  |\  \ |  |   |  | 
`--' '--'`--'   `--'   `----'`--''--' `---'  `----'`--'`--'    `--' `--'`--' '--'`--'   `--' 
                                                                                             
EOF

    test -f '/etc/os-release' && {
      . /etc/os-release
      distro=${distro:-$ID}
      codename=${codename:-$VERSION_CODENAME}
      codename=${codename:-$(echo $VERSION | cut -d '(' -f 2 | cut -d ')' -f 1)}
      version=${version:-$VERSION_ID}
}

# CPU arch detetction
arch=$(uname -m)
if [[ $arch == x86_64* ]]; then
    cpu="AMD/Intel 64bit Architecture"
elif [[ $arch == i*86 ]]; then
    cpu="AMD/Intel 32bit Architecture"
elif [[ $arch == arm* ]]; then
    cpu="ARM 32bit Architecture"
elif [[ $arch == aarch64 ]]; then
    cpu="ARM 64bit Architecture"
fi

echo ; echo "${red}Rivendell upgrade script for CentOS, Raspberry Pi OS and Debian Buster/Bullseye."
echo "For more information visit github.com/edgeradio993fm/rivendell"
echo "More information and original project source code at rivendellaudio.org${reset}"
echo

#while true; do
echo -n "Please enter the password for sudo user" ${red}${SUDO_USER:-$USER}${reset} "and press enter..."
echo
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"
#if su $USER -c true 2>/dev/null; then echo -e "\n${green}Success!${reset}"
#break
#echo
#else
#echo -e "\n${red}Wrong Password. Please try again or ctrl+c to exit.${reset}"
#echo
#fi
#done

# System details section
echo
echo "${green}Your System Details${reset}"
echo "OS:" $distro $version $codename
#$( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1
echo "Kernel:" $(uname) $(uname -r)
echo "Arch:" $cpu "($(uname -m))"
echo "Hostname:" $(hostname)
echo "IP Address:" $(hostname -I)
echo "User:" ${SUDO_USER:-$USER}
echo "Uptime:" $(uptime -p | cut -d " " -f2-)
echo

# Detection of Rivendell details
echo "${green}Your Rivendell Installation Details${reset}"
rddbmgr --version
sudo rddbmgr
echo

# Check if database is stored locally
if grep -rnwi '/etc/rd.conf' -e 'Hostname=localhost' 1>/dev/null; then
host="server"
echo "Looks like this system hosts a Rivendell database."
echo "This process will allow you to backup your current database and update your install to the latest schema."
echo "This assumes your installation uses the default database credentials."
echo "${red}Please Note: This process does not backup any audio files.${reset}"
else
host="workstation"
echo "Looks like this system is a Rivendell workstation."
echo "To be safe we will skip the database backup & update process after your installation is upgraded."
fi
echo

# Backup database if stored locally
if [[ "$host" == "server" ]]; then
while true; do
read -r -p "Would you like to backup your database before upgrading? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
    echo ; echo "${green}Backing up your database. Please wait...${reset}"
    mkdir ~/DB_BACKUP 2>/dev/null
    mysqldump -u rduser -pletmein -h localhost Rivendell > ~/DB_BACKUP/DBBK-$(date +%F).sql
    echo ; echo "Done! Your database backup is stored in $HOME/DB_BACKUP/" ; echo
    break
elif [[ ! "$response" =~ ^([yY][eE][sS]|[yY]|[nN][oO]|[nN])$ ]] ; then
    echo ; echo "${red}Invalid input...${reset}" ; echo
else
    echo ; echo "${red}Skipping...${reset}" ; echo
    break 1
fi
done
fi

while true; do
read -r -p "Are you sure you would like to upgrade your Rivendell installation? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
    echo ; echo "Continuing..."
    break
elif [[ ! "$response" =~ ^([yY][eE][sS]|[yY]|[nN][oO]|[nN])$ ]] ; then
    echo ; echo "${red}Invalid input...${reset}" ; echo
else
    echo ; echo "${red}Exiting...${reset}" ; echo
    exit 1
fi
done

# Package variables
YUM_PACKAGE_NAME="rivendell"
DEB_PACKAGE_NAME="rivendell"

# Check for CentOS and run the upgrade
if cat /etc/*release | grep ^NAME | grep CentOS 1> /dev/null; then
    echo
    echo "${green}Upgrading package $YUM_PACKAGE_NAME on "$distro${reset}
    echo
    sudo yum install -y $YUM_PACKAGE_NAME

# Check for Debian
elif cat /etc/*release | grep ^NAME | grep Debian 1> /dev/null || cat /etc/*release | grep ^NAME | grep Raspbian 1> /dev/null; then

# Checking for old repository and updating
    echo ; echo "${green}Checking for the old repository and removing if needed...${reset}" ; echo
    if sudo sed -i '/7edg/d' /etc/apt/sources.list; then
    echo "Done!"
    else
    echo "Nothing to remove" ; echo
    fi

# Add Rivendell ARM repository if needed
    echo ; echo "${green}Adding Rivendell on ARM repository to your system...${reset}" ; echo
    if cat /etc/*release | grep ^NAME | grep Debian 1> /dev/null | test -f /etc/apt/sources.list.d/7edg-rivendell-arm.list; then
    echo "Reopsitory already added. Skipping..." ; echo
    else
    echo "Adding the reopsitory..." ; echo
    curl -1sLf 'https://dl.cloudsmith.io/public/7edg/rivendell-arm/setup.deb.sh' | sudo -E distro=debian bash
    echo
    fi

# Run the upgrade for Debian
    echo
    echo "${green}Upgrading package $DEB_PACKAGE_NAME on "$distro${reset}
    echo
    sudo apt-get update
    sudo apt-get install -y $DEB_PACKAGE_NAME
else
    echo "Your operating system isn't supported by this upgrade script."
    exit 1;
 fi

echo ; echo "${green}Restarting system services...${reset}" ; echo

sudo ldconfig
sudo systemctl daemon-reload
sudo systemctl restart rivendell
echo "Done!"
echo

if [[ "$host" == "server" ]]; then
while true; do
read -r -p "Do you want to update your Rivendell database? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
    echo ; echo "${green}Modifying Rivendell database...${reset}"
    sudo rddbmgr --modify
    break
elif [[ ! "$response" =~ ^([yY][eE][sS]|[yY]|[nN][oO]|[nN])$ ]] ; then
    echo ; echo "${red}Invalid input...${reset}"
else
    echo ; echo "${red}Database not updated...${reset}"
    break 1
fi
done
fi

echo
echo "${green}Your Rivendell installation is now:${reset}"
sudo rddbmgr --version
sudo rddbmgr ; echo

echo "Upgrade complete. Please reboot your system to fully complete the upgrade." ; echo

exit 1
