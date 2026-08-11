# Devbox global packages
if command -v devbox >/dev/null 2>&1 \
    && devbox global list >/dev/null 2>&1; then
    eval "$(devbox global shellenv)"
fi

# Oh My Zsh
export ZSH="$HOME/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh"
export ZSH_THEME=""

# Oh My Zsh plugins
zstyle :omz:plugins:ssh-agent identities ~/.ssh/github/id_ed25519
plugins=(
    aliases
    ssh
    ssh-agent
    git
    colored-man-pages
    fzf
    emoji
)

# Options
setopt no_beep

# Clipboard alias (Wayland preferred, X11 fallback)
if command -v wl-copy >/dev/null 2>&1; then
    alias clip="wl-copy"
elif command -v xsel >/dev/null 2>&1; then
    alias clip="xsel --clipboard --input"
fi

# Atuin
if [ -f "$HOME/.atuin/bin/env" ]; then
    . "$HOME/.atuin/bin/env"
fi
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
    if command -v fzf >/dev/null 2>&1; then
        alias atuinfzf="atuin history list --cmd-only | fzf"
    fi
fi

# Sheldon loads Oh My Zsh, plugins, and Starship.
if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
fi

# Local override
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
