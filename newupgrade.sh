#!/usr/bin/env bash

clear

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


red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

echo ; echo "${red}Rivendell upgrade script for CentOS, Raspberry Pi OS and Debian Buster/Bullseye."
echo "For more information visit github.com/edgeradio993fm/rivendell"
echo "More information and original project source code at rivendellaudio.org${reset}"
echo

# System details section
echo "${green}Your System Details${reset}"
echo
echo "OS:" $distro $version $codename
#$( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1
echo "Kernel:" $(uname) $(uname -r)
echo "User:" ${SUDO_USER:-$USER}
echo "Hostname:" $(hostname)
echo $(sudo rddbmgr)
echo

while true
do
 read -r -p "Are you sure you want to ugrade your Rivendell installation? [Y/n] " input

 case $input in
     [yY][eE][sS]|[yY])
 echo "Yes"
 break
 ;;
     [nN][oO]|[nN])
 echo ; echo "${red}Exiting...${reset}" ; echo
 exit
        ;;
     *)
 echo "Invalid input..."
 ;;
 esac
done || exit 1

# Package variables
YUM_PACKAGE_NAME="rivendell"
DEB_PACKAGE_NAME="rivendell"

# Check for CentOS and run the upgrade
if cat /etc/*release | grep ^NAME | grep CentOS 1> /dev/null; then
    echo "==============================================="
    echo "Upgrading package $YUM_PACKAGE_NAME on "$distro
    echo "==============================================="
    yum install -y $YUM_PACKAGE_NAME

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
    echo "==============================================="
    echo "Upgrading package $DEB_PACKAGE_NAME on "$distro
    echo "==============================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
else
    echo "Your operating system isn't supported by this upgrade script."
    exit 1;
 fi

echo ; echo "${green}Restarting system services...${reset}" ; echo

sudo systemctl daemon-reload
sudo systemctl restart rivendell
echo "Done!"

echo ; echo "${green}Upgrading database...${reset}" ; echo

while true; do
read -r -p "Do you want to update the database? [Y/n] " input

case $input in
     [yY][eE][sS]|[yY])
echo ; echo "${green}Modifying Rivendell database...${reset}" ; echo
	sudo rddbmgr --modify && break ;;
     [nN][oO]|[nN])
echo ; echo "${red}Database not updated${reset}" ; echo
	break ;;
	*)
echo "${red}Invalid input...${reset}"
;;
esac
done

echo "${green}Upgrade complete. Please reboot your machine to complete the upgrade.${reset}" ; echo

exit 0
