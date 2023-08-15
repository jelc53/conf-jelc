#!/bin/sh
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x439 --rotate normal --output DP-1-0 --off --output DP-1-1 --off --output HDMI-1-0 --mode 3840x2160 --pos 1920x0 --rotate normal
bspc monitor eDP-1 -d 1 3 4 5 6 7 8 9 10
bspc monitor HDMI-1-0 -d 2
