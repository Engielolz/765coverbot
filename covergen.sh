#!/bin/bash
# SPDX-License-Identifier: MIT
# example=$(grep -F "ARMooo" songs.txt)
# example+="
# $(grep -F "all" songs.txt)"

function iterateGroupsWithoutIdol () {
   counter=1
   cat data/idols.txt | sed -n $num'p' | tr ',' '\n' | while read word; do
      if ! [ "$counter" = "1" ]; then echo $word; fi
      counter+=1
   done
}

function displayIdolGroupDataWithoutIdol () {
num=$1 # Get ARMooo
groups=$(iterateGroupsWithoutIdol)
echo "$groups"
}

function iterateGroups () {
   cat data/idols.txt | sed -n $num'p' | tr ',' '\n' | while read word; do
      echo $word
   done
}

function displayIdolGroupData () {
num=$1
groups=$(iterateGroups)
echo "$groups"
}



function iterateSongs () {
   echo "$(grep -F "$1" data/songs.txt)"
}

function checkAllSongs () {
   songlist=
   while IFS= read -r line; do
      #echo "Working on $line"
      appendlist=
      appendlist="$(iterateSongs $line | cut -f1 -d",")"
      if ! [ -z "$appendlist" ]; then
         songlist+=$(printf "\n ")
         songlist+=$appendlist
      fi
      #echo "Output: $(iterateSongs $line)"
      #songlist+="$(printf "\n ")"
   done <<< $(displayIdolGroupData $1)
   # workaround bug with spaces and newline at beginning. also remove any dupes
   songlist=$(echo "$songlist" | sed 's/^[[:space:]]*//g' | sed "1d" | awk '!seen[$0]++')
}


function getIdolName () {
   cat data/idols.txt | sed -n $1'p' | tr ',' '\n' | sed -n -e 1p
}

function dbgDisplayIdolAndGroups () {
   echo "Idol/Unit: $(getIdolName $1)"
   echo 'In' $(displayIdolGroupDataWithoutIdol $1 | wc -l) "groups:"
   displayIdolGroupDataWithoutIdol $1
}

function pickSong () {
   songNumber=$((1 + $RANDOM % $1 ))
   echo $(echo "$songlist" | sed -n $songNumber'p')
   return
}


function generateCover () {
   idolNumber=$((1 + $RANDOM % $(wc -l < data/idols.txt) ))
   idol=$(getIdolName $idolNumber)
   checkAllSongs $idolNumber
   generatedCover=$(pickSong $(echo "$songlist" | wc -l))" - $idol"
   return
}

function cliMassGenerate () {
   if [ -z "$1" ]; then echo "Specify how many covers should be made"; return 1; fi
   for i in $(seq 1 $1); do
      generateCover
      echo "$generatedCover"
   done
}

function cliTest () {
   generateCover
   echo "Cover: $generatedCover"
   dbgDisplayIdolAndGroups $idolNumber
   echo "$(echo "$songlist" | wc -l) songs available:"
   echo "$songlist"
}

if [ "$1" = "--test" ]; then cliTest; exit 0; fi
if [ "$1" = "--massgenerate" ]; then cliMassGenerate $2; exit 0; fi
if [ "$0" = "$BASH_SOURCE" ] || [ -z "$BASH_SOURCE" ]; then echo "You might be calling this script by itself. Please pass --test parameter to try out the generator."; fi
