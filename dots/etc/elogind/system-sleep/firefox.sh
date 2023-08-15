#!/bin/bash

# if Firefox is currently focused, cancel suspend
FOCUSED=$(xdotool getwindowclassname $(bspc query -N -n .focused))
if [[ "$FOCUSED" == "Firefox" ]]; then exit 1; fi

# if Firefox is fullscreen, cancel suspend
for w in $(bspc query -N -n .fullscreen)
do
  if [[ "$(xdotool getwindowclassname $w)" == "Firefox" ]]; then
    exit 1
  fi
done
