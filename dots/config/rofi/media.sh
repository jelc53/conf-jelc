#!/bin/bash
if [[ ! -z "$1" ]]
then
  MEDIA=$(echo "$1" | awk -F ' -> ' '{printf "%s/%s", $2, $1}')
  xdg-open "$MEDIA" > /dev/null &
else
  fd . -e pdf -e mpg -e mp4 -e png -e jpg -e jpeg -I /data ~/Zotero/storage -x echo -e '{/} -> {//}'
fi
