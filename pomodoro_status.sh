#!/bin/sh

MESSAGE=""
[ "$1" = "display" ] && NOTIFY=1

EVENTS=""

for job in $(atq | awk '{print $1}'); do
  ACTION="$( at -c $job | grep POMODORO_ACTION | cut -d: -f2)"
  [ -n "$ACTION" ] && EVENTS="$EVENTS $ACTION:$job"
  [ -n "$NOTIFY" ] && MESSAGE="${MESSAGE}${ACTION} $(atq | grep $job) "
done

for event in $EVENTS; do
  echo $event
done

if [ -n "$MESSAGE" ]; then
  notify-send "$MESSAGE"
fi
