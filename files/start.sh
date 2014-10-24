#!/bin/bash

mkdir -p /tmm/rlogs/supervisor
touch /tmm/rlogs/cron.log
touch /tmm/rlogs/xvfb.log
touch /tmm/rlogs/xvfb.err
touch /tmm/rlogs/x11vnc.log
touch /tmm/rlogs/x11vnc.err
touch /tmm/rlogs/tmm.log
touch /tmm/rlogs/tmm.err
touch /tmm/rlogs/openbox.log
touch /tmm/rlogs/openbox.err
touch /tmm/rlogs/novnc.log
touch /tmm/rlogs/novnc.err
chmod 666 /tmm/rlogs/*
chmod +x /tmm/tinyMediaManager.sh /tmm/tinyMediaManagerCMD.sh

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
