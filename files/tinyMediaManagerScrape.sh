#!/bin/bash
sleep 120
kill $(ps -aux | grep tmm.jar | grep -v grep | awk '{print $2}')
su -c 'cd /tmm ; java -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8 -Djava.awt.headless=true -Xms64m -Xmx512m -Xss512k -Djna.nosys=true -jar tmm.jar -update -scrapeNew -renameNew' -m nobody
supervisorctl start tmm
