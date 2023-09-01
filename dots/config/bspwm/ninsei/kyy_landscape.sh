#!/bin/sh
xrandr --output eDP1 --primary --mode 1920x1200 --pos 0x720 --rotate normal --output DP1 --off --output HDMI1 --mode 1280x720 --pos 160x0 --rotate normal --output VGA1 --off --output VIRTUAL1 --off
bspc monitor eDP1 -d 1 3 4 5 6 7 8 9 10
bspc monitor HDMI1 -d 2
