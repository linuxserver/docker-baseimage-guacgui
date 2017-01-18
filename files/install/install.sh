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

echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt xenial main universe restricted' > /etc/apt/sources.list
echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates main universe restricted' >> /etc/apt/sources.list


# Install Dependencies
apt-get update -qq
# Install general

apt-get install -qy --force-yes --no-install-recommends apt-utils \
                                                        wget \
							unzip \
							dialog \
							gconf-service \
							gconf-service-backend \
							gconf2-common \
							libappindicator1 \
							libasound2 \
							libasound2-data \
							libatk1.0-0 \
							libatk1.0-data \
							libavahi-client3 \
							libavahi-common-data \
							libavahi-common3 \
							libcups2 libcurl3 \
							libdbusmenu-glib4 \
							libdbusmenu-gtk4 \
							libgconf-2-4 \
							libgtk2.0-0 \
							libgtk2.0-common \
							libindicator7 \
							libnspr4 \
							libnss3 \
							libnss3-nssdb \
							libpango1.0-0 \
							libpangox-1.0-0 \
							libxss1 \
							shared-mime-info \
							xdg-utils \
							libvte-common \
							libvte9 \
							lxterminal \
							nano

# Install window manager and x-server
apt-get install -qy --force-yes --no-install-recommends vnc4server \
                                                        x11-xserver-utils \
							openbox \
							xfonts-base \
							xfonts-100dpi \
							xfonts-75dpi \
							libfuse2

# Install xrdp
apt-get install -qy --force-yes --no-install-recommends xrdp


=======
apt-get install -qy --force-yes --no-install-recommends wget \
                            				unzip

# Install window manager and x-server
apt-get install -qy --force-yes --no-install-recommends x11-xserver-utils \
                                                        libxrandr2 \
                                                        libfuse2 \
                                                        xutils \
                                                        libxfixes3 \
                                                        libx11-dev \
                                                        libxml2 \
                                                        zlib1g \
                                                        fuse \
                                                        autocutsel \
                                                        pulseaudio \
							x11-apps \
                                                        openbox
# x11rdp install
dpkg -i /tmp/x11rdp/x11rdp_0.9.0+devel-1_amd64.deb

# xrdp needs to be installed seperately
dpkg -i /tmp/x11rdp/xrdp_0.9.0+devel_amd64.deb



#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# User directory
mkdir /nobody
mkdir -p /nobody/.config/openbox
mkdir /nobody/.cache

# config
cat <<'EOT' > /etc/my_init.d/00_config.sh
#!/bin/bash
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi
EOT

# user config
cat <<'EOT' > /etc/my_init.d/01_user_config.sh
#!/bin/bash

USERID=${USER_ID:-99}
GROUPID=${GROUP_ID:-100}
groupmod -g $GROUPID users
usermod -u $USERID nobody
usermod -g $GROUPID nobody
usermod -d /nobody nobody
usermod -a -G adm,sudo,fuse nobody
chown -R nobody:users /nobody/ 
EOT

# app config
cat <<'EOT' > /etc/my_init.d/02_app_config.sh
#!/bin/bash

APPNAME=${APP_NAME:-"GUI_APPLICATION"}

sed -i -e "s#GUI_APPLICATION#$APPNAME#" /etc/xrdp/xrdp.ini

if [[ -e /startapp.sh ]]; then 
    chown nobody:users /startapp.sh
    chmod +x /startapp.sh
fi
EOT

# X11rdp
mkdir -p /etc/service/X11rdp
cat <<'EOT' > /etc/service/X11rdp/run
#!/bin/bash
exec 2>&1
WD=${WIDTH:-1280}
HT=${HEIGHT:-720}


exec /sbin/setuser nobody X11rdp :1 -bs -ac -nolisten tcp -geometry ${WD}x${HT} -depth 16 -uds

EOT

# xrdp
mkdir -p /etc/service/xrdp
cat <<'EOT' > /etc/service/xrdp/run
#!/bin/bash
exec 2>&1
RSAKEYS=/etc/xrdp/rsakeys.ini

    # Check for rsa key
    [ -f /usr/share/doc/xrdp/rsakeys.ini ] && rm /usr/share/doc/xrdp/rsakeys.ini
    ln -s $RSAKEYS /usr/share/doc/xrdp/rsakeys.ini
    if [ ! -f $RSAKEYS ]; then
        echo "Generating xrdp RSA keys..."
        (umask 077 ; xrdp-keygen xrdp $RSAKEYS)
        chown root:root $RSAKEYS
        if [ ! -f $RSAKEYS ] ; then
	        echo "could not create $RSAKEYS"
            exit 1
        fi
    fi
    [ -f /var/run/xrdp/xrdp.pid ] && rm /var/run/xrdp/xrdp.pid
    echo "Starting xrdp!"

exec /usr/sbin/xrdp --nodaemon
EOT


# xrdp.ini
cat <<'EOT' > /etc/xrdp/xrdp.ini
[globals]
bitmap_cache=yes
bitmap_compression=yes
port=3389
allow_channels=true
max_bpp=16
fork=yes
crypt_level=low
security_layer=rdp
tcp_nodelay=yes
tcp_keepalive=yes
blue=009cb5
grey=dedede
autorun=xrdp1
bulk_compression=yes
new_cursors=yes
use_fastpath=both
hidelogwindow=yes

[Logging]
LogFile=xrdp-ng.log
LogLevel=DEBUG
EnableSyslog=1
SyslogLevel=DEBUG

[channels]
rdpdr=true
rdpsnd=true
drdynvc=true
cliprdr=true
rail=true

[xrdp1]
name=GUI_APPLICATION
lib=libxup.so
username=na
password=na
ip=127.0.0.1

port=/tmp/.xrdp/xrdp_display_1
chansrvport=/tmp/.xrdp/xrdp_chansrv_socket_1
xserverbpp=16
code=10

EOT

# xrdp-chansrv
mkdir -p /etc/service/xrdp-chansrv
cat <<'EOT' > /etc/service/xrdp-chansrv/run
#!/bin/bash

exec env DISPLAY=:1 HOME=/nobody /sbin/setuser nobody xrdp-chansrv
EOT

# autocutsel
mkdir -p /etc/service/autocutsel
cat <<'EOT' > /etc/service/autocutsel/run
#!/bin/bash

exec env DISPLAY=:1 HOME=/nobody /sbin/setuser nobody autocutsel
EOT

# autocutsel2
mkdir -p /etc/service/autocutsel2
cat <<'EOT' > /etc/service/autocutsel2/run
#!/bin/bash

exec env DISPLAY=:1 HOME=/nobody /sbin/setuser nobody autocutsel -selection PRIMARY
EOT

# xclipboard
mkdir -p /etc/service/xclipboard
cat <<'EOT' > /etc/service/xclipboard/run
#!/bin/bash
sv -w7 check openbox

exec env DISPLAY=:1 HOME=/nobody /sbin/setuser nobody xclipboard
EOT

# asound.conf
cat <<'EOT' > /etc/asound.conf
pcm.pulse {
    type pulse
}

ctl.pulse {
    type pulse
}

pcm.!default {
    type pulse
}

ctl.!default {
    type pulse
}
EOT

# pulseaudio
mkdir -p /etc/service/pulseaudio
cat <<'EOT' > /etc/service/pulseaudio/run
#!/bin/bash

exec env DISPLAY=:1 HOME=/nobody /sbin/setuser nobody pulseaudio -F /etc/xrdp/pulse/default.pa -n
EOT

# openbox
mkdir -p /etc/service/openbox
cat <<'EOT' > /etc/service/openbox/run
#!/bin/bash
exec 2>&1

exec env DISPLAY=:1 HOME=/nobody /sbin/setuser nobody  /usr/bin/openbox-session
EOT


# Openbox User nobody autostart
cat <<'EOT' > /nobody/.config/openbox/autostart
# Programs that will run after Openbox has started

xsetroot -solid black -cursor_name left_ptr
if [ -e /startapp.sh ]; then 
    echo "Starting X app..."
    exec /startapp.sh
fi
EOT

chmod -R +x /etc/service/ /etc/my_init.d/ 

#########################################
##             INSTALLATION            ##
#########################################


# openbox confg
cp /tmp/openbox/rc.xml /nobody/.config/openbox/rc.xml
chown nobody:users /nobody/.config/openbox/rc.xml


# Install slimjet
cd /tmp
wget 'http://www.slimjet.com/download.php?version=lnx64&type=deb&beta=1&server=' -O slimjet.deb
dpkg -i slimjet.deb


# pulseauido rdp
cp /tmp/x11rdp/module-xrdp* /usr/lib/pulse-4.0/modules
chown -R 777 /usr/lib/pulse-4.0/modules


#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
apt-get autoclean -y
apt-get autoremove -y
rm -rf /usr/share/locale/*
rm -rf /var/cache/debconf/*-old
rm -rf /var/lib/apt/lists/*
rm -rf /usr/share/doc/*
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/openbox

