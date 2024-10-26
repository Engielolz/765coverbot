#!/bin/bash
function napTime () {
   now=$(date +%s)
   next_hour=$(((now + $1) / $1 * $1))
   echo "Will sleep for $((next_hour - now)) seconds"
}

napTime 3600

napTime 14400

napTime 60
