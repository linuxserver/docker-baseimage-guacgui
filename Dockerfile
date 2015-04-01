#TinyMediaManager 
FROM phusion/baseimage:0.9.16
MAINTAINER Carlos Hernandez <carlos@techbyte.ca>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8


# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################
COPY ./files/ ./files/wsgate.ini /tmp/
RUN chmod +x /tmp/install/tmm_install.sh && /tmp/install/tmm_install.sh
RUN chmod +x /tmp/install/wsgate_install.sh && /tmp/install/wsgate_install.sh

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME ["/config"]
EXPOSE 9000 3389
