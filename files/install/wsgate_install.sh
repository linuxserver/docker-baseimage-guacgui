#!/bin/bash
#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Install dependencies
apt-get install -qy --force-yes build-essential \
				g++-4.8 \
				libxml++2.6-dev \
				libssl-dev \
				libboost1.54-all-dev \
				libpng-dev \
				libdwarf-dev \
				subversion \
				subversion-tools \
				svn2cl \
				autotools-dev \
				autoconf \
				libtool \
				git \
				binutils-dev \
				binutils-multiarch-dev \
				cmake


# replace old gcc/g++ with new one
rm /usr/bin/g++  
ln -s /usr/bin/g++-4.8 /usr/bin/g++  
rm /usr/bin/gcc  
ln -s /usr/bin/gcc-4.8 /usr/bin/gcc 

#########################################
##     BUILDING FreeRDP-WebConnect     ##
#########################################
echo "---- Downloading FreeRDP-WebConnect Project ----"
cd /tmp
git clone https://github.com/HurricaneHernandez/FreeRDP-WebConnect.git
cd FreeRDP-WebConnect
./setup-all.sh -f

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

mkdir -p /etc/service/wsgate
cat <<'EOT' > /etc/service/wsgate/run
#!/bin/bash

#exec /wsgate/wsgate -c /wsgate/wsgate.ini >> /var/log/wsgate 2>&1
EOT


chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# Install wsgate
mkdir /wsgate
mv /tmp/FreeRDP-WebConnect/wsgate/build/* /wsgate
mv /tmp/wsgate.ini /wsgate/wsgate.ini

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
#apt-get purge --remove build-essential cmake subversion subversion-tools svn2cl git -y 
#apt-get autoremove -y 
#apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/*
