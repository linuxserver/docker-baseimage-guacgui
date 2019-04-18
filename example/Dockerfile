FROM lsiobase/guacgui

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="HurricaneHrndz"
ENV APPNAME="xclock"

RUN \
 echo "**** install deps ****" && \
 apt-get update && \
 apt-get install -qy --no-install-recommends \
	x11-apps && \
 echo "**** clean up ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3389
VOLUME /config

