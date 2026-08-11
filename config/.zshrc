#
# ohmyzsh
#

export ZSH="$HOME/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh"
export ZSH_THEME="" #プロンプトのカスタマイズは starship を使う

# ssh
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

#
# utility
#

# Devbox global packages
if command -v devbox >/dev/null 2>&1; then
  eval "$(devbox global shellenv --init-hook)"
fi

has() {
  type "$1" > /dev/null 2>&1
}

#
# alias
#

# copy to clipboard (Wayland優先、X11フォールバック)
if has "wl-copy"; then
    alias clip="wl-copy"
elif has "xsel"; then
    alias clip="xsel --clipboard --input"
fi

#
# others
#

# ビープ音を鳴らさない
setopt no_beep

#
# atuin
#

if [ -f "$HOME/.atuin/bin/env" ]; then
    . "$HOME/.atuin/bin/env"
fi
if has "atuin"; then
    eval "$(atuin init zsh)"
    if has "fzf"; then
        alias atuinfzf="atuin history list --cmd-only | fzf"
    fi
fi

#
# sheldon
#

eval "$(sheldon source)"

#
# local override
#

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
