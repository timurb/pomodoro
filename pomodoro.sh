#!/bin/sh

ACTION=$1
TIME=$2
ICON_PATH="$( dirname $( readlink $0 ) )"
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

check_string() {
  echo "$1" | egrep -qv '(;|&|\||<|>)' || \
    fail "$1 contains special characters:  ;&|<>"
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
  [ -z "$2" ] && fail "Usage: set_alarm() ACTION TIME REPEAT"

  (
    echo "echo \"POMODORO_ACTION:$1:\" > /dev/null" # this is needed for checking current status
    echo "DISPLAY=$DISPLAY notify-send -i \"$( icon_name $1 )\" $NOTIFY_OPTIONS \"$( message $1)\""
    [ -n "$REPEAT" ] && echo "DISPLAY=$DISPLAY POMODORO_CONFIG=\"$POMODORO_CONFIG\" $0 $1"
  ) |  at "now+$2min"
}

### Main program starts here

[ -z "$ACTION" ] && usage

check_string "$ACTION"

which notify-send > /dev/null || fail "notify-send not found. 'apt-get install libnotify-bin' is likely to help you"

[ -r "$HOME/.pomodoro-config" ] && . "$HOME/.pomodoro-config"
[ -n "$POMODORO_CONFIG" ] && . "$POMODORO_CONFIG"

if [ -z "$ACTIONS" ]; then
  ACTIONS="work rest"
  [ -z "$work_duration" ] && work_duration=40
  [ -z "$rest_duration" ] && rest_duration=10
  work_nextaction=rest
  rest_nextaction=work
fi

for action in $(echo $ACTIONS); do
  if [ "x$ACTION" = "x$action" ]; then
    ACTION_FOUND=1
    TIME=${TIME:-"$( eval echo "\$${action}_duration" )"}
    NEXT_ACTION="$( eval echo "\$${action}_nextaction" )"
    break
  fi
done

[ -z "$ACTION_FOUND" ] && fail "Unknown action: ${ACTION}"

set_alarm $NEXT_ACTION $TIME $REPEAT
