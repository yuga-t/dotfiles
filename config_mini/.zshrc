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
    aws
    gcloud
)

#
# utility
#

has() {
  type "$1" > /dev/null 2>&1
}

#
# alias
#

# copy to clipboard
if has "xsel"; then
    alias clip="xsel --clipboard --input"
else
    echo "xsel NOT exist!"
fi

# bat
if has "bat"; then
  alias cat="bat --paging=never"
  alias less="bat"
else
  echo "bat NOT exist!"
fi

#
# others
#

# ビープ音を鳴らさない
setopt no_beep

#
# atuin
#

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

if has "atuin" && has "fzf"; then
    alias atuinfzf="atuin history list --cmd-only | fzf"
else
    echo "atuin or fzf NOT exist!"
fi

#
# sheldon
#

eval "$(sheldon source)"
