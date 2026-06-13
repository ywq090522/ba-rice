#!/bin/bash
# Fastfetch character info module
# Usage: fastfetch-char-module.sh <field>
# field: game | element | role | faction

CONFIG="$HOME/.ba-rice/config.json"
current=$(jq -r '.current' "$CONFIG")
value=$(jq -r ".characters.\"$current\".\"$1\" // \"—\"" "$CONFIG")
echo "$value"
