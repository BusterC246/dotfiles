#!/bin/sh

MAX_LOAD_PER_CORE="${MAX_LOAD_PER_CORE:-0.50}"

CORES="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
THRESH="$(awk -v c="$CORES" -v p="$MAX_LOAD_PER_CORE" 'BEGIN{print c*p}')"

while true; do
  LOAD1="$(awk '{print $1}' /proc/loadavg)"

  if awk -v l="$LOAD1" -v t="$THRESH" 'BEGIN{exit !(l >= t)}'; then
    sleep 60
  else
    loginctl suspend
  fi
done
