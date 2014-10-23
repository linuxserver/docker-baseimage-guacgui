#docker TinnyMediaManager

## Description:

This is a Dockerfile for "TinnyMediaManager" - (http://www.tinymediamanager.org/)

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

## Docker run command:

```
docker run -d -p 5900:5900 -v /*tmm_install_dir_on_host:/tmm -v /*your_media_location*:/media -v /etc/localtime:/etc/localtime:ro --name=tmm hurricane/tmm

```
