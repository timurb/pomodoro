#!/bin/sh

fail() {
  echo "ERROR: $*"
  exit 1
}

[ -z "$1" ] && fail "Usage: $(basename $0) EVENT"
STOPEVENT="$1"

PATH="$PATH:$(dirname $0)"
STATUS="$( which pomodoro_status.sh | grep -v 'not found' )"
[ -z "$STATUS" ] && STATUS="$( which pomodoro_status | grep -v 'not found' )"

for eventlong in $(pomodoro_status.sh); do
  event=$(echo $eventlong | cut -f1 -d:)
  atno=$(echo $eventlong | cut -f2 -d:)
  [ "x$event" = "x$STOPEVENT" ] && atrm $atno
done
