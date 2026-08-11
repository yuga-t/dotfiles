#!/bin/bash
#
# Install Devbox and host-dependent packages.
# Debian based Linux only.
#

set -eu -o pipefail

if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

die() {
    echo "[ERROR] $*" >&2
    exit 1
}

require_debian() {
    [ -f /etc/debian_version ] || die "This script only supports Debian based Linux"
}

setup_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        die "This script needs root or sudo for apt and font installation"
    fi
}

apt_cmd() {
    $SUDO env DEBIAN_FRONTEND=noninteractive apt-get "$@"
}

ensure_curl() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "[INFO] Installing curl"
        apt_cmd update
        apt_cmd install -y curl
    fi
}

install_devbox_packages() {
    if [ "${SKIP_DEVBOX:-false}" = "true" ]; then
        echo "[INFO] Skipping Devbox installation"
        return
    fi

    if ! command -v devbox >/dev/null 2>&1; then
        echo "[INFO] Installing Devbox"
        curl -fsSL https://get.jetify.com/devbox | bash -s -- -f
    fi

    export PATH="$HOME/.local/bin:$PATH"
    local packages=(
        atuin bat delta eza fd ffmpeg ffmpegthumbnailer fzf git-lfs
        herdr hunk imagemagick jq p7zip poppler_utils python3 ripgrep
        sheldon starship universal-ctags unzip vim yazi zsh
    )
    devbox global add "${packages[@]}"
    eval "$(devbox global shellenv --preserve-path-stack -r)"
    hash -r
}

install_apt_packages() {
    local packages=(
        xsel wl-clipboard ddcutil fcitx5 fcitx5-mozc unzip fontconfig
    )
    apt_cmd update
    apt_cmd install -y "${packages[@]}"
}

install_vim_plug() {
    if [ -f "$HOME/.vim/autoload/plug.vim" ]; then
        echo "[SKIP] vim-plug already installed"
        return
    fi

    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_cica_fonts() {
    local cica_dir=/usr/local/share/fonts/Cica
    local cica_marker="$cica_dir/.installed"

    if [ -f "$cica_marker" ]; then
        echo "[SKIP] Cica fonts already installed"
        return
    fi

    local cica_tmp
    cica_tmp=$(mktemp -d)
    trap '[ -z "${cica_tmp:-}" ] || rm -rf "$cica_tmp"' EXIT
    curl -fsSL -o "$cica_tmp/Cica.zip" \
        https://github.com/miiton/Cica/releases/download/v5.0.3/Cica_v5.0.3.zip
    unzip -q "$cica_tmp/Cica.zip" -d "$cica_tmp"
    $SUDO mkdir -p "$cica_dir"
    $SUDO cp "$cica_tmp"/Cica-*.ttf "$cica_dir"
    $SUDO fc-cache -fv
    $SUDO touch "$cica_marker"
    rm -rf "$cica_tmp"
    cica_tmp=""
    echo "[INFO] Cica fonts installed"
}

main() {
    require_debian
    setup_sudo
    ensure_curl
    mkdir -p "$HOME/.local/bin"
    install_devbox_packages
    install_apt_packages
    install_vim_plug
    install_cica_fonts
    echo "[INFO] Packages installed"
}

main "$@"
