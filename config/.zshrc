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

# brightness

detect_monitors() {
  ddcutil detect --terse | grep Monitor: | sed -e 's/.*:.*:.*://'
}

# usage: setvcp_all <new-value>
setvcp_all() {
  local monitor_serials=($(detect_monitors))
  for serial_num in $monitor_serials; do
    ddcutil --sn $serial_num setvcp 10 $1
  done
}

setvcp_up_all() {
    local monitor_serials=($(detect_monitors))
  for serial_num in $monitor_serials; do
    ddcutil --sn $serial_num setvcp 10 + 7
  done
}

setvcp_down_all() {
    local monitor_serials=($(detect_monitors))
  for serial_num in $monitor_serials; do
    ddcutil --sn $serial_num setvcp 10 - 7
  done
}

if has "ddcutil"; then
  alias bup="setvcp_up_all"
  alias bdown="setvcp_down_all"
  alias bmax="setvcp_all 100"
  alias bmed="setvcp_all 50"
  alias bmin="setvcp_all 0"
else
    echo "ddcutil NOT exist!"
fi

# night light
alias nighton="gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true && gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3306"
alias nightoff="gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false"

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
# cursor
#
if [ -f ~/Applications/cursor.AppImage ]; then
    alias cursor='~/Applications/cursor.AppImage --no-sandbox'
else
    echo "~/Applications/cursor.AppImage NOT exist!"
fi

#
# sheldon
#

eval "$(sheldon source)"
