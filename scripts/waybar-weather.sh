#!/bin/bash
# Waybar custom module: weather info (city + temperature)
# Uses wttr.in — no API key needed

CONFIG_FILE="$HOME/.ba-rice/config.json"

city=$(jq -r '.weather.city // empty' "$CONFIG_FILE")
query=$(jq -r '.weather.query // empty' "$CONFIG_FILE")

if [ -z "$city" ]; then
  echo '{"text":"未设置城市","tooltip":"在 ~/.ba-rice/config.json 中设置 weather.city"}'
  exit 0
fi

# query 为空时用 city 做 API 查询
[ -z "$query" ] && query="$city"

# 从 wttr.in 获取温度
temp=$(curl -s --max-time 5 "wttr.in/${query}?format=%t" 2>/dev/null | tr -d '[:space:]' | sed 's/^+//')

if [ -z "$temp" ] || [ "$temp" = "Unknownlocation" ]; then
  printf '{"text":"%s —","tooltip":"天气获取失败"}\n' "$city"
  exit 0
fi

printf '{"text":"%s %s","tooltip":"点击查看天气详情","class":"weather"}\n' "$city" "$temp"
