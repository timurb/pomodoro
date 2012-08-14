#!/bin/sh

PATH="$PATH:$(dirname $0)"

[ -z "$1" ] && fail "Usage: $(basename $0) EVENT"

STOPEVENT="$1"

for eventlong in $(pomodoro_status.sh); do
  event=$(echo $eventlong | cut -f1 -d:)
  atno=$(echo $eventlong | cut -f2 -d:)
  [ "x$event" = "x$STOPEVENT" ] && atrm $atno
done
