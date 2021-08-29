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


echo ; echo "\e[7mRivendell upgrade script for Raspberry Pi OS and Debian Buster/Bullseye."
echo "For more information visit github.com/edgeradio993fm/rivendell"
echo "More information and original project source code at rivendellaudio.org\e[27m"
echo

# System details section
echo "\e[101mYour System Details\e[0m"
echo
echo "OS:" $distro $codename $version 
#$( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1
echo "Kernel:" $(uname) $(uname -r)
echo "User:" ${SUDO_USER:-$USER}
echo "Hostname:" $(hostname)
echo $(sudo rddbmgr)
echo

# Operating system detection to run approprate upgrade
YUM_PACKAGE_NAME="rivendell rivendell-pypad"
DEB_PACKAGE_NAME="rivendell rivendell-pypad"

# Check for CentOS and run the upgrade
if cat /etc/*release | grep ^NAME | grep CentOS 1> /dev/null; then
    echo "==============================================="
    echo "Upgrading package $YUM_PACKAGE_NAME on CentOS"
    echo "==============================================="
    yum install -y $YUM_PACKAGE_NAME

# Check for Debian
elif cat /etc/*release | grep ^NAME | grep Debian 1> /dev/null; then

# Checking for old repository and updating
    echo ; echo "\e[101mChecking for the old repository and removing if needed...\e[0m" ; echo
    if sudo sed -i '/7edg/d' /etc/apt/sources.list; then
    echo "Done!"
    else
    echo "Nothing to remove" ; echo
    fi

# Add Rivendell ARM repository if needed
    echo ; echo "\e[101mAdding Rivendell on ARM repository to your system...\e[0m" ; echo
    if cat /etc/*release | grep ^NAME | grep Debian 1> /dev/null | test -f /etc/apt/sources.list.d/7edg-rivendell4-arm.list; then
    echo "Reopsitory already added. Skipping..." ; echo
    else
    echo "Adding the reopsitory..." ; echo
    curl -1sLf 'https://dl.cloudsmith.io/public/7edg/rivendell4-arm/setup.deb.sh' | sudo -E distro=debian bash
    echo
    fi

# Run the upgrade for Debian
    echo "==============================================="
    echo "Upgrading package $DEB_PACKAGE_NAME on Debian"
    echo "==============================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
else
    echo "Your operating system isn't supported by this upgrade script, couldn't install package $PACKAGE"
    exit 1;
 fi

echo ; echo "\e[101mRestarting system services...\e[0m" ; echo

sudo systemctl daemon-reload
sudo systemctl restart rivendell
echo "Done!"

echo ; echo "\e[101mUpgrading database...\e[0m" ; echo

while true
do
read -r -p "Do you want to update the database? [Y/n] " input

case $input in
     [yY][eE][sS]|[yY])
echo ; echo "Modifying Rivendell database..."
	sudo rddbmgr --modify && break ;;
     [nN][oO]|[nN])
echo ; echo "Database not updated" ; echo
	break ;;
	*)
echo "Invalid input..."
;;
esac
done

echo "\e[101mUpgrade complete. Please reboot your machine to complete the upgrade.\e[0m" ; echo

exit 0
