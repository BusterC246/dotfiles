#!/bin/sh
MAX_LOAD_PER_CORE="${MAX_LOAD_PER_CORE:-0.75}"

CORES="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
LOAD1="$(awk '{print $1}' /proc/loadavg)"

THRESH="$(awk -v c="$CORES" -v p="$MAX_LOAD_PER_CORE" 'BEGIN{print c*p}')"

if awk -v l="$LOAD1" -v t="$THRESH" 'BEGIN{exit !(l >= t)}'; then
  exit 0
fi

loginctl suspend
