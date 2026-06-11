#!/bin/bash

NAME=$(grep -m1 "model name" /proc/cpuinfo | grep -oE '[a-z][0-9]+-[0-9]+[A-Z]*' | head -1)
CORE=$(grep -c "^processor" /proc/cpuinfo)
GHZ=$(echo "scale=2; $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq) / 1000000" | bc)

printf "%s \e[2m[%s] [%sGHz]\e[0m" "$NAME" "$CORE" "$GHZ"