#!/bin/bash
echo '765 Cover Bot'
echo 'Using atproto the dirty way! (bash and cURL)'

function loadFail () {
   echo "Cannot load required dependency script"
   exit 127
}

source bash-atproto.sh
if ! [ "$?" = "0" ]; then loadFail; fi
source covergen.sh
if ! [ "$?" = "0" ]; then loadFail; fi

refreshInterval=1800 # refresh every half hour
postInterval=3600 # post every hour

function saveKeysAndRefreshTime () {
   saveKeys
   echo 'savedRefreshTime='$(( $(date +%s) + $refreshInterval )) >> ./secrets.env
}

function napTime () {
   now=$(date +%s)
   next_hour=$(((now + $1) / $1 * $1))
   sleeptime=$((next_hour - now))
   echo "Sleeping until $(date -d @$(($(date +%s) + $sleeptime)))"
   sleep $sleeptime
}

didInit


# Do we have keys?
if [ -z "$savedRefresh" ]; then 
   echo 'Keys not found; obtaining'
   getKeys $did $2
   if [ $? -ne 0 ]; then echo 'You need to pass an app password for auth. You should only need to do this once every 90 days.'; exit 1; fi
fi


echo 'Prep complete. Starting loop'

while :
do
   if ! [ "$1" = "--posttest" ]; then napTime $postInterval; fi
   if [ "$(date +%s)" -gt "$savedRefreshTime" ]; then refreshKeys; fi
   generateCover
   postToBluesky "$generatedCover"
   if [ "$?" = "2" ]; then
      refreshKeys
      postToBluesky "$generatedCover"
   fi
   if [ "$1" = "--posttest" ]; then exit 0; fi
done
