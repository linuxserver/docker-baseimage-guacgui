#!/bin/bash
docker run -d -p 8080:8080 -p 3389:3389 -e "TZ=America/Edmonton" --privileged --name DockerGui dockergui

