#!/bin/bash

#########################################
##     BUILDING FreeRDP-WebConnect     ##
#########################################
echo "---- Downloading FreeRDP-WebConnect Project ----"
cd /tmp
git clone https://github.com/HurricaneHernandez/FreeRDP-WebConnect.git
cd FreeRDP-WebConnect
./install_prereqs.sh
./setup-all.sh -f

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

mkdir -p /etc/service/wsgate
cat <<'EOT' > /etc/service/wsgate/run
#!/bin/bash
cd /wsgate
./wsgate -c wsgate.ini >> /var/log/wsgate 2>&1
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
apt-get purge --remove build-essential cmake git -y 
apt-get autoremove -y 
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/*
