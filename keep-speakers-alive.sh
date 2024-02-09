#!/bin/bash
function run {
  WAV_FILE=/home/virgil/bin/100-Hz.wav # Works
  #WAV_FILE=/home/virgil/diverse/100-hz-001.wav # Untested
  #WAV_FILE=/home/virgil/diverse/100-hz-0001.wav # Does not work
  while :
  do
      (paplay -v $WAV_FILE) \
      && echo "done"
    date
    sleep 5m
  done
}

run

