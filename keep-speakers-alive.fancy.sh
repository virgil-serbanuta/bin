#!/bin/bash
function run {
  WAV_FILE=/home/virgil/diverse/100-hz.wav # Works
  WAV_FILE=/home/virgil/diverse/100-hz-001.wav # Untested
  #WAV_FILE=/home/virgil/diverse/100-hz-0001.wav # Does not work
  while :
  do
    (who | grep virgil) \
      && (gsettings get org.gnome.desktop.lockdown disable-lock-screen | grep false) \
      && (paplay -v $WAV_FILE -d alsa_output.usb-GPE_KEF_EGG-00.analog-stereo || paplay -v $WAV_FILE) \
      && echo "done"
    date
    sleep 5m
  done
}
pulseaudio -k; pulseaudio -D
run
