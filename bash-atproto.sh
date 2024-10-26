#!/bin/bash

# Load tokens if already present
if [[ -f ./secrets.env ]]; then while IFS= read -r line; do declare "$line"; done < ./secrets.env
fi
# $1 must be our DID of the account
did_regex="^did:\S*:\S*"
coverWarn=0


function saveKeys () {
   echo 'Updating secrets'
   echo 'savedAccess='$savedAccess > ./secrets.env
   echo 'savedRefresh='$savedRefresh >> ./secrets.env
   echo 'savedDID='$savedDID >> ./secrets.env
   return 0
}

function processAPIError () {
   echo 'Function' $1 'encountered an API error'
   APIErrorCode=$(echo ${!2} | jq -r .error)
   APIErrorMessage=$(echo ${!2} | jq -r .message)
   echo 'Error code:' $APIErrorCode
   echo 'Message:' $APIErrorMessage
   if [ "$APIErrorCode" = "AccountTakedown" ] || [ "$APIErrorCode" = "InvalidRequest" ] || [ "$APIErrorCode" = "InvalidToken" ]; then 
      echo "Safety triggered. Dumping error and shutting down."
      echo ${!2} > ./fatal.json
      exit 115
   fi;
}

function getKeys () {
   if [ -z "$2" ]; then echo "No app password was passed"; return 1; fi
   echo 'Opening session'
   keyInfo=$(curl --fail-with-body -s -X POST -H 'Content-Type: application/json' -d "{ \"identifier\": \"$1\", \"password\": \"$2\" }" "https://bsky.social/xrpc/com.atproto.server.createSession")
   if [ "$?" = "22" ]; then
      echo 'fatal: failed to authenticate'
      processAPIError getKeys keyInfo
      echo $keyInfo > failauth.json
      exit 1
   fi
   echo Authenticate SUCCESS
   # echo $keyInfo > debug.json
   savedAccess=$(echo $keyInfo | jq -r .accessJwt)
   savedRefresh=$(echo $keyInfo | jq -r .refreshJwt)
   savedDID=$(echo $keyInfo | jq -r .did)
   # we don't care about the handle
   saveKeys
   return 0
}

function refreshKeys () {
   echo 'Trying to refresh keys...'
   keyInfo=$(curl --fail-with-body -s -X POST -H "Authorization: Bearer $savedRefresh" -H 'Content-Type: application/json' "https://bsky.social/xrpc/com.atproto.server.refreshSession")
   if [ "$?" = "22" ]; then
      echo 'fatal: failed to refresh keys!'
      processAPIError refreshKeys keyInfo
      echo $keyInfo > failauth.json
      return 1
   fi
   echo Refresh succeeded.
   savedAccess=$(echo $keyInfo | jq -r .accessJwt)
   savedRefresh=$(echo $keyInfo | jq -r .refreshJwt)
   savedDID=$(echo $keyInfo | jq -r .did)
   saveKeys
   return 0
}

function postToBluesky () { # savedAccess
   if [ -z "$1" ]; then echo "Nothing to post. Screw this, I'm outta here!"; return 1; fi

   result=$(curl --fail-with-body -X POST -H "Authorization: Bearer $savedAccess" -H 'Content-Type: application/json' -d "{ \"collection\": \"app.bsky.feed.post\", \"repo\": \"$did\", \"record\": { \"text\": \"$1\", \"createdAt\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\", \"\$type\": \"app.bsky.feed.post\", \"langs\": [ \"en-US\" ] } } " "https://bsky.social/xrpc/com.atproto.repo.createRecord")
   if [ "$?" = "22" ]; then
      echo 'Warning: the post failed.'
      APIErrorCode=$(echo $result | jq -r .error)
      if ! [ "$APIErrorCode" = "ExpiredToken" ]; then processAPIError postToBluesky result; return 1; fi
      echo 'The token needs to be refreshed.'
      return 2
   fi
   coverResult=
   uri=$(echo $result | jq -r .uri)
   echo "Posted record at $uri"
   return 0
}


function didInit () {
skipDIDFetch=0


if ! [ -z "$savedDID" ]; then
   skipDIDFetch=1
   did=$savedDID
   echo 'Obtained DID from cache'
fi


if [[ "$skipDIDFetch" = "0" ]] && [[ "$1" =~ $did_regex ]] ; then
   skipDIDFetch=1
   did=$1
   echo 'Obtained user-specified DID'
fi
if [ "$skipDIDFetch" = "0" ]; then
   echo 'DID not specified. Fetching from ATproto API'
   did=$(curl -s -G --data-urlencode "handle=$1" "https://bsky.social/xrpc/com.atproto.identity.resolveHandle" | jq -r .did)
   if ! [[ "$did" =~ $did_regex ]]; then
      echo "Error obtaining DID from API"
      exit 1
   fi
   echo "Obtained DID from API!"
fi
echo 'Using DID' $did
}

