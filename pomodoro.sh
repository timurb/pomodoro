#!/bin/sh

ACTION=$1
ICON_PATH="$( pwd )"
EXT="png"
NOTIFY_OPTIONS=''

usage() {
  cat << EOF
Usage:  pomodoro work|rest [TIME]

Default times:
  work: 40m
  rest: 10m
EOF
  exit 1
}


fail() {
  echo "Error: $*"
  exit 1
}

icon_name() {
  [ -z "$1" ] && fail "Usage: icon_name() ICON"

  echo "${ICON_PATH}/$1.$EXT"
}

message() {
  [ -z "$1" ] && fail "Usage: message() ACTION"

  echo "Time for $1"
}

set_alarm() {
  [ -z "$2" ] && fail "Usage: set_alarm() ACTION TIME"

  at "now+$2min" << EOF
    DISPLAY=$DISPLAY notify-send -i "$( icon_name $1 )" $NOTIFY_OPTIONS "$( message $1)"
EOF
}

### Main program starts here

[ -z "$ACTION" ] && usage

which notify-send > /dev/null || fail "notify-send not found. 'apt-get install libnotify-bin' is likely to help you"

case $ACTION in
  work)
    TIME=${2:-40}
    NEXT_ACTION='rest'
    ;;
  rest)
    TIME=${2:-10}
    NEXT_ACTION='work'
    ;;
  *)
    fail "Unknown action: $ACTION"
    ;;
esac

set_alarm $NEXT_ACTION $TIME
