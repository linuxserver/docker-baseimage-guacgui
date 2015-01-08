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
RUN apt-mark hold initscripts udev plymouth mountall;\
    echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90forceyes;\
    echo 'deb http://archive.ubuntu.com/ubuntu utopic main universe restricted' > /etc/apt/sources.list;\
    echo 'deb http://archive.ubuntu.com/ubuntu utopic-updates  main universe restricted' >> /etc/apt/sources.list;\
    apt-get update;\
    echo exit 101 > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d;\
    dpkg-divert --local --rename --add /sbin/initctl;\
    ln -sf /bin/true /sbin/initctl;\
    apt-get -y upgrade && apt-get clean

# Install vnc, xvfb in order to creat a 'fake' display novnc
RUN apt-get install -qy --force-yes x11vnc xvfb openjdk-7-jre wget openbox python-pip unzip python-tornado python-zmq python-psutil

# Install and Configure Circus
RUN pip --no-input install --upgrade pip
RUN pip --no-input install circus;\
    pip --no-input install circus-env-modifier 
RUN mkdir /etc/circus.d /etc/setup.d

# Setup vnc
RUN mkdir /nobody && cp -R ~/.[a-zA-Z0-9]* /nobody
RUN mkdir /nobody/.vnc
RUN rm -r /nobody/.cache; mkdir /nobody/.cache
# Setup a password
RUN x11vnc -storepasswd 1234 /nobody/.vnc/passwd

# Cleanup
RUN apt-get -y autoremove 

# Exposed config volume
VOLUME /config

# Add config files
ADD ./files/circus.ini /etc/circus.ini
ADD ./files/start.sh /start.sh
ADD ./files/circus.d/Xvfb.ini /etc/circus.d/Xvfb.ini
ADD ./files/circus.d/openbox.ini /etc/circus.d/openbox.ini
ADD ./files/circus.d/x11vnc.ini /etc/circus.d/x11vnc.ini
ADD ./files/circus.d/noVNC.ini /etc/circus.d/noVNC.ini
ADD ./files/start.sh /start.sh
ADD ./files/openbox/autostart /etc/xdg/openbox/autostart
ADD ./files/noVNC /noVNC
ADD ./files/tinyMediaManager /tinyMediaManager
ADD ./files/tmmConfig /tmmConfig
ADD ./files/setup.d/tinyMediaManager /etc/setup.d/tinyMediaManager

# change ownership for unRAID
RUN chown -R nobody:users /nobody /noVNC /tinyMediaManager
# Expose default noVNC port
EXPOSE 6080
# Make start script executable and default command
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
