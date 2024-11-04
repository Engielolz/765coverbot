#!/bin/bash
echo '765 Pro Cover Bot'
echo 'Using atproto the dirty way! (bash and cURL)'

function loadFail () {
   echo "Cannot load required dependency script"
   exit 127
}

function installService () {
   if ! [[ -d /run/systemd/system ]]; then echo "No systemd detected. Please manage the service manually with your init system."; exit 1; fi
   if ! [ "$1" = "un" ]; then
      echo "Installing service"
      ln -sf $(realpath ./765coverbot.service) /etc/systemd/system/
      systemctl enable 765coverbot
      echo "The script will activate when you restart the system."
      echo "Or you can start it now with: systemctl start 765coverbot"
   else
      echo "Removing service"
      systemctl disable 765coverbot
      #systemd deletes the symlink for us
   fi
   exit 0
}

source bash-atproto.sh
if ! [ "$?" = "0" ]; then loadFail; fi
source covergen.sh
if ! [ "$?" = "0" ]; then loadFail; fi

if [ "$1" = "--install" ]; then installService; fi
if [ "$1" = "--uninstall" ]; then installService un; fi

refreshInterval=1800 # refresh every half hour
# 3600 to post every hour
postInterval=14400 # post every 4 hours

function napTime () {
   sleeptime=$(($1 - $(date +%s) % $1))
   echo "Sleeping until $(date -d @$(($(date +%s) + $sleeptime)))"
   sleep $sleeptime
}

function postingLogic () {
   generateCover
   echo "Posting $generatedCover"
   postToBluesky "$generatedCover"
   error=$?
   if [ "$error" = "2" ]; then
      refreshKeys
      postToBluesky "$generatedCover"
   elif ! [ "$error" = "0" ]; then
      echo "Error when posting the cover."
      echo "Error code: $error"
   fi
   generatedCover=
}

loadSecrets ./secrets.sh
didInit $1
if ! [ "$?" = "0" ]; then echo "DID init failure. Please check your DID."; exit 1; fi

# Do we have keys?
if [ -z "$savedRefresh" ]; then 
   echo 'Keys not found; obtaining'
   if [ -z "$2" ]; then echo 'You need to pass an app password for auth. You should only need to do this once.'; exit 1; fi
   getKeys $did $2
   if [ $? -ne 0 ]; then echo "Couldn't log in. Verify your credentials are correct."; exit 1; fi
   saveSecrets ./secrets.env
fi

if [ -z "$savedAccessTimestamp" ]; then savedAccessTimestamp=0; fi

echo 'Prep complete. Starting loop'

if [ "$1" = "--post-on-start" ] || [ "$1" = "--posttest" ]; then postingLogic; fi

while :
do
   napTime $postInterval
   if [ "$(date +%s)" -gt "$(( $savedAccessTimestamp + $refreshInterval ))" ]; then
      refreshKeys
      if ! [ "$?" = "0" ]; then
         echo "Refresh failure. Not continuing."
         exit 1
      fi
      saveSecrets ./secrets.env
   fi
   postingLogic
done
