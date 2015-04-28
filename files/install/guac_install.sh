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
apt-get install -qy --force-yes --no-install-recommends openjdk-7-jre \
							vnc4server \
							libxfont1 \
                                                        wget \
                                                        openbox \
                                                        unzip \
							libossp-uuid-dev \
							libpng12-dev \
							libfreerdp-dev \
							libvorbis-dev \
							libssl-dev \
							libcairo2-dev \
							tomcat7

# xrdp needs to be installed seperately
dpkg -i /tmp/x11rdp/xrdp_0.9.0+master-1_amd64.deb

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

# Xvnc
#mkdir -p /etc/service/Xvnc
cat <<'EOT' > /etc/service/Xvnc/run
#!/bin/bash
exec 2>&1

exec /sbin/setuser nobody vncserver :0 -geometry 1280x720 -nolisten tcp -localhost -depth 16 -dpi 96
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
#cat <<'EOT' > /etc/xrdp/xrdp.ini
#[globals]
#bitmap_cache=yes
#bitmap_compression=yes
#port=3389
#max_bpp=16
#fork=yes
#crypt_level=low
#security_layer=rdp
#tcp_nodelay=yes
#tcp_keepalive=yes
#blue=009cb5
#grey=dedede
#autorun=xrdp1
#bulk_compression=yes
#new_cursors=yes
#use_fastpath=both

#[Logging]
#LogFile=xrdp.log
#LogLevel=DEBUG
#EnableSyslog=1
#SyslogLevel=DEBUG

#[xrdp1]
#name=tinyMediaManaer
#lib=libvnc.so
#username=na
#password=na
#ip=127.0.0.1
#port=5900
#xserverbpp=16
#code=10
#EOT

# xrdp-sesman
mkdir -p /etc/service/xrdp-sesman
cat <<'EOT' > /etc/service/xrdp-sesman/run
#!/bin/bash
exec 2>&1

exec /usr/sbin/xrdp-sesman --nodaemon >> /var/log/xrdp-sesman_run.log 2>&1
EOT

# sesman.ini
#cat <<'EOT' /etc/xrdp/sesman.ini
#[Globals]
#ListenAddress=127.0.0.1
#ListenPort=3350
#EnableUserWindowManager=1
#UserWindowManager=startwm.sh
#DefaultWindowManager=startwm.sh

#[Security]
#AllowRootLogin=1
#MaxLoginRetry=4
#TerminalServerUsers=tsusers
#TerminalServerAdmins=tsadmins
# When AlwaysGroupCheck = false access will be permitted
# if the group TerminalServerUsers is not defined.
#AlwaysGroupCheck = false

#[Sessions]
#MaxSessions=2
#KillDisconnected=0
#IdleTimeLimit=0
#DisconnectedTimeLimit=0
#Policy=Default

#[Logging]
#LogFile=xrdp-sesman.log
#LogLevel=DEBUG
#EnableSyslog=1
#SyslogLevel=DEBUG

#[Xvnc]
#param1=-bs
#param2=-ac
#param3=-nolisten
#param4=tcp
#param5=-localhost
#param6=-dpi
#param7=96
#EOT

# openbox
#mkdir -p /etc/service/openbox
cat <<'EOT' > /etc/service/openbox/run
#!/bin/bash
exec 2>&1
exec env DISPLAY=:0 HOME=/nobody /sbin/setuser nobody  /usr/bin/openbox-session
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
    <config name="tinyMediaManager" protocol="rdp">
        <param name="hostname" value="127.0.0.1" />
        <param name="port" value="3389" />
    </config>
</configs>
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

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get autoremove -y 
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/guacamole /tmp/openbox
