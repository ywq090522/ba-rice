#!/bin/bash
# CPU info for fastfetch — portable across Intel/AMD/ARM/VM

# CPU 名称：只保留型号（如 i5-10600KF、Ryzen 7 5800X）
NAME=$(grep -m1 "model name" /proc/cpuinfo | sed 's/.*: //; s/ @.*//; s/(R)//g; s/(TM)//g; s/Intel//g; s/Core//g; s/CPU//g; s/  */ /g; s/^ *//; s/ *$//')
# fallback: ARM/RISC-V 等没有 model name
if [ -z "$NAME" ]; then
    NAME=$(grep -m1 "^Hardware" /proc/cpuinfo | sed 's/.*: //' 2>/dev/null)
fi
if [ -z "$NAME" ]; then
    NAME=$(uname -m)
fi

# 核心数
CORE=$(nproc 2>/dev/null || grep -c "^processor" /proc/cpuinfo)

# 频率：读最大频率，fallback 到当前频率
GHZ=""
MAX_FILE="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
FREQ_FILE="/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq"
if [ -f "$MAX_FILE" ]; then
    GHZ=$(awk '{printf "%.1f", $1/1000000}' "$MAX_FILE")
elif [ -f "$FREQ_FILE" ]; then
    GHZ=$(awk '{printf "%.1f", $1/1000000}' "$FREQ_FILE")
fi

if [ -n "$GHZ" ]; then
    printf "%s \e[2m[%s cores] [%s GHz]\e[0m" "$NAME" "$CORE" "$GHZ"
else
    printf "%s \e[2m[%s cores]\e[0m" "$NAME" "$CORE"
fi
