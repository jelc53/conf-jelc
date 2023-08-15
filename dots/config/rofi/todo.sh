#!/bin/bash
FILE=/data/todos.md
TODOS=$(<$FILE)
echo "$TODOS"
TODO=$(echo "$TODOS" | rofi -dmenu -i -p "todo")
[[ $TODO =~ ^$ ]] && exit 0
if echo "$TODOS" | grep -q "^$TODO"; then
  echo "$TODOS" | grep -v "^$TODO" >| $FILE
else
  echo $TODO >> $FILE
fi
