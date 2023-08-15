#!/bin/sh
xrandr --output DP-1.1 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1.3 --primary --mode 3440x1440 --pos 1920x831 --rotate normal --output DP-0 --mode 1920x1080 --pos 0x1080 --rotate normal --output DP-1 --off --output HDMI-0 --off
DISPLAY_CENTER="%DP-1.3"
DISPLAY_LOWER_LEFT="DP-0"
DISPLAY_UPPER_LEFT="%DP-1.1"
bspc monitor $DISPLAY_CENTER -d 1 4 5 6 7 8 9 10
bspc monitor $DISPLAY_LOWER_LEFT -d 2
bspc monitor $DISPLAY_UPPER_LEFT -d 3
