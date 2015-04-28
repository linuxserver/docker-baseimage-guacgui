#Docker tinyMediaManager

## Description:
tinyMediaManager (http://www.tinymediamanager.org) is a media management tool written in Java/Swing.  
It is written to provide metadata for the XBOX Media Center (XBMC).  
Due to the fact that it is written in Java, tinyMediaManager will run on Windows, Linux and Mac OSX (and possible more OS).  
  
 
This Docker image makes it possible to use  "tinyMediaManager" on a headless server through a modern web browser such as chrome.
Additionally xrdp is installed and the container can be accessed using any rdp client. You can access the web interface by going to port 8080.
  
![Alt text](http://i.imgur.com/SnolAAr.jpg "")
  
## How to use this image:
  
### start a tinyMediaManager instance:
  
```
docker run -d -p 8080:8080 -p 3389:3389 -v /*tmm_config_location*:/config -v /*your_media_location*:/mnt -e TZ=America/Edmonton --name=tmm hurricane/tinyMediaManager
```

## Volumes:

#### `/mnt`
Location of media, that you want managed by media manager.

#### `/config`
Config directory of tinyMediaManager.
  
## Environment Variables
  
The tinyMediaManager image uses one optional enviromnet variable.

####`TZ`
This environment variable is used to set the [TimeZone] of the container.

[TimeZone]: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
   
## Build from docker file (Info only, not required.):

```
git clone --depth=1 https://github.com/hurricanehernandez/tmm.git 
cd tmm
docker build --rm=true -t tmm . 
```
