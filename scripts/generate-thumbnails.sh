#!/bin/bash
# Generate 96px PNG thumbnails for all character icons
THUMB_DIR="$HOME/.ba-rice/.thumbs"
CHAR_DIR="$HOME/.ba-rice/characters"

rm -f "$THUMB_DIR"/*.bmp 2>/dev/null

for f in "$CHAR_DIR"/*/icon.png; do
  name=$(basename "$(dirname "$f")")
  magick "$f" -resize 96x96 "$THUMB_DIR/$name.png" && echo "ok: $name" || echo "fail: $name"
done

echo "total: $(ls "$THUMB_DIR"/*.png 2>/dev/null | wc -l)"
du -sh "$THUMB_DIR/"
