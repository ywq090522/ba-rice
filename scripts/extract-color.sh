#!/bin/bash
# 从 avatar.png 提取最鲜艳的颜色并映射到 Catppuccin Mocha

CONFIG_DIR="$HOME/.ba-rice"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Catppuccin Mocha 颜色表
declare -A CATPPUCCIN=(
    ["Rosewater"]="f5e0dc"
    ["Flamingo"]="f2cdcd"
    ["Pink"]="f5c2e7"
    ["Mauve"]="cba6f7"
    ["Red"]="f38ba8"
    ["Maroon"]="eba0ac"
    ["Peach"]="fab387"
    ["Yellow"]="f9e2af"
    ["Green"]="a6e3a1"
    ["Teal"]="94e2d5"
    ["Sky"]="89dceb"
    ["Sapphire"]="74c7ec"
    ["Blue"]="89b4fa"
    ["Lavender"]="b4befe"
)

# RGB 欧氏距离
color_distance() {
    local r1=$1 g1=$2 b1=$3
    local r2=$4 g2=$5 b2=$6
    echo $(( (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2 ))
}

# 从图片提取最鲜艳的颜色（高饱和度 + 高亮度）
extract_vibrant_color() {
    local img="$1"

    # 缩小图片，量化到 16 色，输出 RGB 值
    local colors=$(magick "$img" -resize 64x64 -colorspace RGB \
        -dither None -colors 16 -depth 8 \
        -format '%c' histogram:info: 2>/dev/null | \
        grep -oP '#[0-9A-Fa-f]{6}' | sort -u)

    if [ -z "$colors" ]; then
        echo ""
        return
    fi

    local best_color=""
    local best_score=0

    while IFS= read -r hex; do
        [ -z "$hex" ] && continue

        # 跳过接近白色、黑色、灰色的
        hex="${hex#\#}"
        local r=$((16#${hex:0:2}))
        local g=$((16#${hex:2:2}))
        local b=$((16#${hex:4:2}))

        # 计算饱和度（简化版：最大通道和最小通道的差）
        local max=$r; local min=$r
        [ $g -gt $max ] && max=$g; [ $g -lt $min ] && min=$g
        [ $b -gt $max ] && max=$b; [ $b -lt $min ] && min=$b
        local saturation=$(( max - min ))

        # 计算亮度
        local brightness=$(( (r + g + b) / 3 ))

        # 跳过太暗或太灰的
        [ $saturation -lt 30 ] && continue
        [ $brightness -lt 40 ] && continue
        [ $brightness -gt 230 ] && continue

        # 综合评分：饱和度权重高，亮度适中
        local score=$(( saturation * 2 + brightness ))

        if [ $score -gt $best_score ]; then
            best_score=$score
            best_color="$hex"
        fi
    done <<< "$colors"

    # 如果没找到鲜艳色，降级取主色
    if [ -z "$best_color" ]; then
        best_color=$(magick "$img" -resize 64x64 -colors 1 -depth 8 \
            -format '%[pixel:u]' info: 2>/dev/null | \
            grep -oP '[0-9A-Fa-f]{6}' | head -1)
    fi

    echo "$best_color"
}

# 映射到 Catppuccin
map_to_catppuccin() {
    local hex="$1"
    # 移除 # 并转换为 RGB
    hex="${hex#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    local min_dist=999999
    local closest=""

    for name in "${!CATPPUCCIN[@]}"; do
        local chex="${CATPPUCCIN[$name]}"
        local cr=$((16#${chex:0:2}))
        local cg=$((16#${chex:2:2}))
        local cb=$((16#${chex:4:2}))

        local dist=$(color_distance $r $g $b $cr $cg $cb)
        if [ "$dist" -lt "$min_dist" ]; then
            min_dist=$dist
            closest="$name"
        fi
    done

    echo "${CATPPUCCIN[$closest]}"
}

# 主函数
if [ -z "$1" ]; then
    echo "Usage: $0 <character_name>"
    exit 1
fi

CHAR="$1"
CHAR_DIR=$(jq -r ".characters.\"$CHAR\".dir" "$CONFIG_FILE")
AVATAR="$CHAR_DIR/avatar.png"

if [ ! -f "$AVATAR" ]; then
    echo "Error: $AVATAR not found"
    exit 1
fi

# 提取颜色
RAW_COLOR=$(extract_vibrant_color "$AVATAR")
if [ -z "$RAW_COLOR" ]; then
    echo "Error: Could not extract color from $AVATAR"
    exit 1
fi

# 映射到 Catppuccin
MAPPED=$(map_to_catppuccin "$RAW_COLOR")

# 更新配置
jq ".characters.\"$CHAR\".color = \"#$MAPPED\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && \
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

echo "#$MAPPED"
