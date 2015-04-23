#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -m -d /nobody nobody
usermod -s /bin/bash nobody
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
apt-get install -qy --force-yes --no-install-recommends xvfb \
							openjdk-7-jre \
							wget \
							openbox \
							unzip \
							python2.7 \
							x11vnc 

# xrdp needs to be installed seperately
apt-get install -qy --force-yes xrdp


#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# User directory
mkdir /nobody
mkdir -p /nobody/.config/openbox
mkdir /nobody/.cache
mkdir /root/.vnc

# Openbox User nobody autostart
cat <<'EOT' > /nobody/.config/openbox/autostart
# Programs that will run after Openbox has started

cd /tinyMediaManager
java -Djava.net.preferIPv4Stack=true -jar getdown.jar .
EOT

# config
cat <<'EOT' > /etc/my_init.d/00_config.sh
#!/bin/bash
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi
EOT

# tmm config
cat <<'EOT' > /etc/my_init.d/01_tmm_config.sh
#!/bin/bash
[[ ! -d /config ]] && mkdir /config
[[ ! -d /config/log ]] && mkdir /config/log
[[ ! -d /config/logs ]] && mkdir /config/logs
[[ ! -d /config/backup ]] && mkdir /config/backup
[[ ! -e /config/launcher.log ]] && touch /config/launcher.log
[[ ! -e /config/config.xml ]] && cp /tmmConfig/config.xml /config/config.xml
[[ ! -e /config/tmm.odb ]] && cp /tmmConfig/tmm.odb /config/tmm.odb
[[ ! -L /tinyMediaManager/log ]] && ln -s /config/log /tinyMediaManager/log
[[ ! -L /tinyMediaManager/logs ]] && ln -s /config/logs /tinyMediaManager/logs
[[ ! -L /tinyMediaManager/backup ]] && ln -s /config/backup /tinyMediaManager/backup
[[ ! -L /tinyMediaManager/launcher.log ]] && ln -s /config/launcher.log /tinyMediaManager/launcher.log
[[ ! -L /tinyMediaManager/config.xml ]] && ln -s /config/config.xml /tinyMediaManager/config.xml
[[ ! -L /tinyMediaManager/tmm.odb ]] && ln -s /config/tmm.odb /tinyMediaManager/tmm.odb

chown -R nobody:users /config /tinyMediaManager /nobody
EOT

# xrdp.ini
cat <<'EOT' > /etc/xrdp/xrdp.ini
[globals]
bitmap_cache=yes
bitmap_compression=yes
port=3389
crypt_level=low
channel_code=1
max_bpp=24
#black=000000
#grey=d6d3ce
#dark_grey=808080
#blue=08246b
#dark_blue=08246b
#white=ffffff
#red=ff0000
#green=00ff00
#background=626c72


[xrdp1]
name=tinyMediaManager
lib=libvnc.so
ip=127.0.0.1
port=5900
username=na
password=na
EOT


# Xvfb
mkdir -p /etc/service/Xvfb
cat <<'EOT' > /etc/service/Xvfb/run
#!/bin/bash
exec 2>&1
umask 000

exec /usr/bin/Xvfb :1 -screen 0 1280x960x16
EOT

# x11vnc
mkdir -p /etc/service/x11vnc
cat <<'EOT' > /etc/service/x11vnc/run
#!/bin/bash
exec 2>&1

exec x11vnc -display :1 -xkb
EOT

# noVNC
mkdir -p /etc/service/noVNC
cat <<'EOT' > /etc/service/noVNC/run
#!/bin/bash
exec 2>&1
cd /noVNC
exec /noVNC/utils/launch.sh
EOT

# xrdp
mkdir -p /etc/service/xrdp
cat <<'EOT' > /etc/service/xrdp/run
#!/bin/bash
exec 2>&1
RSAKEYS=/etc/xrdp/rsakeys.ini

    # Check for rsa key
    if [ ! -f $RSAKEYS ] || cmp $RSAKEYS /usr/share/doc/xrdp/rsakeys.ini > /dev/null; then
        log_action_begin_msg "Generating xrdp RSA keys..."
        (umask 077 ; xrdp-keygen xrdp $RSAKEYS)
        chown root:root $RSAKEYS
        if [ ! -f $RSAKEYS ] ; then
            log_action_end_msg 1 "could not create $RSAKEYS"
            exit 1
        fi
        log_action_end_msg 0 "done"
    fi

exec /usr/sbin/xrdp --nodaemon 
EOT

# xrdp-sesman
mkdir -p /etc/service/xrdp-sesman
cat <<'EOT' > /etc/service/xrdp-sesman/run
#!/bin/bash
exec 2>&1

exec /usr/sbin/xrdp-sesman --nodaemon >> /var/log/xrdp-sesman_run.log 2>&1
EOT

# openbox
mkdir -p /etc/service/openbox
cat <<'EOT' > /etc/service/openbox/run
#!/bin/bash
exec 2>&1

exec env DISPLAY=:1 HOME=/nobody /sbin/setuser nobody  /usr/bin/openbox-session
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# Install tinyMediaManager
mv /tmp/tmmConfig /tmmConfig
mv /tmp/tinyMediaManager /

# Install noVNC
mv /tmp/noVNC /noVNC

# Make 2.7 python default
ln -s /usr/bin/python2.7 /usr/bin/python
