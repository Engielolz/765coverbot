#!/bin/bash

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
fakeData="{\"error\":\"InvalidToken\",\"message\":\"Invalid identifier or password\"}"
processAPIError fakeException fakeData
echo $APIErrorCode
