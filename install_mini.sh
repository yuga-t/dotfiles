#!/bin/bash

set -eu -o pipefail

DEBUG="${DEBUG:-}"
if [ "$DEBUG" = "true" ]; then
    set -x
fi

DOTFILES_REPO="https://github.com/yuga-t/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

#
# Setup
#

type sudo 2>&1 >/dev/null && [ "$(whoami)" != "root" ] && SUDO="sudo" || SUDO=""

if [ -f /etc/arch-release ]; then
    echo "[INFO] Arch Linux detected"
    $SUDO pacman -Syu
    $SUDO pacman -S --noconfirm git
elif [ -f /etc/debian_version ]; then
    echo "[INFO] Debian based Linux detected"
    $SUDO apt update
    $SUDO apt install -y git
else
    echo "[ERROR] This script only supports Arch Linux and Debian based Linux"
    exit 1
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    git -C "$DOTFILES_DIR" pull
fi

echo "[INFO] Cloned dotfiles repository"

#
# Link dotfiles
#

cd "$DOTFILES_DIR"
config_files=$(find config_mini -type f)

for link_target in $config_files; do

    link_target_trimmed=${link_target#*/} # 先頭のパス config_mini を削除
    link_name="$HOME/$link_target_trimmed" # リンク先のパス

    # もしファイルが存在していればバックアップを取る
    if [ -e "$link_name" ] || [ -L "$link_name" ]; then
        mv "$link_name" "$link_name".bak-$(echo $(date '+%Y-%m-%dT%H:%M:%S' --utc)Z)
        echo "[INFO] Backed up $link_name"

        rm -f "$link_name"
    fi

    link_target_fullpath="$DOTFILES_DIR/$link_target"

    mkdir -p "$(dirname "$link_name")"
    ln -sf "$link_target_fullpath" "$link_name"
    echo "[INFO] Linked $link_target_fullpath to $link_name"
done

#
# Install packages
#

if [ -f /etc/arch-release ]; then

    # install yay
    $SUDO pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay-bin.git "$HOME/git/yay-bin" && \
        cd "$HOME/git/yay-bin" && \
        makepkg -si --noconfirm && \
        cd "$HOME"

    yay -S --noconfirm \
        zsh \
        sheldon \
        starship \
        vim \
        vim-plug \
        tmux \
        fzf \
        ripgrep \
        eza \
        bat \
        xsel \
        git-delta \
        ctags \
        shellcheck \
        unzip

elif [ -f /etc/debian_version ]; then

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
        unzip

    # sheldon
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

    # starship
    curl -sS https://starship.rs/install.sh | sh

    # vim-plug
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# tmux plugin manager
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# nvm
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

# atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

#
# Finish
#

echo "[INFO] Installation finished"
