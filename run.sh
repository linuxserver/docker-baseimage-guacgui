#!/bin/bash
docker run -d -p 3389:3389 -e "TZ=America/New_York" --name DockerGui dockergui

