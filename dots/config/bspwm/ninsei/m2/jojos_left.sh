#!/bin/sh
xrandr --output eDP-1 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1-0 --off --output DP-1-1 --off --output HDMI-1-0 --primary --mode 1920x1080 --pos 1920x0 --rotate normal
bspc monitor HDMI-1-0 -d 1 3 4 5 6 7 8 9 10
bspc monitor eDP-1 -d 2
