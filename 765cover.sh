#!/bin/bash
echo '765 Cover Bot'
echo 'Using atproto the dirty way! (bash and cURL)'

function loadFail () {
   echo "Cannot load required dependency script"
   exit 127
}

function installService () {
   if ! [[ -d /run/systemd/system ]]; then echo "No systemd detected. Please manage the service manually with your init system."; exit 1; fi
   if ! [ "$1" = "un" ]; then
      echo "Installing service"
      cp ./765coverbot.service /etc/systemd/system/
      systemctl enable 765coverbot
   else
      echo "Removing service"
      systemctl disable 765coverbot
      rm /etc/systemd/system/765coverbot.service
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

function saveRefreshTime () {
   echo 'savedRefreshTime='$(( $(date +%s) + $refreshInterval )) >> ./secrets.env
}

function napTime () {
   sleeptime=$(($1 - $(date +%s) % $1))
   echo "Sleeping until $(date -d @$(($(date +%s) + $sleeptime)))"
   sleep $sleeptime
}

function postingLogic () {
   generateCover
   echo "Posting $generatedCover"
   postToBluesky "$generatedCover"
   if [ "$?" = "2" ]; then
      refreshKeys
      saveRefreshTime
      postToBluesky "$generatedCover"
   fi
   generatedCover=
}


didInit


# Do we have keys?
if [ -z "$savedRefresh" ]; then 
   echo 'Keys not found; obtaining'
   getKeys $did $2
   if [ $? -ne 0 ]; then echo 'You need to pass an app password for auth. You should only need to do this once every 90 days.'; exit 1; fi
   saveRefreshTime
fi

if [ -z "$savedRefreshTime" ]; then savedRefreshTime=0; fi


echo 'Prep complete. Starting loop'

if [ "$1" = "--post-on-start" ]; then postingLogic; fi

while :
do
   if ! [ "$1" = "--posttest" ]; then napTime $postInterval; fi
   if [ "$(date +%s)" -gt "$savedRefreshTime" ]; then refreshKeys; saveRefreshTime; fi
   postingLogic
   if [ "$1" = "--posttest" ]; then exit 0; fi
done
