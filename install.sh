#!/bin/bash

set -eux -o pipefail

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

if [ ! -d $DOTFILES_DIR ]; then
    git clone $DOTFILES_REPO $DOTFILES_DIR
else
    git -C $DOTFILES_DIR pull
fi

echo "[INFO] Cloned dotfiles repository"

#
# Link dotfiles
#

cd $DOTFILES_DIR
config_files=$(find config -type f)

for link_target in $config_files; do

    link_target_trimmed=${link_target#*/} # 最初のパスを削除
    link_name="$HOME/$link_target_trimmed" # リンク先のパス

    # もしファイルが存在していればバックアップを取る
    if [ -e $link_name ] || [ -L $link_name ]; then
        mv $link_name $link_name.bak-$(echo $(date '+%Y-%m-%dT%H:%M:%S' --utc)Z)
        echo "[INFO] Backed up $link_name"

        rm -f $link_name
    fi

    mkdir -p $(dirname $link_name)
    ln -sf $link_target $link_name
    echo "[INFO] Linked $link_target to $link_name"
done

#
# Set etc files
#

cp etc/environment /etc/environment

#
# Install packages: TODO
#

if [ -f /etc/arch-release ]; then
elif [ -f /etc/debian_version ]; then
fi

#
# Finish
#

echo "[INFO] Installation finished"
