#!/bin/bash
#####################################################################################
# Launch tmm without the updater (or the updater if tmm.jar is missing)
#####################################################################################

# have a look if we need to launch the updater or tmm directly
if [ -f tmm.jar ]; then
  ARGS="-Dsilent=noupdate"
fi

ARGS="$ARGS -Djava.net.preferIPv4Stack=true"

# execute it :)
java $ARGS -jar getdown.jar .   