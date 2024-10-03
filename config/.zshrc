#
# ohmyzsh
#

export ZSH="$HOME/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh"
export ZSH_THEME="" #プロンプトのカスタマイズは starship を使う

# ssh
zstyle :omz:plugins:ssh-agent identities ~/.ssh/github/id_ed25519

plugins=(ssh-agent ssh aws gcloud poetry fzf emoji docker colored-man-pages)

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
if has "ddcutil"; then
  alias bup="ddcutil setvcp 10 + 7"
  alias bdown="ddcutil setvcp 10 - 7"
  alias bmax="ddcutil setvcp 10 100"
  alias bmed="ddcutil setvcp 10 50"
  alias bmin="ddcutil setvcp 10 0"
else
    echo "ddcutil NOT exist!"
fi

# night light
alias nighton="gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3306"
alias nightoff="gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 6000"

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
# sheldon
#

eval "$(sheldon source)"
