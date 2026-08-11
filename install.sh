#!/bin/bash
#
# Bootstrap entry point: ensure Devbox, clone this repository, then run link.sh and packages.sh.
# 通常はリモートから `curl -fsSL ...install.sh | bash` で実行する想定。
# 既にローカルにdotfilesがあるなら ./link.sh と ./packages.sh を直接実行してもよい。
#

set -eu -o pipefail

DEBUG="${DEBUG:-}"
if [ "$DEBUG" = "true" ]; then
    set -x
fi

DOTFILES_REPO="https://github.com/yuga-t/dotfiles.git"
DEVBOX_GLOBAL_URL="https://raw.githubusercontent.com/yuga-t/dotfiles/main/devbox-global.json"
DOTFILES_DIR="$HOME/dotfiles"

if type sudo >/dev/null 2>&1 && [ "$(whoami)" != "root" ]; then
    SUDO="sudo"
else
    SUDO=""
fi

if [ ! -f /etc/debian_version ]; then
    echo "[ERROR] This script only supports Debian based Linux"
    exit 1
fi

echo "[INFO] Debian based Linux detected"

if [ "$(whoami)" != "root" ] && [ -z "$SUDO" ]; then
    echo "[ERROR] This script needs root or sudo for apt operations"
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "[INFO] Installing curl"
    $SUDO apt update
    $SUDO apt install -y curl
fi

if ! command -v devbox >/dev/null 2>&1; then
    echo "[INFO] Installing Devbox"
    curl -fsSL https://get.jetify.com/devbox | bash
fi

export PATH="$HOME/.local/bin:$PATH"

# Pull the global manifest before cloning so git itself comes from Devbox.
devbox global pull "$DEVBOX_GLOBAL_URL"
eval "$(devbox global shellenv)"

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    if ! git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "[ERROR] $DOTFILES_DIR exists but is not a Git repository"
        exit 1
    fi
    git -C "$DOTFILES_DIR" pull
fi

echo "[INFO] Repository ready at $DOTFILES_DIR"

bash "$DOTFILES_DIR/link.sh"
bash "$DOTFILES_DIR/packages.sh"

echo "[INFO] Installation finished"
