#!/bin/sh
NOW=$(date '+%Y%m%d%H%M%S')
LOGFILE="log.$NOW"

while true
do
      echo $(date '+[TIME: %H:%M:%S]   Output: ' ; ps aux | grep "python" | grep -v "grep" | wc -l ) | tee -a $LOGFILE
          sleep 60 
done
