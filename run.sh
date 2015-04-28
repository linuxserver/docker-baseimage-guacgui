#!/bin/bash
docker run -d -p 8088:8080 -p 3389:3389 -e "TZ=America/Edmonton" --name tinyMediaManager tmm

