#!/bin/bash
# ba-rice: Blue Archive Character Theme System — 一键部署脚本
set -e

REPO_URL="${1:-root@192.168.121.91:/root/.hermes/repos/ba-rice.git}"
IMAGE_TAR="${2:-}"
BA="$HOME/.ba-rice"

echo "╔══════════════════════════════════════╗"
echo "║   BA Character Theme — Deploy        ║"
echo "╚══════════════════════════════════════╝"

# ── 依赖检查 ──
echo ""
echo "▸ 检查依赖..."
DEPS=(jq rofi swww)
MISSING=()
for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        MISSING+=("$dep")
    fi
done
if [ ${#MISSING[@]} -gt 0 ]; then
    echo "  ✗ 缺少: ${MISSING[*]}"
    echo "  请手动安装后再运行本脚本"
    exit 1
fi
echo "  ✓ 依赖齐全"

# ── 克隆仓库 ──
echo ""
echo "▸ 克隆配置..."
if [ -d "$BA/.git" ]; then
    echo "  已存在，拉取最新..."
    git -C "$BA" pull --ff-only 2>/dev/null || true
else
    if ! git clone "$REPO_URL" "$BA" 2>/dev/null; then
        echo "  ✗ 无法连接裸仓库"
        echo "  请手动克隆到 $BA 后重新运行本脚本"
        echo "  例如: git clone <仓库地址> $BA"
        exit 1
    fi
fi

# ── 解压图片 ──
echo ""
echo "▸ 解压角色图片..."
if [ -d "$BA/characters/shiroko" ]; then
    echo "  已存在，跳过"
elif [ -n "$IMAGE_TAR" ] && [ -f "$IMAGE_TAR" ]; then
    tar xzf "$IMAGE_TAR" -C "$BA/"
    echo "  ✓ 从 $IMAGE_TAR 解压完成"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    TAR_FILE="$SCRIPT_DIR/ba-rice-images.tar.gz"
    if [ -f "$TAR_FILE" ]; then
        tar xzf "$TAR_FILE" -C "$BA/"
        echo "  ✓ 从 $TAR_FILE 解压完成"
    else
        echo "  ✗ 未找到图片包！请提供路径:"
        echo "    $0 <repo_url> <path/to/ba-rice-images.tar.gz>"
        echo "  或手动解压到 $BA/characters/"
    fi
fi

# ── 创建 symlink ──
echo ""
echo "▸ 创建 symlink..."

# fastfetch config
mkdir -p "$HOME/.config/fastfetch"
ln -sfn "$BA/configs/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"
echo "  fastfetch config → $BA/configs/fastfetch.jsonc"
ln -sfn "$BA/configs/cpu.sh" "$HOME/.config/fastfetch/cpu.sh"
echo "  cpu.sh → $BA/configs/cpu.sh"
ln -sfn "$BA/configs/gpu.sh" "$HOME/.config/fastfetch/gpu.sh"
echo "  gpu.sh → $BA/configs/gpu.sh"

# fish fastfetch wrapper
mkdir -p "$HOME/.config/fish/conf.d"
ln -sfn "$BA/configs/fastfetch.fish" "$HOME/.config/fish/conf.d/fastfetch.fish"
echo "  fish fastfetch wrapper → $BA/configs/fastfetch.fish"

# Pictures/character 兼容性
mkdir -p "$HOME/Pictures"
ln -sfn "$BA/characters" "$HOME/Pictures/character"
echo "  Pictures/character → $BA/characters"
# SDDM/KDE 头像
ln -sfn "$BA/current_avatar.png" "$HOME/.face"
ln -sfn "$BA/current_avatar.png" "$HOME/.face.icon"
echo "  .face + .face.icon → $BA/current_avatar.png"

# ── Hyprland keybind ──
echo ""
echo "▸ 配置 Hyprland keybind..."
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
HYPR_CHAR="$BA/configs/hyprland-character.conf"
if [ -f "$HYPR_CONF" ]; then
    if ! grep -q 'hyprland-character.conf' "$HYPR_CONF" 2>/dev/null; then
        echo "" >> "$HYPR_CONF"
        echo "# ba-rice character theme" >> "$HYPR_CONF"
        echo "source = $HYPR_CHAR" >> "$HYPR_CONF"
        echo "  ✓ 已追加 source 到 hyprland.conf"
    else
        echo "  已配置，跳过"
    fi
else
    echo "  ! hyprland.conf 不存在，请手动添加:"
    echo "    source = $HYPR_CHAR"
fi

# ── 初始化当前角色 ──
echo ""
echo "▸ 初始化当前角色..."
CURRENT=$(jq -r '.current // empty' "$BA/config.json" 2>/dev/null)
if [ -n "$CURRENT" ] && [ -d "$BA/characters/$CURRENT" ]; then
    echo "  当前角色: $CURRENT"
else
    FIRST=$(jq -r '.characters | keys[0]' "$BA/config.json" 2>/dev/null)
    if [ -n "$FIRST" ]; then
        jq --arg c "$FIRST" '.current = $c' "$BA/config.json" > "$BA/config.json.tmp" && mv "$BA/config.json.tmp" "$BA/config.json"
        echo "  默认角色: $FIRST"
    fi
fi

# 更新 fastfetch icon 路径
ICON="$BA/characters/$(jq -r '.current' "$BA/config.json")/icon.png"
if [ -f "$ICON" ]; then
    jq --arg icon "$ICON" '.logo.source = $icon' "$BA/configs/fastfetch.jsonc" > "$BA/configs/fastfetch.jsonc.tmp" && mv "$BA/configs/fastfetch.jsonc.tmp" "$BA/configs/fastfetch.jsonc"
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   ✓ 部署完成！                        ║"
echo "║                                      ║"
echo "║   SUPER+W  → 角色选择器                ║"
echo "║   fastfetch → 带角色色的系统信息         ║"
echo "╚══════════════════════════════════════╝"
