#!/bin/sh
xrandr --output eDP1 --primary --mode 1920x1200 --pos 330x1440 --rotate normal --output DP1 --off --output HDMI1 --mode 2560x1440 --pos 0x0 --rotate normal --output VIRTUAL1 --off
bspc monitor eDP1 -d 1 3 4 5 6 7 8 9 10
bspc monitor HDMI1 -d 2
