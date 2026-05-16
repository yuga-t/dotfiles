#!/bin/bash
#
# Install packages.
# Debian based Linux only.
#

set -eu -o pipefail

DEBUG="${DEBUG:-}"
if [ "$DEBUG" = "true" ]; then
    set -x
fi

type sudo >/dev/null 2>&1 && [ "$(whoami)" != "root" ] && SUDO="sudo" || SUDO=""

if [ ! -f /etc/debian_version ]; then
    echo "[ERROR] This script only supports Debian based Linux"
    exit 1
fi

$SUDO apt update

$SUDO apt install -y \
    zsh \
    vim \
    tmux \
    fzf \
    ripgrep \
    eza \
    bat \
    xsel \
    git-delta \
    universal-ctags \
    shellcheck \
    ddcutil \
    fcitx5 \
    fcitx5-mozc \
    unzip \
    fontconfig \
    ffmpegthumbnailer \
    ffmpeg \
    p7zip \
    jq \
    poppler-utils \
    fd-find

mkdir -p "$HOME/.local/bin"

# link bat to batcat
ln -sf "$(which batcat)" "$HOME/.local/bin/bat"

# link fd to fdfind
ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"

# imagemagick
mkdir -p /tmp/imagemagick
curl -o /tmp/imagemagick/magick -L https://imagemagick.org/archive/binaries/magick
mv /tmp/imagemagick/magick "$HOME/.local/bin"
chmod +x "$HOME/.local/bin/magick"

# sheldon
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"

# starship
curl -sS https://starship.rs/install.sh | sh -s -- -y

# vim-plug
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# yazi
mkdir -p /tmp/yazi
curl -o /tmp/yazi/downloaded -L https://github.com/sxyazi/yazi/releases/download/v0.3.3/yazi-x86_64-unknown-linux-gnu.zip
unzip /tmp/yazi/downloaded -d /tmp/yazi/unzipped
mv /tmp/yazi/unzipped/yazi-x86_64-unknown-linux-gnu/ya "$HOME/.local/bin"
mv /tmp/yazi/unzipped/yazi-x86_64-unknown-linux-gnu/yazi "$HOME/.local/bin"

# tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# nvm
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

# atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# cica fonts
curl -L -o /tmp/Cica_v5.0.3.zip https://github.com/miiton/Cica/releases/download/v5.0.3/Cica_v5.0.3.zip
unzip /tmp/Cica_v5.0.3.zip -d /tmp/Cica_v5.0.3
$SUDO mkdir -p /usr/local/share/fonts/Cica
$SUDO cp /tmp/Cica_v5.0.3/Cica-*.ttf /usr/local/share/fonts/Cica
$SUDO fc-cache -fv

echo "[INFO] Packages installed"
