#!/bin/bash

mkdir -p /tmm/rlogs/supervisor
touch /tmm/rlogs/cron.log
chmod 666 /tmm/rlogs/cron.log
chmod +x /tmm/tinyMediaManager.sh /tmm/tinyMediaManagerCMD.sh

supervisord -n
