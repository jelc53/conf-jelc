#!/bin/bash
URI="google.com/search?q="
if [ "$#" -ge 1 ]; then
  ARGS=$@
  ARG1=$(echo $ARGS | cut -d " " -f 1)
  if [ "$ARG1" = "p" ]; then
    ARGS=$(echo $ARGS | cut -d " " -f2-)
    firefox -private-window "$URI$ARGS" > /dev/null &
  else
    firefox "$URI$ARGS" > /dev/null &
  fi
else
  xdo activate -n firefox
fi
exit 0
