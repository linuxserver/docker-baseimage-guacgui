#!/bin/bash

mkdir -p /config/circus
touch /config/circus/Xvfb.log
touch /config/circus/x11vnc.log
touch /config/circus/TinyMediaManager.log
touch /config/circus/openbox.log
touch /config/circus/noVNC.log

chmod 666 /config/circus/*
chmod +x /tinyMediaManager/tinyMediaManager.sh /tinyMediaManager/tinyMediaManagerCMD.sh 

run-parts -v  --report /etc/setup.d

echo "---> Starting circus..."
exec /usr/local/bin/circusd /etc/circus.ini
