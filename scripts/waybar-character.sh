#!/bin/bash
# Waybar custom module: current character name with theme color

CONFIG_DIR="$HOME/.ba-rice"
CONFIG_FILE="$CONFIG_DIR/config.json"

current=$(jq -r '.current' "$CONFIG_FILE")
name=$(jq -r ".characters.\"$current\".name" "$CONFIG_FILE")
color=$(jq -r ".characters.\"$current\".color" "$CONFIG_FILE")

if [ -z "$name" ] || [ "$name" = "null" ]; then
  echo '{"text":"—","tooltip":"未选择角色"}'
  exit 0
fi

# escape color for JSON
printf '{"text":"%s","tooltip":"点击切换角色","style":"color: %s"}\n' "$name" "$color"
