function fastfetch --wraps=/usr/bin/fastfetch
    set -l config "$HOME/.config/character-theme/config.json"
    set -l char (jq -r '.current' $config 2>/dev/null)

    if test -n "$char" -a "$char" != "null"
        set -l color (jq -r ".characters.\"$char\".color" $config 2>/dev/null)
        if test -n "$color" -a "$color" != "null"
            /usr/bin/fastfetch --color-title $color --color-keys $color --color-separator $color $argv
            return
        end
    end

    /usr/bin/fastfetch $argv
end
