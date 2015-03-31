#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home
usermod -a -G adm,sudo nobody
echo "nobody:PASSWD" | chpasswd

# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Install Dependencies
apt-get update -qq
apt-get upgrade -qq
apt-get install -qy --force-yes --no-install-recommends xvfb \
							openjdk-7-jre \
							wget \
							openbox \ 
							python-pip \ 
							unzip \                                                          
							git \
							sudo \
							ttf-ubuntu-font-family


#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# User directory
mkdir /nobody && cp -R ~/.[a-zA-Z0-9]* /nobody
mkdir /nobody/.vnc
mkdir -p /nobody/.config/openbox
rm -r /nobody/.cache; mkdir /nobody/.cache

# Openbox User nobody autostart
cat <<'EOT' > /nobody/.config/openbox/autostart
# Programs that will run after Openbox has started

cd /tinyMediaManager
./tinyMediaManager.sh
EOT

# CONFIG
cat <<'EOT' > /etc/my_init.d/00_config.sh
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi
EOT

cat <<'EOT' > /etc/my_init.d/01_tmm_config.sh
echo "---> Setting up tinyMediaManager in volume..."
[[ ! -d /config ]] && mkdir /config
[[ ! -d /config/log ]] && mkdir /config/log
[[ ! -d /config/logs ]] && mkdir /config/logs
[[ ! -d /config/backup ]] && mkdir /config/backup
[[ ! -e /config/launcher.log ]] && touch /config/launcher.log
[[ ! -e /config/config.xml ]] && cp /tmmConfig/config.xml /config/config.xml
[[ ! -e /config/tmm.odb ]] && cp /tmmConfig/tmm.odb /config/tmm.odb

chown -R nobody:users /config

echo "---> Linking config files..."
ln -s /config/log /tinyMediaManager/log
ln -s /config/logs /tinyMediaManager/logs
ln -s /config/backup /tinyMediaManager/backup
ln -s /config/launcher.log /tinyMediaManager/launcher.log
ln -s /config/config.xml /tinyMediaManager/config.xml
ln -s /config/tmm.odb /tinyMediaManager/tmm.odb
EOT

# Xvfb
mkdir -p /etc/service/Xvfb
cat <<'EOT' > /etc/service/Xvfb/run
#!/bin/bash
umask 000
exec /usr/bin/Xvfb :1 -screen 0 1152x864x16
EOT

# xrdp
mkdir -p /etc/service/xrdp
cat <<'EOT' > /etc/service/xrdp/run
#!/bin/bash

RSAKEYS=/etc/xrdp/rsakeys.ini
PIDDIR=/var/run/xrdp/

if [ ! -d $PIDDIR ]; then
	mkdir $PIDDIR
fi

if [ ! -f $RSAKEYS ]; then
	echo "Generating xrdp RSA keys..."
	(umask 077 ; xrdp-keygen xrdp $RSAKEYS)
fi

exec /usr/sbin/xrdp --nodaemon >> /var/log/xrdp_run.log 2>&1
EOT

# xrdp-sesman
mkdir -p /etc/service/xrdp-sesman
cat <<'EOT' > /etc/service/xrdp-sesman/run
#!/bin/bash

PIDDIR=/var/run/xrdp/

if [ ! -d $PIDDIR ]; then
	mkdir $PIDDIR
fi

exec /usr/sbin/xrdp-sesman --nodaemon >> /var/log/xrdp-sesman_run.log 2>&1
EOT

# openbox
mkdir -p /etc/service/openbox
cat <<'EOT' > /etc/service/openbox/run
#!/bin/bash

DISPLAY=:1

exec /usr/bin/openbox-sessio >> /var/log/openbox_run.log 2>&1
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# Install x11rdp and xrdp
dpkg -i /tmp/debs/x11rdp_0.9.0+master-1_amd64.deb 
dpkg -i /tmp/debs/xrdp_0.9.0+master-1_amd64.deb
mv /tmp/tmmConfig /tmmConfig
mv /tmp/scripts /scripts
mv /tmp/tinyMediaManager /

chmod +x /tinyMediaManager/tinyMediaManager.sh /tinyMediaManager/tinyMediaManagerCMD.sh
