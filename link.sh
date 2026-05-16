#!/bin/bash
#
# Link dotfiles from this repository to $HOME.
# Idempotent: 既に正しいシンボリックリンク/同じ内容のVSCode生成ファイルなら何もしない。
# 変化があるときだけ既存ファイルを .bak-TIMESTAMP として退避してから更新する。
#
# 例外: VSCode の settings.json / keybindings.json はシンボリックリンクせず、
# ~/.config/Code/User/{settings,keybindings}.local.json をディープマージして実ファイルとして書き出す。
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

VSCODE_SETTINGS_REL="config/.config/Code/User/settings.json"
VSCODE_KEYBINDS_REL="config/.config/Code/User/keybindings.json"
VSCODE_SETTINGS_LOCAL="$HOME/.config/Code/User/settings.local.json"
VSCODE_KEYBINDS_LOCAL="$HOME/.config/Code/User/keybindings.local.json"

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

ensure_vscode_merged() {
    local mode="$1"          # settings or keybinds
    local base_rel="$2"
    local local_path="$3"
    local out_path="$HOME/${base_rel#*/}"

    mkdir -p "$(dirname "$out_path")"

    local tmp
    tmp="$(mktemp)"
    python3 "$SCRIPT_DIR/scripts/merge-vscode.py" \
        "$mode" \
        "$SCRIPT_DIR/$base_rel" \
        "$local_path" \
        "$tmp"

    # 既存と同じならスキップ
    if [ -f "$out_path" ] && cmp -s "$tmp" "$out_path"; then
        rm -f "$tmp"
        echo "[SKIP] $out_path (already up-to-date)"
        return
    fi

    # 既存（古い内容 or シンボリックリンク）があるなら退避
    if [ -e "$out_path" ] || [ -L "$out_path" ]; then
        local bak
        bak="$(backup_path "$out_path")"
        mv "$out_path" "$bak"
        echo "[BAK ] $out_path -> $bak"
    fi

    mv "$tmp" "$out_path"
    echo "[MERGE] $out_path (base=$base_rel, local=$local_path)"
}

cd "$SCRIPT_DIR"
config_files=$(find config -type f)

for link_target in $config_files; do
    # VSCode 設定はマージ処理に回す
    case "$link_target" in
        "$VSCODE_SETTINGS_REL"|"$VSCODE_KEYBINDS_REL")
            continue
            ;;
    esac

    link_target_trimmed=${link_target#*/}  # 先頭の "config" を削除
    link_name="$HOME/$link_target_trimmed"
    ensure_symlink "$SCRIPT_DIR/$link_target" "$link_name"
done

if ! type python3 >/dev/null 2>&1; then
    echo "[WARN] python3 not found; skipping VSCode settings merge"
else
    ensure_vscode_merged settings "$VSCODE_SETTINGS_REL" "$VSCODE_SETTINGS_LOCAL"
    ensure_vscode_merged keybinds "$VSCODE_KEYBINDS_REL" "$VSCODE_KEYBINDS_LOCAL"
fi

echo "[INFO] Link finished"
