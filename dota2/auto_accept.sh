#!/bin/bash

#MOUSE_POSITION="746 571"
MOUSE_POSITION="1696 1150" # dota2 reborn
PID_FILE="/tmp/dota2_auto_accept.pid"

if [[ -e $PID_FILE ]]; then
  kill `cat $PID_FILE`
  rm $PID_FILE
  exit
fi

echo $$ > $PID_FILE

for ((;;)) do
  xdotool mousemove $MOUSE_POSITION click 1
  sleep 5
done
