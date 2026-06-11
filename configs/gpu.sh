#!/bin/bash

GPU_INFO=$(lspci | grep -E "VGA|3D" | head -1)
GPU_INFO2=$(lspci | grep -E "VGA|3D" | head -1 | cut -d' ' -f1)

get_gpu() {
    if echo "$GPU_INFO" | grep -qi "intel"; then
        echo "$GPU_INFO" | grep -oE "UHD Graphics [0-9]+|HD Graphics [0-9]+|Arc [A-Z0-9]+|Iris [A-Za-z0-9]+" | head -1
    elif echo "$GPU_INFO" | grep -qi "amd"; then
        echo "$GPU_INFO" | grep -oE "RX [0-9]+ [A-Z]+|[0-9]+ [A-Z]+" | grep -oE "[0-9]+ [A-Z]+" | tail -1 | sed 's/^/RX /'
    elif echo "$GPU_INFO" | grep -qi "nvidia"; then
        echo "$GPU_INFO" | grep -oE "GeForce [A-Z0-9]+|RTX [0-9]+|GTX [0-9]+" | head -1
    else
        echo "Unknown"
    fi
}

GPUMEM=$(cat /sys/class/drm/card1/device/mem_info_vram_total 2>/dev/null | awk '{printf "%.0f GB\n", $1 / 1024 / 1024 / 1024}')
DRIVER=$(lspci -k -s "$GPU_INFO2" | grep "Kernel driver" | awk -F ': ' '{print $2}')

printf "%s \e[2m[%s] [%s]\e[0m" "$(get_gpu)" "$GPUMEM" "$DRIVER"
