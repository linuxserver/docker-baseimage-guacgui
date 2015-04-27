# tinyMediaManager 
FROM phusion/baseimage:0.9.16
MAINTAINER Carlos Hernandez <carlos@techbyte.ca>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"


# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################
COPY ./files/ /tmp/
RUN chmod +x /tmp/install/guac_install.sh && /tmp/install/guac_install.sh
RUN chmod +x /tmp/install/tmm_install.sh && /tmp/install/tmm_install.sh

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME ["/config"]
EXPOSE 3389
