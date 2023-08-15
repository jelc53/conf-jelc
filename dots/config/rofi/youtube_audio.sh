#!/bin/bash
nohup mpv --no-video $(youtube-dl -g $1) > /dev/null 2>&1 &
