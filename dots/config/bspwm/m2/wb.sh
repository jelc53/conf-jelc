#!/bin/sh
xrandr --output eDP1 --primary --mode 1920x1080 --pos 0x1080 --rotate normal --output VIRTUAL1 --off --output DP-1-0 --off --output DP-1-1 --off --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
bspc monitor eDP1 -d 1 4 5 6 7 8 9 10
bspc monitor HDMI-1-0 -d 2 3
