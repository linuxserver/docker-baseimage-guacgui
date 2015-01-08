#docker TinyMediaManager

## Description:
tinyMediaManager (http://www.tinymediamanager.org) is a media management tool written in Java/Swing.  
It is written to provide metadata for the XBOX Media Center (XBMC).  
Due to the fact that it is written in Java, tinyMediaManager will run on Windows, Linux and Mac OSX (and possible more OS).  
  
 
This Docker image makes it possible to use  "tinyMediaManager" - (http://www.tinymediamanager.org/), through a modern web browser such as chrome.

## Build from docker file:

```
git clone --depth=1 https://github.com/hurricanehernandez/tmm.git 
cd tmm
docker build --rm=true -t tmm . 
```

## Volumes:

#### `/media`

Location of media, that you want managed by media manager.

#### `/config`

Config directory of tinyMediaManager.


## Docker run command:

```
docker run -d -p 6080:6080 -v /*tmm_install_dir_on_host:/tmm -v /*your_media_location*:/media -v /etc/localtime:/etc/localtime:ro --name=tmm hurricane/tmm

```
