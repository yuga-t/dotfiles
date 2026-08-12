#!/bin/bash
#
# Install Devbox and host-dependent packages.
# Debian based Linux only.
#
# Env vars:
#   SKIP_DEVBOX=true  Skip Devbox installation
#   HEADLESS=true     Skip display-dependent packages (clipboard, DDC, IME) and font install
#   DEBUG=true        Enable shell tracing
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
        atuin bat clang-tools delta eza fd ffmpeg ffmpegthumbnailer fzf
        git-lfs gopls herdr hunk imagemagick jq neovim p7zip poppler_utils
        pyright ripgrep sheldon starship taplo typescript-language-server
        universal-ctags unzip vscode-langservers-extracted
        yaml-language-server yazi
    )
    devbox global add "${packages[@]}"
    eval "$(devbox global shellenv --preserve-path-stack -r)"
    hash -r
}

install_apt_packages() {
    local packages=(fontconfig unzip zsh)

    if [ "${HEADLESS:-false}" != "true" ]; then
        packages+=(xsel wl-clipboard ddcutil fcitx5 fcitx5-mozc)
    fi

    apt_cmd update
    apt_cmd install -y "${packages[@]}"
}

install_cica_fonts() {
    if [ "${HEADLESS:-false}" = "true" ]; then
        echo "[SKIP] Cica fonts (HEADLESS=true)"
        return
    fi

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
    install_cica_fonts
    echo "[INFO] Packages installed"
}

main "$@"
