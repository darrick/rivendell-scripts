### Generating the Repository and Install Packages

---

####Repository Setup

Reference Guide: [https://blog.packagecloud.io/eng/2017/03/23/create-debian-repository-reprepro/](https://blog.packagecloud.io/eng/2017/03/23/create-debian-repository-reprepro/)

**Create a Release**
1. Navigate to **/var/www/html** and place your .deb file here.
2.  Run the following command to generate a release.
``` sudo reprepro -b repo/ includedeb buster rivendell_3.3.0-3_armhf.deb ```
3. Test your updated release on a client machine.
``` sudo apt update -y && sudo apt upgrade -y ```

**Generating Public GPG Repository Key**
``` sudo gpg --output rivendellpi.key --armor --export you@yourdomain.com ```

***Add the Repository to a Client Machine***
1. Add the repository GPG key.
``` wget -qO - https://7edg.org/repo/rivendellpi.key | sudo apt-key add - ```
2. Add the repository to the /etc/apt/sources.list file.
``` sudo echo "deb https://7edg.org/repo buster main" | sudo tee -a /etc/apt/sources.list ```

---

####Generating Install Packages

The **deb** packages are generated using the **checkinstall** utility. This utility is avalaible in the Raspbian repositories but not the Debian Buster repositories. You must set up the Buster Backports repository to be albel to install and use checkinstall.

**Setting up Buster Backports and Installing Checkinstall.**
1. Add Buster Backports repository to the /etc/apt/sources.list file.
``` sudo echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list ```
2. Update and install checkinstall.
``` sudo apt update -y && apt -t buster-backports install checkinstall -y ```

**Generating the Packages**
1. Once you have configured and compliled Rivendell, you now must run the checkinstall process with the following command. Make sure you update the package version. Also make sure **description-pak**, **preinstall-pak** and **postinstall-pak** are in the root Rivendell directory as they will be read by checkinstall.
``` sudo checkinstall --install=no --pkgname=rivendell --pkgversion=3.3.0 --pkgsource=https://github.com/ElvishArtisan/rivendell --pkgaltsource=https://github.com/edgeradio993fm/rivendell --maintainer=tech@edgeradio.org.au --replaces=rivendell --requires=libssh-dev,libsamplerate0-dev,libsndfile1-dev,libcdparanoia-dev,libid3-3.8.3-dev,libcurl4-openssl-dev,libpam0g-dev,libsoundtouch-dev,libasound2-dev,libflac++-dev,libmp4v2-dev,libmad0-dev,libtwolame-dev,libmp3lame-dev,libfaad-dev,libqt4-dev,libqt4-sql-mysql,libexpat1-dev,libtag1-dev,libjack-jackd2-dev,autofs,python3-mysqldb,libtool,m4,automake,pkg-config,make,gcc,g++,apache2,mariadb-server,libmusicbrainz5-dev,libcoverart-dev,libcoverart1,libcoverartcc1v5,libdiscid0,libdiscid-dev ```
2. You will now have a .deb install file in the Rivendell root directory to upload to the repository for release after testing.