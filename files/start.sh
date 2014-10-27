#!/bin/bash

mkdir -p /tmm/rlogs/supervisor
touch /tmm/rlogs/crontab.log
touch /tmm/rlogs/supervisor/xvfb.log
touch /tmm/rlogs/supervisor/xvfb.err
touch /tmm/rlogs/supervisor/x11vnc.log
touch /tmm/rlogs/supervisor/x11vnc.err
touch /tmm/rlogs/supervisor/tmm.log
touch /tmm/rlogs/supervisor/tmm.err
touch /tmm/rlogs/supervisor/openbox.log
touch /tmm/rlogs/supervisor/openbox.err
touch /tmm/rlogs/supervisor/novnc.log
touch /tmm/rlogs/supervisor/novnc.err
cp /tinyMediaManagerScrape.sh /tmm/tinyMediaManagerScrape.sh

chmod 666 /tmm/rlogs/*
chmod +x /tmm/tinyMediaManager.sh /tmm/tinyMediaManagerCMD.sh /tmm/tinyMediaManagerScrape.sh

if [ -e /tmm/crontab ]; then
    cp /tmm/crontab /etc/crontab
    chown root:root /etc/crontab
fi

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
