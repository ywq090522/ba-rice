#!/bin/bash
# 角色主题选择器

CONFIG_DIR="$HOME/.ba-rice"
CONFIG_FILE="$CONFIG_DIR/config.json"
CHAR_DIR="$HOME/.ba-rice/characters"
THUMB_DIR="$HOME/.ba-rice/.thumbs"

# 获取角色列表
get_characters() {
  jq -r '.characters | keys[]' "$CONFIG_FILE" | sort
}

# 显示 rofi 选择器
show_rofi() {
  local chars=$(get_characters)
  local names=""

  while IFS= read -r char; do
    local name=$(jq -r ".characters.\"$char\".name" "$CONFIG_FILE")
    # 优先用 96px 缩略图，秒开不卡
    local icon="$THUMB_DIR/$char.png"
    if [ ! -f "$icon" ]; then
      icon="$CHAR_DIR/$char/icon.png"
    fi

    if [ -f "$icon" ]; then
      names+="$char\x00icon\x1f$icon\x1fdisplay\x1f$name\n"
    else
      names+="$char\x1fdisplay\x1f$name\n"
    fi
  done <<<"$chars"

  echo -e "$names" | rofi -dmenu -i -p "角色" \
    -theme-str 'window {width: 850px; height: 850px;}' \
    -theme-str 'inputbar {enabled: false;}' \
    -theme-str 'listview {columns: 5; flow: horizontal; cycle: true;}' \
    -theme-str 'element {orientation: vertical; padding: 14px;}' \
    -theme-str 'element-icon {size: 96px;}' \
    -theme-str 'element-text {horizontal-align: 0.5; font-size: 14px;}'
}

# 更新壁纸（swww + hyprlock 背景）
update_wallpaper() {
  local char="$1"
  local wallpaper="$CHAR_DIR/$char/wallpaper.png"

  if [ -f "$wallpaper" ]; then
    swww img "$wallpaper" --transition-type grow --transition-step 30 --transition-fps 60 --transition-duration 2
    cp "$wallpaper" "$CONFIG_DIR/current_wallpaper.png"
  fi
}

# 更新 hyprlock 头像
update_hyprlock() {
  local char="$1"
  local avatar="$CHAR_DIR/$char/avatar.png"

  if [ -f "$avatar" ]; then
    cp "$avatar" "$CONFIG_DIR/current_avatar.png"
  fi
}

# 更新 fastfetch
update_fastfetch() {
  local char="$1"
  local icon="$CHAR_DIR/$char/icon.png"
  local color=$(jq -r ".characters.\"$char\".color" "$CONFIG_FILE")

  if [ "$color" = "null" ] || [ -z "$color" ]; then
    color=$("$CONFIG_DIR/scripts/extract-color.sh" "$char")
  fi

  if [ -f "$icon" ]; then
    local ff_config="$HOME/.ba-rice/configs/fastfetch.jsonc"

    local name=$(jq -r ".characters[\"$char\"].name // \"$char\"" "$CONFIG_FILE")
    local len=${#name}
    local width=48
    local pad=$(( (width - len) / 2 ))
    local format=$(printf "%${pad}s%s" "" "$name")

    jq --arg icon "$icon" \
      --arg color "$color" \
      --arg format "$format" \
      '.logo.source = $icon |
       .logo.recache = true |
       .color.title = $color |
       .color.separator = $color |
       .color.keys = $color |
       .modules = [.modules[] | if .type == "title" then .format = $format | .outputColor = $color else . end]' "$ff_config" >"${ff_config}.tmp" &&
      mv "${ff_config}.tmp" "$ff_config"
  fi
}

# 更新 starship 主题色（替换 palette 中 accent 的 hex 值）
update_starship() {
  local char="$1"
  local color=$(jq -r ".characters.\"$char\".color" "$CONFIG_FILE")

  if [ "$color" = "null" ] || [ -z "$color" ]; then
    color=$("$CONFIG_DIR/scripts/extract-color.sh" "$char")
  fi

  local starship_config="$HOME/.config/starship.toml"
  if [ -f "$starship_config" ] && [ -n "$color" ]; then
    sed -i "s/^accent = \"#.*/accent = \"$color\"/" "$starship_config"
  fi
}

# 更新 waybar 角色名颜色
update_waybar() {
  local char="$1"
  local color=$(jq -r ".characters.\"$char\".color" "$CONFIG_FILE")

  if [ "$color" = "null" ] || [ -z "$color" ]; then
    color=$("$CONFIG_DIR/scripts/extract-color.sh" "$char")
  fi

  local waybar_css="$HOME/.config/waybar/style.css"
  if [ -f "$waybar_css" ] && [ -n "$color" ]; then
    sed -i "s/^@define-color character .*/@define-color character $color;/" "$waybar_css"
  fi
}

# 主流程
main() {
  local selected=$(show_rofi)

  if [ -z "$selected" ]; then
    exit 0
  fi

  # 更新当前角色
  jq --arg char "$selected" '.current = $char' "$CONFIG_FILE" >"${CONFIG_FILE}.tmp" &&
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

  # 并行更新所有组件
  update_wallpaper "$selected" &
  update_hyprlock "$selected" &
  update_fastfetch "$selected" &
  update_starship "$selected" &
  update_waybar "$selected" &

  wait

  pkill -SIGUSR2 waybar 2>/dev/null
  notify-send "角色切换" "已切换到 $(jq -r ".characters.\"$selected\".name" "$CONFIG_FILE")" -i "$CHAR_DIR/$selected/icon.png" 2>/dev/null
  echo "Switched to: $selected"
}

main "$@"
