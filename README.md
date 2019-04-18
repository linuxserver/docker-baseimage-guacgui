[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)](https://linuxserver.io)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring :-

 * regular and timely application updates
 * easy user mappings (PGID, PUID)
 * custom base image with s6 overlay
 * weekly base OS updates with common layers across the entire LinuxServer.io ecosystem to minimise space usage, down time and bandwidth
 * regular security updates

Find us at:
* [Discord](https://discord.gg/YWrKVTn) - realtime support / chat with the community and the team.
* [IRC](https://irc.linuxserver.io) - on freenode at `#linuxserver.io`. Our primary support channel is Discord.
* [Blog](https://blog.linuxserver.io) - all the things you can do with our containers including How-To guides, opinions and much more!

# [linuxserver/docker-baseimage-guacgui](https://github.com/linuxserver/dockergui)
[![](https://img.shields.io/discord/354974912613449730.svg?logo=discord&label=LSIO%20Discord&style=flat-square)](https://discord.gg/YWrKVTn)
[![](https://images.microbadger.com/badges/version/linuxserver/docker-baseimage-guacgui.svg)](https://microbadger.com/images/linuxserver/docker-baseimage-guacgui "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/linuxserver/docker-baseimage-guacgui.svg)](https://microbadger.com/images/linuxserver/docker-baseimage-guacgui "Get your own version badge on microbadger.com")
![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/docker-baseimage-guacgui.svg)
![Docker Stars](https://img.shields.io/docker/stars/linuxserver/docker-baseimage-guacgui.svg)
[![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Pipeline-Builders/docker-docker-baseimage-guacgui/master)](https://ci.linuxserver.io/job/Docker-Pipeline-Builders/job/docker-docker-baseimage-guacgui/job/master/)
[![](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/docker-baseimage-guacgui/latest/badge.svg)](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/docker-baseimage-guacgui/latest/index.html)

## [Docker-baseimage-guacgui](https://github.com/dockergui/)
&nbsp;
This Docker image makes it possible to use any X application on a headless
server through a modern web browser such as chrome. Additionally the
container can be accessed using any rdp client. You can access the web
interface by going to port 8080 or rdp via port 3389.


[![docker-baseimage-guacgui]()](https://github.com/dockergui/)

## Supported Architectures

Our images support multiple architectures such as `x86-64`, `arm64` and `armhf`. We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list) and our announcement [here](https://blog.linuxserver.io/2019/02/21/the-lsio-pipeline-project/). 

Simply pulling `linuxserver/docker-baseimage-guacgui` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armhf | arm32v7-latest |


## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=docker-baseimage-guacgui \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e APPNAME=xclock \
  -e GUAC_USER=abc \
  -e GUAC_PASS=900150983cd24fb0d6963f7d28e17f72 \
  -p 8080:8080 \
  -p 3389:3389 \
  -v </path/to/appdata>:/config \
  --restart unless-stopped \
  linuxserver/docker-baseimage-guacgui
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  docker-baseimage-guacgui:
    image: linuxserver/docker-baseimage-guacgui
    container_name: docker-baseimage-guacgui
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - APPNAME=xclock
      - GUAC_USER=abc
      - GUAC_PASS=900150983cd24fb0d6963f7d28e17f72
    volumes:
      - </path/to/appdata>:/config
    ports:
      - 8080:8080
      - 3389:3389
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8080` | Allows HTTP access to the internal X server. |
| `-p 3389` | Allows RDP access to the internal X server. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London |
| `-e APPNAME=xclock` | Specify the graphical application name shown on RDP access. |
| `-e GUAC_USER=abc` | Specify the username for guacamole's web interface. |
| `-e GUAC_PASS=900150983cd24fb0d6963f7d28e17f72` | Specify the password's md5 hash for guacamole's web interface. |
| `-v /config` | Contains X user's home directory contents. |

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


&nbsp;
## Application Setup

This is baseimage meant to be used as base for graphical applications. Please
refer to the example folder for usage.
&nbsp;
Passwords can be generate via the following:
```
echo -n password | openssl md5
```
```
printf '%s' password | md5sum
```
Please beaware this image is not hardened for internet usage. Use
a reverse ssl proxy to increase security.



## Support Info

* Shell access whilst the container is running: `docker exec -it docker-baseimage-guacgui /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f docker-baseimage-guacgui`
* container version number 
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' docker-baseimage-guacgui`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/docker-baseimage-guacgui`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.  
  
Below are the instructions for updating containers:  
  
### Via Docker Run/Create
* Update the image: `docker pull linuxserver/docker-baseimage-guacgui`
* Stop the running container: `docker stop docker-baseimage-guacgui`
* Delete the container: `docker rm docker-baseimage-guacgui`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start docker-baseimage-guacgui`
* You can also remove the old dangling images: `docker image prune`

### Via Taisun auto-updater (especially useful if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one shot:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock taisun/updater \
  --oneshot docker-baseimage-guacgui
  ```
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull docker-baseimage-guacgui`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d docker-baseimage-guacgui`
* You can also remove the old dangling images: `docker image prune`

## Versions

* **17.04.19:** - Rebase docker-baseimage-gui and Ubuntu 18.04.
