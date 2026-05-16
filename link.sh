#!/bin/bash
#
# Link dotfiles from this repository to $HOME.
# 既存ファイルがあればタイムスタンプ付きでバックアップ。
#
# 例外: VSCode の settings.json / keybindings.json はシンボリックリンクせず、
# ~/.vscode-{settings,keybindings}.local.json をディープマージして実ファイルとして書き出す。
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
VSCODE_SETTINGS_LOCAL="$HOME/.vscode-settings.local.json"
VSCODE_KEYBINDS_LOCAL="$HOME/.vscode-keybindings.local.json"

backup_if_exists() {
    local path="$1"
    if [ -e "$path" ] || [ -L "$path" ]; then
        mv "$path" "${path}.bak-$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        echo "[INFO] Backed up $path"
    fi
}

merge_vscode() {
    local mode="$1"          # settings or keybinds
    local base_rel="$2"
    local local_path="$3"
    local out_path="$HOME/${base_rel#*/}"

    backup_if_exists "$out_path"
    mkdir -p "$(dirname "$out_path")"
    python3 "$SCRIPT_DIR/scripts/merge-vscode.py" \
        "$mode" \
        "$SCRIPT_DIR/$base_rel" \
        "$local_path" \
        "$out_path"
    echo "[INFO] Merged $out_path (base=$base_rel, local=$local_path)"
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

    backup_if_exists "$link_name"

    link_target_fullpath="$SCRIPT_DIR/$link_target"
    mkdir -p "$(dirname "$link_name")"
    ln -sf "$link_target_fullpath" "$link_name"
    echo "[INFO] Linked $link_target_fullpath to $link_name"
done

# VSCode マージ
if ! type python3 >/dev/null 2>&1; then
    echo "[WARN] python3 not found; skipping VSCode settings merge"
else
    merge_vscode settings "$VSCODE_SETTINGS_REL" "$VSCODE_SETTINGS_LOCAL"
    merge_vscode keybinds "$VSCODE_KEYBINDS_REL" "$VSCODE_KEYBINDS_LOCAL"
fi

echo "[INFO] Link finished"
