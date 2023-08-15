#!/bin/sh
xrandr --output HDMI-0 --primary --mode 3440x1440 --pos 1920x767 --rotate normal --output DP-0 --off --output DP-1 --mode 1920x1080 --pos 0x1080 --rotate normal --output DP-2 --off --output DP-3 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-4 --off --output DP-5 --off
DISPLAY_CENTER="HDMI-0"
DISPLAY_LOWER_LEFT="DP-1"
DISPLAY_UPPER_LEFT="DP-3"
bspc monitor $DISPLAY_CENTER -d 1 4 5 6 7 8 9 10
bspc monitor $DISPLAY_LOWER_LEFT -d 2
bspc monitor $DISPLAY_UPPER_LEFT -d 3
