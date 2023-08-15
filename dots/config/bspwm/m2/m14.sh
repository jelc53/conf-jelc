#!/bin/sh
xrandr --output eDP1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output VIRTUAL1 --off --output DP-1-0 --off --output DP-1-1 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1-0 --off
bspc monitor eDP1 -d 1 3 4 5 6 7 8 9 10
bspc monitor DP-1-1 -d 2
