# BA-Rice

基于 Blue Archive 角色的 Hyprland 桌面主题系统。一键切换角色，自动更新壁纸、头像、系统信息颜色。

## 项目结构

```
.
├── characters/          # 角色图片资源
├── configs/
│   ├── fastfetch.fish   # fish shell 快速 fetch 包装器
│   ├── fastfetch.jsonc  # fastfetch 配置
│   ├── hyprlock.conf    # 锁屏配置
│   └── hyprland-character.conf
├── scripts/
│   ├── cpu.sh           # CPU 信息获取
│   ├── extract-color.sh # 颜色提取工具
│   ├── gpu.sh           # GPU 信息获取
│   └── select.sh        # 角色选择器
├── config.json          # 当前角色配置
├── current_avatar.png   # 当前角色头像
├── current_wallpaper.png # 当前角色壁纸
└── deploy.sh            # 部署脚本
```

## 快速部署

1. 克隆仓库：

```
git clone https://github.com/your-username/ba-rice.git ~/.ba-rice
```

2. 运行部署脚本：

```
cd ~/.ba-rice && ./deploy.sh
```

3. 重启 Hyprland 或注销重新登录使配置生效。

## 使用方法

按 `SUPER+W` 打开角色选择器，使用 rofi 五列网格界面选择角色。

切换角色时，系统会并行执行：
- 更新壁纸（swww）
- 更新头像（hyprlock + SDDM）
- 更新 fastfetch 图标和颜色主题

## 添加角色

1. 将角色图片放入 `characters/` 目录
2. 在 `config.json` 中添加角色名称
3. 重新部署或重启相关服务

## 符号链接

部署脚本会创建以下符号链接：

| 源路径 | 目标路径 |
|--------|----------|
| `$HOME/.config/fastfetch/config.jsonc` | `$HOME/.ba-rice/configs/fastfetch.jsonc` |
| `$HOME/.config/fastfetch/cpu.sh` | `$HOME/.ba-rice/scripts/cpu.sh` |
| `$HOME/.config/fastfetch/gpu.sh` | `$HOME/.ba-rice/scripts/gpu.sh` |
| `$HOME/.config/fish/conf.d/fastfetch.fish` | `$HOME/.ba-rice/configs/fastfetch.fish` (仅 fish) |
| `$HOME/.config/hypr/hyprlock.conf` | `$HOME/.ba-rice/configs/hyprlock.conf` |
| `$HOME/.config/character-theme` | `$HOME/.ba-rice` |
| `$HOME/.face` + `$HOME/.face.icon` | `$HOME/.ba-rice/current_avatar.png` |
| `$HOME/Pictures/character` | `$HOME/.ba-rice/characters` |

## 快捷键

| 快捷键 | 功能 |
|--------|------|
| `SUPER+W` | 打开角色选择器 |

## 依赖

**必需：**
- jq
- rofi
- swww
- fastfetch
- hyprlock
- imagemagick

**可选：**
- fish（用于 fastfetch 颜色传递包装器）

## 角色列表

当前支持 28 个 Blue Archive 角色：

ako, arisu_maid, azusa_swimsuit, hanako_swimsuit, hifumi_swimsuit, hina_dress, hoshino, hoshino_battle, hoshino_swimsuit, izuna, kayoko_dress, kisaki, koharu, kokona, mari_idol, midori_maid, mika, misaki, momoi_maid, natsu, noa, rio, shiroko, shiroko_terror, shun_kid, toki, yuuka_pajama, yuuka_sportswear

## 说明

- 所有路径使用 `$HOME`，无硬编码用户名
- 颜色自动映射到 Catppuccin Mocha 主题
- hyprlock 使用 Catppuccin 主题配合角色壁纸背景
- fastfetch 显示角色颜色的系统信息
- 兼容 bash/zsh/fish 等多种 shell