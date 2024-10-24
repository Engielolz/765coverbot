#!/bin/bash
echo '765 Cover Bot'
echo 'Using atproto the dirty way! (bash and cURL)'
# Load tokens if already present
if [[ -f ./secrets.env ]]; then while IFS= read -r line; do declare "$line"; done < ./secrets.env
fi
# $1 must be our DID of the account
did_regex="^did:\S*:\S*"
skipDIDFetch=0


function saveKeys () {
   echo 'Updating secrets'
   echo 'savedAccess='$savedAccess > ./secrets.env
   echo 'savedRefresh='$savedRefresh >> ./secrets.env
   echo 'savedDID='$savedDID >> ./secrets.env
   return 0
}

function getKeys () {
   if [ -z "$2" ]; then echo "No app password was passed"; return 1; fi
   echo 'Opening session'
   keyInfo=$(curl --fail-with-body -s -X POST -H 'Content-Type: application/json' -d "{ \"identifier\": \"$1\", \"password\": \"$2\" }" "https://bsky.social/xrpc/com.atproto.server.createSession")
   if [ "$?" = "22" ]; then
      echo 'fatal: failed to authenticate'
      echo $keyInfo > failauth.json
      exit 1
   fi
   echo Authenticate SUCCESS
   echo $keyInfo > debug.json
   savedAccess=$(echo $keyInfo | jq -r .accessJwt)
   savedRefresh=$(echo $keyInfo | jq -r .refreshJwt)
   savedDID=$(echo $keyInfo | jq -r .did)
   # we don't care about the handle
   saveKeys
   return 0
}




if [[ "$1" =~ $did_regex ]] ; then
   skipDIDFetch=1
   did=$1
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

# Do we have keys?
if [ -z "$savedRefresh" ]; then 
   echo 'Keys not found; obtaining'
   getKeys $did $2
   if [ $? -ne 0 ]; then echo 'You need to pass an app password for auth. You should only need to do this once every 90 days.'; exit 1; fi
fi
# Do we need to refresh the key?
