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
echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main universe restricted' > /etc/apt/sources.list
echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main universe restricted' >> /etc/apt/sources.list
add-apt-repository ppa:no1wantdthisname/openjdk-fontfix

# Install Dependencies
apt-get update -qq
# Install general
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
                                                        openbox
# x11rdp install
dpkg -i /tmp/x11rdp/x11rdp_0.9.0+devel-1_amd64.deb

# xrdp needs to be installed seperately
dpkg -i /tmp/x11rdp/xrdp_0.9.0+devel-1_amd64.deb

# Install Guac
apt-get install -qy --force-yes --no-install-recommends openjdk-7-jre \
							libossp-uuid-dev \
                                                        libpng12-dev \
                                                        libfreerdp-dev \
                                                        libcairo2-dev \
                                                        tomcat7


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
sed -i -e "s#GUI_APPLICATION#$APPNAME#" /etc/guacamole/noauth-config.xml

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
    if [ ! -f $RSAKEYS ] || cmp $RSAKEYS /usr/share/doc/xrdp/rsakeys.ini > /dev/null; then
        echo "Generating xrdp RSA keys..."
        (umask 077 ; xrdp-keygen xrdp $RSAKEYS)
        chown root:root $RSAKEYS
        if [ ! -f $RSAKEYS ] ; then
            echo "could not create $RSAKEYS"
            exit 1
        fi
        echo "done"
    fi

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

mkdir -p /etc/service/tomcat7
cat <<'EOT' > /etc/service/tomcat7/run
#!/bin/bash
exec 2>&1

touch /var/lib/tomcat7/logs/catalina.out

cd /var/lib/tomcat7

exec /usr/lib/jvm/java-7-openjdk-amd64/bin/java -Djava.util.logging.config.file=/var/lib/tomcat7/conf/logging.properties \
                                           -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
                                           -Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC \
                                           -Djava.endorsed.dirs=/usr/share/tomcat7/endorsed \
                                           -classpath /usr/share/tomcat7/bin/bootstrap.jar:/usr/share/tomcat7/bin/tomcat-juli.jar \
                                           -Dcatalina.base=/var/lib/tomcat7 -Dcatalina.home=/usr/share/tomcat7 \
                                           -Djava.io.tmpdir=/tmp/tomcat7-tomcat7-tmp org.apache.catalina.startup.Bootstrap start
EOT

mkdir -p /etc/service/guacd
cat <<'EOT' > /etc/service/guacd/run
#!/bin/bash
exec 2>&1

exec /usr/local/sbin/guacd -f
EOT

mkdir -p /etc/guacamole
cat <<'EOT' > /etc/guacamole/guacamole.properties
# Location to read extra .jar's from (don't change for this docker config)
lib-directory:  /var/lib/guacamole/classpath

# Hostname and port of guacamole proxy (don't change for this docker config)
guacd-hostname: localhost
guacd-port:     4822

# Auth provider class
auth-provider: net.sourceforge.guacamole.net.auth.noauth.NoAuthenticationProvider

# NoAuth properties
noauth-config: /etc/guacamole/noauth-config.xml
EOT


cat <<'EOT' > /etc/guacamole/noauth-config.xml
<configs>
    <config name="GUI_APPLICATION" protocol="rdp">
        <param name="hostname" value="127.0.0.1" />
        <param name="port" value="3389" />
        <param name="color-depth" value="16" />
    </config>
</configs>
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

# Make needed directories
mkdir -p /var/cache/tomcat7
mkdir -p /var/lib/guacamole/classpath
mkdir -p /usr/share/tomcat7/.guacamole
mkdir -p /usr/share/tomcat7-root/.guacamole
mkdir -p /root/.guacamole

# Install guacd
dpkg -i /tmp/guacamole/guacamole-server_0.9.6_amd64.deb
ldconfig

# Configure tomcat
cp /tmp/guacamole/guacamole-0.9.6.war /var/lib/tomcat7/webapps/guacamole.war
cp /tmp/guacamole/guacamole-auth-noauth-0.9.6.jar /var/lib/guacamole/classpath
ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat7/.guacamole/
ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat7-root/.guacamole/
ln -s /etc/guacamole/guacamole.properties /root/.guacamole/

# Fix tomcat webroot
rm -Rf /var/lib/tomcat7/webapps/ROOT
ln -s /var/lib/tomcat7/webapps/guacamole.war /var/lib/tomcat7/webapps/ROOT.war 

### Compensate for GUAC-513
ln -s /usr/local/lib/freerdp/guacsnd.so /usr/lib/x86_64-linux-gnu/freerdp/ 
ln -s /usr/local/lib/freerdp/guacdr.so /usr/lib/x86_64-linux-gnu/freerdp/

# openbox confg
cp /tmp/openbox/rc.xml /nobody/.config/openbox/rc.xml
chown nobody:users /nobody/.config/openbox/rc.xml

# pulseauido rdp
cp /tmp/x11rdp/module-xrdp* /usr/lib/pulse-4.0/modules
chown -R 777 /usr/lib/pulse-4.0/modules

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get autoremove -y 
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/guacamole /tmp/openbox /tmp/x11rdp
