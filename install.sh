#!/bin/bash
#
# Bootstrap entry point: ensure git, clone this repository, then run link.sh and packages.sh.
# 通常はリモートから `curl -fsSL ...install.sh | bash` で実行する想定。
# 既にローカルにdotfilesがあるなら ./link.sh と ./packages.sh を直接実行してもよい。
#

set -eu -o pipefail

if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/yuga-t/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

die() {
    echo "[ERROR] $*" >&2
    exit 1
}

setup_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        die "This script needs root or sudo for apt operations"
    fi
}

install_git() {
    if ! command -v git >/dev/null 2>&1; then
        $SUDO apt-get update
        $SUDO apt-get install -y git
    fi
}

prepare_repository() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        return
    fi

    git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
        || die "$DOTFILES_DIR exists but is not a Git repository"

    if [ "${SKIP_GIT_PULL:-false}" = "true" ]; then
        echo "[INFO] Skipping Git pull"
    else
        git -C "$DOTFILES_DIR" pull
    fi
}

main() {
    [ -f /etc/debian_version ] || die "This script only supports Debian based Linux"
    setup_sudo
    echo "[INFO] Debian based Linux detected"
    install_git
    prepare_repository
    echo "[INFO] Repository ready at $DOTFILES_DIR"

    bash "$DOTFILES_DIR/link.sh"
    bash "$DOTFILES_DIR/packages.sh"

    echo "[INFO] Installation finished"
}

main "$@"
