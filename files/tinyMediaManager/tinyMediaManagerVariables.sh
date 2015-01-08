# have a look if we need to launch the updater or tmm directly
if [ -f /tinyMediaManager/tmm.jar ]; then
  export TMM_UPDATE_ARG="-Dsilent=noupdate"
fi
