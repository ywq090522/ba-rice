# BA Character Theme System

Blue Archive 角色主题一键切换系统。选择角色后同时更新：壁纸、hyprlock 头像、SDDM 头像、fastfetch 图标+颜色。

## 快速部署

```bash
# 1. 克隆
git clone <repo_url> ~/.ba-rice

# 2. 解压图片（从 tar 包）
tar xzf ba-rice-images.tar.gz -C ~/.ba-rice/

# 3. 运行部署脚本
bash ~/.ba-rice/deploy.sh
```

或直接用部署脚本一步到位：
```bash
bash deploy.sh <repo_url> <image_tar_path>
```

## 目录结构

```
~/.ba-rice/
├── config.json              # 角色配置（名称、颜色、路径）
├── characters/              # 角色图片（wallpaper/avatar/icon）
├── scripts/
│   ├── select.sh            # rofi 角色选择器
│   └── extract-color.sh     # 头像主色提取 → Catppuccin Mocha
├── configs/
│   ├── fastfetch.jsonc      # fastfetch 配置
│   ├── fastfetch.fish       # fish wrapper（自动传角色色）
│   ├── hyprlock.conf        # hyprlock 配置
│   └── hyprland-character.conf  # 角色相关 keybind
└── deploy.sh                # 部署脚本
```

## 快捷键

| 按键 | 功能 |
|------|------|
| `SUPER+W` | 角色选择器（rofi 网格） |

## 依赖

- `jq` `rofi` `swww` `fastfetch` `hyprlock` `imagemagick` `fish`

## 添加角色

1. 在 `characters/<name>/` 下放入：
   - `wallpaper.png` — 壁纸
   - `avatar.png` — 头像（用于 hyprlock + 颜色提取）
   - `icon.png` — 小图标（用于 rofi + fastfetch）
2. 在 `config.json` 的 `characters` 中添加条目
3. 运行 `scripts/extract-color.sh <name>` 提取主题色

## Catppuccin 主题色映射

提取的颜色自动映射到最近的 Catppuccin Mocha 颜色：
Rosewater / Flamingo / Pink / Mauve / Red / Maroon / Peach / Yellow / Green / Teal / Sky / Sapphire / Blue / Lavender
