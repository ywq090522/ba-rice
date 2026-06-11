#!/bin/bash
# CPU info for fastfetch — portable across Intel/AMD/ARM/VM

# CPU 名称：直接取 /proc/cpuinfo 的 model name，去掉冗余字段
NAME=$(grep -m1 "model name" /proc/cpuinfo | sed 's/.*: //; s/ @.*//; s/(R)//; s/(TM)//; s/  */ /g; s/^ *//; s/ *$//')
# fallback: ARM/RISC-V 等没有 model name
if [ -z "$NAME" ]; then
    NAME=$(grep -m1 "^Hardware" /proc/cpuinfo | sed 's/.*: //' 2>/dev/null)
fi
if [ -z "$NAME" ]; then
    NAME=$(uname -m)
fi

# 核心数
CORE=$(nproc 2>/dev/null || grep -c "^processor" /proc/cpuinfo)

# 频率：优先读当前频率，fallback 到最大频率
GHZ=""
FREQ_FILE="/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq"
MAX_FILE="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
if [ -f "$FREQ_FILE" ]; then
    GHZ=$(awk '{printf "%.1f", $1/1000000}' "$FREQ_FILE")
elif [ -f "$MAX_FILE" ]; then
    GHZ=$(awk '{printf "%.1f", $1/1000000}' "$MAX_FILE")
fi

if [ -n "$GHZ" ]; then
    printf "%s \e[2m[%s cores] [%s GHz]\e[0m" "$NAME" "$CORE" "$GHZ"
else
    printf "%s \e[2m[%s cores]\e[0m" "$NAME" "$CORE"
fi
