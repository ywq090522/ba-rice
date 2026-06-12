#!/bin/bash
# GPU info for fastfetch — portable across AMD/NVIDIA/Intel/VM

# 检测 GPU
GPU_LINE=$(lspci 2>/dev/null | grep -E "VGA|3D|Display" | head -1)
if [ -z "$GPU_LINE" ]; then
    printf "No GPU detected"
    exit 0
fi

GPU_ADDR=$(echo "$GPU_LINE" | cut -d' ' -f1)

# 提取 GPU 名称
get_name() {
    local info="$1"
    local name=""
    if echo "$info" | grep -qi "nvidia"; then
        name=$(echo "$info" | grep -oE "GeForce [A-Za-z ]+[0-9]+[A-Za-z]*|RTX [0-9A-Za-z ]+|GTX [0-9A-Za-z ]+|Quadro [A-Za-z0-9 ]+|Tesla [A-Za-z0-9 ]+" | head -1 | sed 's/ *$//')
    elif echo "$info" | grep -qiE "\bamd\b|\bati\b|radeon"; then
        local raw=$(echo "$info" | sed 's/.*\[Radeon //; s/\].*//')
        local base=$(echo "$raw" | cut -d'/' -f1 | sed 's/^ *//; s/ *$//')
        if echo "$raw" | grep -qi "XT"; then
            name="$base XT"
        else
            name="$base"
        fi
    elif echo "$info" | grep -qi "intel"; then
        name=$(echo "$info" | grep -oE "Arc [A-Z0-9 ]+|Iris [A-Za-z0-9 ]+|UHD Graphics [0-9]*|HD Graphics [0-9]*|Graphics [0-9]*" | head -1 | sed 's/ *$//')
    fi
    # fallback
    if [ -z "$name" ]; then
        name=$(echo "$info" | sed 's/^[^:]*: //; s/ (rev [^)]*)//; s/ (prog-if [^)]*)//')
    fi
    echo "$name"
}

NAME=$(get_name "$GPU_LINE")

# 显存：按厂商用不同方法
get_vram() {
    local addr="$1"
    local driver=""

    driver=$(lspci -k -s "$addr" 2>/dev/null | grep "Kernel driver" | awk -F ': ' '{print $2}')

    # NVIDIA: nvidia-smi
    if echo "$driver" | grep -qi "nvidia"; then
        local vram=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
        if [ -n "$vram" ]; then
            echo "$((vram / 1024)) GB"
            return
        fi
    fi

    # AMD: sysfs (遍历所有 card)
    if echo "$driver" | grep -qiE "amdgpu|radeon"; then
        for card_dir in /sys/class/drm/card*/device; do
            local vram_file="$card_dir/mem_info_vram_total"
            if [ -f "$vram_file" ]; then
                local bytes=$(cat "$vram_file")
                if [ "$bytes" -gt 0 ] 2>/dev/null; then
                    echo "$(( (bytes + 536870912) / 1024 / 1024 / 1024 )) GB"
                    return
                fi
            fi
        done
    fi

    # Intel：共享内存
    if echo "$driver" | grep -qiE "i915|xe"; then
        echo "shared"
        return
    fi
}

VRAM=$(get_vram "$GPU_ADDR")

if [ -n "$VRAM" ]; then
    printf "%s \e[2m[%s]\e[0m" "$NAME" "$VRAM"
else
    printf "%s" "$NAME"
fi
