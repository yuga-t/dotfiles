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

has() {
  type "$1" > /dev/null 2>&1
}

#
# alias
#

# brightness / contrast (DDC VCP code: 10=luminance, 12=contrast)

detect_monitors() {
  ddcutil detect --terse | grep Monitor: | sed -e 's/.*:.*:.*://'
}

# usage: setvcp_all <vcp-code> <value>
setvcp_all() {
  local vcp=$1 value=$2
  local monitor_serials=($(detect_monitors))
  for serial_num in $monitor_serials; do
    ddcutil --sn $serial_num setvcp $vcp $value
  done
}

# usage: setvcp_step_all <vcp-code> <+|-> <step>
setvcp_step_all() {
  local vcp=$1 sign=$2 step=$3
  local monitor_serials=($(detect_monitors))
  for serial_num in $monitor_serials; do
    ddcutil --sn $serial_num setvcp $vcp $sign $step
  done
}

if has "ddcutil"; then
  # brightness
  alias bup="setvcp_step_all 10 + 7"
  alias bdown="setvcp_step_all 10 - 7"
  alias bmax="setvcp_all 10 100"
  alias bmed="setvcp_all 10 50"
  alias bmin="setvcp_all 10 0"
  # contrast
  alias cup="setvcp_step_all 12 + 7"
  alias cdown="setvcp_step_all 12 - 7"
  alias cmax="setvcp_all 12 100"
  alias cmed="setvcp_all 12 50"
  alias cmin="setvcp_all 12 0"
fi

# night light
alias nighton="gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true && gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3306"
alias nightoff="gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false"

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
