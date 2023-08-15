#!/bin/bash
source ~/.keys/spotify/login.sh
spotifyd \
  --backend pulseaudio \
  --device-name $(hostname)-spotifyd \
  --device-type computer \
  --mixer pamixer \
  --username $SPOTIFY_USER \
  --password $SPOTIFY_PASSWORD
