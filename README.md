#docker TinyMediaManager

## Description:

This is a Dockerfile for "TinyMediaManager" - (http://www.tinymediamanager.org/).
A VNC server running TinyMediaManager that can be access through a modern browser such as chrome. 
Image also runs TinyMediaManager to update and scrape any new movies at midnight.

## Build from docker file:

```
git clone --depth=1 https://github.com/hurricanehernandez/tmm.git 
cd tmm
docker build --rm=true -t tmm . 
```

## Volumes:

#### `/media`

Location of media, that you want managed by media manager.

#### `/tmm`

Install directory of TinyMediaManager.

## Instructions:

* Download latest TinyMediaManager from [here](http://code.fosshub.com/tinyMediaManager/downloads).
* Extract to a location such as /tmm on the host and ensure the directory and all files are by uid 99 and gid 100 (nobdy and users on unRAID).
* Run the docker command.
* Access TinyMediaManager from a browser such as chrome by vising. http://host:6080/vnc.html
* If mouse is an issue than disable local mouse config on webpage before connecting. There is no password.

## Docker run command:

```
docker run -d -p 6080:6080 -v /*tmm_install_dir_on_host:/tmm -v /*your_media_location*:/media -v /etc/localtime:/etc/localtime:ro --name=tmm hurricane/tmm

```
