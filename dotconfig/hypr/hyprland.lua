-- Hyprland Config - Catppuccin Mocha

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@120.00Hz",
    position = "0x0",
    scale    = 1,
    vrr      = 2,
    bitdepth = 10,
})

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "rofi -show drun"

hl.on("hyprland.start", function()
    hl.exec_cmd("swww-daemon &")
    hl.exec_cmd("sleep 1 && swww img \"$HOME/.ba-rice/current_wallpaper.png\" --transition-type grow --transition-step 30 --transition-fps 60 --transition-duration 2")
    hl.exec_cmd("sudo scxctl start --sched bpfland")
    hl.exec_cmd("waybar &")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1 &")
    hl.exec_cmd("clash-party &")
    hl.exec_cmd("mako &")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("XCURSOR_THEME", "catppuccin-mocha-mauve-cursors")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in     = 6,
        gaps_out    = 12,
        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(cba6f7ee)", "rgba(89b4faee)" }, angle = 45 },
            inactive_border = "rgba(313244aa)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 3,

        active_opacity   = 1.0,
        inactive_opacity = 0.92,

        shadow = {
            enabled      = true,
            range        = 20,
            render_power = 3,
            color        = "rgba(1e1e2eee)",
        },

        blur = {
            enabled              = true,
            size                 = 6,
            passes               = 3,
            noise                = 0.02,
            contrast             = 1.1,
            brightness           = 0.8,
            vibrancy             = 0.2,
            vibrancy_darkness    = 0.5,
            popups               = true,
            popups_ignorealpha   = 0.2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo   = true,
    },

    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.curve("wind",     { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn",    { type = "bezier", points = { { 0.1, 1.1 },  { 0.1, 1.05 } } })
hl.curve("winOut",   { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("smooth",   { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.4, 0.8 },  { 0.2, 1.1 } } })
hl.curve("bounce",   { type = "bezier", points = { { 1, 1.6 },    { 0.1, 0.85 } } })
hl.curve("snappy",   { type = "bezier", points = { { 0.2, 0 },    { 0, 1 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4, bezier = "winIn",    style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "winOut",   style = "slide" })
hl.animation({ leaf = "windowsMove",enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "border",     enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "overshot", style = "slidevert" })

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + C", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + X", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 1"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 0"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -no-show-icons -theme-str \"element-text { horizontal-align: 0; }\" -theme-str \"prompt { enabled: false; }\" -theme-str \"entry { placeholder: \\\"搜索\\\"; }\" | cliphist decode | wl-copy"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("~/.local/bin/power-menu.fish"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind("CTRL + " .. mainMod .. " + up",   hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + " .. mainMod .. " + down", hl.dsp.focus({ workspace = "+1" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png && wl-copy < ~/Pictures/screenshots/$(ls -t ~/Pictures/screenshots | head -1)"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png && wl-copy < ~/Pictures/screenshots/$(ls -t ~/Pictures/screenshots | head -1)"))

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.layer_rule({
    name  = "waybar",
    match = { namespace = "waybar" },

    blur = true,
})

hl.layer_rule({
    name  = "rofi",
    match = { namespace = "rofi" },

    blur         = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name  = "mako",
    match = { namespace = "mako" },

    blur         = true,
    ignore_alpha = 0.2,
})

hl.source("~/.ba-rice/configs/hyprland-character.conf")
