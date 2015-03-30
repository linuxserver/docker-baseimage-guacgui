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
RUN usermod -a -G adm,sudo nobody
RUN echo "nobody:PASSWD" | chpasswd

# Update ubuntu
RUN apt-mark hold initscripts udev plymouth mountall;\
    echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90forceyes;\
    echo 'deb http://us.archive.ubuntu.com/ubuntu utopic main universe restricted' > /etc/apt/sources.list;\
    echo 'deb http://us.archive.ubuntu.com/ubuntu utopic-updates  main universe restricted' >> /etc/apt/sources.list;\
    apt-get update;\
    echo exit 101 > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d;\
    dpkg-divert --local --rename --add /sbin/initctl;\
    ln -sf /bin/true /sbin/initctl;\
    apt-get -y upgrade && apt-get clean

# Install vnc, xvfb in order to creat a 'fake' display novnc
RUN apt-get install -qy --force-yes --no-install-recommends x11vnc xvfb openjdk-7-jre \
							   wget openbox python-pip unzip \
							   git python-tornado python-zmq \
							   python-psutil sudo nano net-tools\
							   ttf-ubuntu-font-family
 
# Download FreeRDP-WebConnect Source
RUN git clone https://github.com/HurricaneHernandez/FreeRDP-WebConnect.git

# Install xrdp, has to be installed alone.
RUN apt-get install -y xrdp

# Install and Configure Circus
RUN pip --no-input install --upgrade pip
RUN pip --no-input install circus;\
    pip --no-input install circus-env-modifier 
RUN mkdir /etc/circus.d /etc/setup.d

# Setup vnc
RUN mkdir /nobody && cp -R ~/.[a-zA-Z0-9]* /nobody
RUN mkdir /nobody/.vnc
RUN mkdir -p /nobody/.config/openbox
RUN rm -r /nobody/.cache; mkdir /nobody/.cache

# Cleanup
RUN apt-get autoclean
RUN apt-get -y autoremove 

# Exposed config volume
VOLUME /config

# Add config files
ADD ./files/circus.ini /etc/circus.ini
ADD ./files/start.sh /start.sh
ADD ./files/circus.d/Xvfb.ini /etc/circus.d/Xvfb.ini
ADD ./files/circus.d/openbox.ini /etc/circus.d/openbox.ini
ADD ./files/circus.d/x11vnc.ini /etc/circus.d/x11vnc.ini
ADD ./files/circus.d/xrdp.ini /etc/circus.d/xrdp.ini
ADD ./files/start.sh /start.sh
ADD ./files/wsgate.ini /wsgate.ini
ADD ./files/scripts /scripts
ADD ./files/tinyMediaManager /tinyMediaManager
ADD ./files/tmmConfig /tmmConfig
ADD ./files/setup.d/tinyMediaManager /etc/setup.d/tinyMediaManager
ADD ./files/setup.d/FreeRDP-WebConnect /etc/setup.d/FreeRDP-WebConnect
ADD ./files/openbox/autostart /nobody/.config/openbox/autostart 

# change ownership for unRAID
RUN chown -R nobody:users /nobody /tinyMediaManager /scripts
# Expose default noVNC port
EXPOSE 3389
EXPOSE 5900
EXPOSE 9000

# Make start script executable and default command
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
