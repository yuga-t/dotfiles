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

if [ "$(whoami)" != "root" ] && [ -z "$SUDO" ]; then
    echo "[ERROR] This script needs root or sudo for apt and font installation"
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "[INFO] Installing curl"
    $SUDO apt update
    $SUDO apt install -y curl
fi

mkdir -p "$HOME/.local/bin"

has() { command -v "$1" >/dev/null 2>&1; }

#
# apt packages
#

$SUDO apt update

$SUDO apt install -y \
    xsel \
    wl-clipboard \
    ddcutil \
    fcitx5 \
    fcitx5-mozc \
    unzip \
    fontconfig

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
# Cica fonts
#

if [ ! -d /usr/local/share/fonts/Cica ]; then
    cica_tmp=$(mktemp -d)
    trap '[ -z "${cica_tmp:-}" ] || rm -rf "$cica_tmp"' EXIT
    curl -fsSL -o "$cica_tmp/Cica.zip" \
        https://github.com/miiton/Cica/releases/download/v5.0.3/Cica_v5.0.3.zip
    unzip -q "$cica_tmp/Cica.zip" -d "$cica_tmp"
    $SUDO mkdir -p /usr/local/share/fonts/Cica
    $SUDO cp "$cica_tmp"/Cica-*.ttf /usr/local/share/fonts/Cica
    $SUDO fc-cache -fv
    rm -rf "$cica_tmp"
    cica_tmp=""
    echo "[INFO] Cica fonts installed"
else
    echo "[SKIP] Cica fonts already installed"
fi

echo "[INFO] Packages installed"
