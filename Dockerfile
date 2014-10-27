#TinyMediaManager 
FROM ubuntu:utopic
MAINTAINER Carlos Hernandez <carlos@techbyte.ca>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Set locale to UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales

# Set user nobody to uid and gid of unRAID, uncomment for unRAID
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody
RUN usermod -m -d /nobody nobody
RUN usermod -s /bin/bash nobody

# Update ubuntu
RUN apt-mark hold initscripts udev plymouth mountall
RUN apt-get -q update
RUN apt-get dist-upgrade -qy && apt-get -q update

# Install vnc, xvfb in order to creat a 'fake' display novnc
RUN apt-get install -qy --force-yes x11vnc xvfb openjdk-7-jre cron postfix supervisor rsyslog wget openbox
RUN wget http://github.com/kanaka/noVNC/tarball/master -O noVNC.tar && mkdir /noVNC && tar -xf noVNC.tar --strip-components 1 -C /noVNC

# Setup vnc
RUN mkdir /nobody && cp -R ~/.[a-zA-Z0-9]* /nobody
RUN mkdir /nobody/.vnc
# Setup a password
RUN x11vnc -storepasswd 1234 /nobody/.vnc/passwd

# Cleanup
RUN apt-get -y autoremove 

# Add config files
ADD ./files/supervisord.conf /etc/supervisor/conf.d/common.conf
ADD ./files/cron-supervisor.conf /etc/supervisor/conf.d/cron.conf
ADD ./files/rsyslog-supervisor.conf /etc/supervisor/conf.d/rsyslog.conf
ADD ./files/xvfb-supervisor.conf /etc/supervisor/conf.d/xvfb.conf
ADD ./files/openbox-supervisor.conf /etc/supervisor/conf.d/openbox.conf
ADD ./files/x11vnc-supervisor.conf /etc/supervisor/conf.d/x11vnc.conf
ADD ./files/noVNC-supervisor.conf /etc/supervisor/conf.d/noVNC.conf
ADD ./files/tmm-supervisor.conf /etc/supervisor/conf.d/tmm.conf
ADD ./files/crontab /etc/crontab
ADD ./files/cron-rsyslog.conf /etc/rsyslog.d/60-cron.conf
ADD ./files/start.sh /start.sh
ADD ./files/tinyMediaManagerScrape.sh /tinnyMediaManagerScrape.sh
RUN sed -i '/session    required     pam_loginuid.so/c\#session    required     pam_loginuid.so' /etc/pam.d/cron
RUN sed -i -e 's/^\$ModLoad imklog/#\$ModLoad imklog/g' /etc/rsyslog.conf
RUN chown root:root /etc/supervisor/conf.d/* /etc/crontab /etc/rsyslog.d/60-cron.conf
# change ownership for unRAID
RUN chown -R nobody:users /nobody /noVNC
# Expose default noVNC port
EXPOSE 6080
# Make start script executable and default command
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
