#!/bin/bash
#
# Link dotfiles from this repository to $HOME.
# Idempotent: 既に正しいシンボリックリンクなら何もしない。
# 変化があるときだけ既存ファイルを .bak-TIMESTAMP として退避してから更新する。
#

set -eu -o pipefail

DEBUG="${DEBUG:-}"
if [ "$DEBUG" = "true" ]; then
    set -x
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "[ERROR] config directory not found: $CONFIG_DIR"
    exit 1
fi

backup_path() {
    # ナノ秒まで含めて、同一秒内の連続バックアップでも衝突しないように
    echo "${1}.bak-$(date -u '+%Y-%m-%dT%H:%M:%S.%NZ')"
}

ensure_symlink() {
    local source="$1"
    local target="$2"

    # 既に正しいリンクならスキップ
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo "[SKIP] $target (already linked)"
        return
    fi

    mkdir -p "$(dirname "$target")"

    # 既存があるなら退避（シンボリックリンクで別の所を指してる場合も含む）
    if [ -e "$target" ] || [ -L "$target" ]; then
        local bak
        bak="$(backup_path "$target")"
        mv "$target" "$bak"
        echo "[BAK ] $target -> $bak"
    fi

    ln -s "$source" "$target"
    echo "[LINK] $target -> $source"
}

cd "$SCRIPT_DIR"
config_files=$(find config -type f)

for link_target in $config_files; do
    link_target_trimmed=${link_target#*/}  # 先頭の "config" を削除
    link_name="$HOME/$link_target_trimmed"
    ensure_symlink "$SCRIPT_DIR/$link_target" "$link_name"
done

echo "[INFO] Link finished"
