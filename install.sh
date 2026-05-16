#!/bin/bash
#
# Bootstrap entry point: ensure git, clone this repository, then run link.sh and packages.sh.
# 通常はリモートから `curl -fsSL ...install.sh | bash` で実行する想定。
# 既にローカルにdotfilesがあるなら ./link.sh と ./packages.sh を直接実行してもよい。
#

set -eu -o pipefail

DEBUG="${DEBUG:-}"
if [ "$DEBUG" = "true" ]; then
    set -x
fi

DOTFILES_REPO="https://github.com/yuga-t/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

type sudo >/dev/null 2>&1 && [ "$(whoami)" != "root" ] && SUDO="sudo" || SUDO=""

if [ ! -f /etc/debian_version ]; then
    echo "[ERROR] This script only supports Debian based Linux"
    exit 1
fi

echo "[INFO] Debian based Linux detected"
$SUDO apt update
$SUDO apt install -y git python3

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    git -C "$DOTFILES_DIR" pull
fi

echo "[INFO] Repository ready at $DOTFILES_DIR"

bash "$DOTFILES_DIR/link.sh"
bash "$DOTFILES_DIR/packages.sh"

echo "[INFO] Installation finished"
