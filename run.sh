#!/bin/bash
docker run -d -p 9000:9000 -p 3389:3389 -p 6080:6080 -e "TZ=America/Edmonton" --name tinyMediaManager tmm

