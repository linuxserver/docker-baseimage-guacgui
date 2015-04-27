#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

### Version of guacamole to be installed
ENV GUAC_VER 0.9.3

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt utopic main universe restricted' > /etc/apt/sources.list
echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt utopic-updates main universe restricted' >> /etc/apt/sources.list


# Install Dependencies
apt-get update -qq
apt-get install -qy --force-yes --no-install-recommends libossp-uuid-dev \
							libpng12-dev \
							libfreerdp-dev \
							libvorbis-dev \
							libssl-dev \
							libcairo2-dev \
							tomcat7


#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

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
rm -RF /var/lib/tomcat7/webapps/ROOT
ln -s /var/lib/tomcat7/webapps/guacamole.war /var/lib/tomcat7/webapps/ROOT.war 

### Compensate for GUAC-513
ln -s /usr/local/lib/freerdp/guacsnd.so /usr/lib/x86_64-linux-gnu/freerdp/ 
ln -s /usr/local/lib/freerdp/guacdr.so /usr/lib/x86_64-linux-gnu/freerdp/

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get autoremove -y 
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
