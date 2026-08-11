#!/bin/bash
#
# Install packages.
# Debian based Linux only.
#
# 二度目以降の実行も安全: バイナリが既に存在するならその手順をスキップする。
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

mkdir -p "$HOME/.local/bin"

has() { command -v "$1" >/dev/null 2>&1; }

#
# apt packages
#

$SUDO apt update

$SUDO apt install -y \
    zsh \
    vim \
    fzf \
    ripgrep \
    eza \
    bat \
    xsel \
    wl-clipboard \
    git-delta \
    universal-ctags \
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
    fd-find \
    imagemagick

# link bat to batcat (Debianでは名前が異なる)
ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

# link fd to fdfind
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"

#
# sheldon (zsh plugin manager)
#

if ! has sheldon; then
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"
else
    echo "[SKIP] sheldon already installed"
fi

#
# starship (prompt)
#

if ! has starship; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "[SKIP] starship already installed"
fi

#
# vim-plug
#

if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "[SKIP] vim-plug already installed"
fi

#
# yazi (latest release from GitHub)
#

if ! has yazi; then
    yazi_tag=$(curl -fsSL https://api.github.com/repos/sxyazi/yazi/releases/latest | jq -r .tag_name)
    yazi_tmp=$(mktemp -d)
    curl -fsSL -o "$yazi_tmp/yazi.zip" \
        "https://github.com/sxyazi/yazi/releases/download/${yazi_tag}/yazi-x86_64-unknown-linux-gnu.zip"
    unzip -q "$yazi_tmp/yazi.zip" -d "$yazi_tmp"
    install -m 0755 "$yazi_tmp"/yazi-x86_64-unknown-linux-gnu/ya   "$HOME/.local/bin/ya"
    install -m 0755 "$yazi_tmp"/yazi-x86_64-unknown-linux-gnu/yazi "$HOME/.local/bin/yazi"
    rm -rf "$yazi_tmp"
    echo "[INFO] yazi $yazi_tag installed"
else
    echo "[SKIP] yazi already installed ($(yazi --version | head -1))"
fi

#
#
# herdr (terminal workspace manager)
#

if ! has herdr; then
    curl -fsSL https://herdr.dev/install.sh | sh
else
    echo "[SKIP] herdr already installed"
fi

#
# hunk (interactive diff viewer)
#

if ! has hunk; then
    hunk_tag=$(curl -fsSL https://api.github.com/repos/modem-dev/hunk/releases/latest | jq -r .tag_name)
    hunk_tmp=$(mktemp -d)
    curl -fsSL -o "$hunk_tmp/hunk.tar.gz" \
        "https://github.com/modem-dev/hunk/releases/download/${hunk_tag}/hunkdiff-linux-x64.tar.gz"
    tar -xzf "$hunk_tmp/hunk.tar.gz" -C "$hunk_tmp"
    install -m 0755 "$hunk_tmp/hunkdiff-linux-x64/hunk" "$HOME/.local/bin/hunk"
    rm -rf "$hunk_tmp"
    echo "[INFO] hunk $hunk_tag installed"
else
    echo "[SKIP] hunk already installed"
fi

#
# atuin (shell history)
#

if ! has atuin; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
else
    echo "[SKIP] atuin already installed"
fi

#
# Cica fonts
#

if [ ! -d /usr/local/share/fonts/Cica ]; then
    cica_tmp=$(mktemp -d)
    curl -fsSL -o "$cica_tmp/Cica.zip" \
        https://github.com/miiton/Cica/releases/download/v5.0.3/Cica_v5.0.3.zip
    unzip -q "$cica_tmp/Cica.zip" -d "$cica_tmp"
    $SUDO mkdir -p /usr/local/share/fonts/Cica
    $SUDO cp "$cica_tmp"/Cica-*.ttf /usr/local/share/fonts/Cica
    $SUDO fc-cache -fv
    rm -rf "$cica_tmp"
    echo "[INFO] Cica fonts installed"
else
    echo "[SKIP] Cica fonts already installed"
fi

echo "[INFO] Packages installed"
