#!/bin/bash
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
   echo "Idol: $(getIdolName $1)"
   echo "Groups:"
   displayIdolGroupDataWithoutIdol $1
   echo 'Total:' $(displayIdolGroupDataWithoutIdol $1 | wc -l)
}


# Pick a group...

dataLines=$(wc -l < data/idols.txt)
aNumber=$((1 + $RANDOM % $dataLines ))
dbgDisplayIdolAndGroups $aNumber
checkAllSongs $aNumber
echo "List is $songlist"
echo "There are $(echo "$songlist" | wc -l) songs!"
