#!/bin/bash
PARAMS=
 
if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  PARAMS=-Djna.nosys=true
fi

circusctl stop tinyMediaManager

# change to the tmm directory
cd /tinyMediaManager 
java -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8 -Djava.awt.headless=true -Xms64m -Xmx512m -Xss512k $PARAMS -jar tmm.jar $1 $2 $3 $4 $5


circusctl start tinyMediaManager
