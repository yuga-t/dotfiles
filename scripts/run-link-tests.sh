#!/bin/bash
#
# link.sh の挙動を検証する。Dockerfile.test 内のコンテナで実行される想定。
# ホストで直接実行すると既存の dotfiles を書き換える可能性があるので、
# 通常は ./test.sh から呼ぶこと。
#
# shellcheck disable=SC2015  # A && B || C パターン: B(=ok) は常に0返すので安全

set -eu -o pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PASS=0
FAIL=0

ok() { printf '  \033[32mOK\033[0m  %s\n' "$*"; PASS=$((PASS+1)); return 0; }
ng() { printf '  \033[31mNG\033[0m  %s\n' "$*"; FAIL=$((FAIL+1)); return 0; }

assert_eq() {
    local label="$1"
    local got="$2"
    local want="$3"
    [ "$got" = "$want" ] && ok "$label (=$got)" || ng "$label (got '$got', want '$want')"
}

cd "$DOTFILES_DIR"

echo '=== Run link.sh ==='
bash ./link.sh

echo
echo '=== Verify symlinks ==='
expect_symlink() {
    local path="$1"
    if [ -L "$HOME/$path" ]; then
        ok "$path -> $(readlink "$HOME/$path")"
    else
        ng "$path (not a symlink)"
    fi
}

expect_symlink .zshrc
expect_symlink .zshenv
expect_symlink .vimrc
expect_symlink .tmux.conf
expect_symlink .gitconfig
expect_symlink .config/ghostty/config.ghostty
expect_symlink .config/fcitx5/config
expect_symlink .config/fcitx5/profile
expect_symlink .config/fcitx5/conf/mozc.conf
expect_symlink .config/sheldon/plugins.toml
expect_symlink .config/starship.toml
expect_symlink .config/user-dirs.dirs
expect_symlink environment.d/envs.conf

echo
echo '=== Verify VSCode files are merged (not symlinks) ==='
for p in .config/Code/User/settings.json .config/Code/User/keybindings.json; do
    if [ -L "$HOME/$p" ]; then
        ng "$p (should be a real file, but is symlink)"
    elif [ -f "$HOME/$p" ]; then
        ok "$p (generated file)"
    else
        ng "$p (missing)"
    fi
done

echo
echo '=== zsh syntax ==='
if zsh -n "$HOME/.zshenv"; then ok '.zshenv parses'; else ng '.zshenv parse error'; fi
if zsh -n "$HOME/.zshrc";  then ok '.zshrc parses';  else ng '.zshrc parse error';  fi

echo
echo '=== Local override: .zshrc.local ==='
rm -f /tmp/zshrc_marker
cat > "$HOME/.zshrc.local" <<'EOF'
export TEST_LOCAL=overridden
echo "$TEST_LOCAL" > /tmp/zshrc_marker
EOF
zsh -c 'source $HOME/.zshrc' >/dev/null 2>&1 || true
assert_eq '.zshrc.local picked up' "$(cat /tmp/zshrc_marker 2>/dev/null || true)" 'overridden'

echo
echo '=== Local override: .gitconfig.local ==='
printf '[user]\n  name = override-user\n' > "$HOME/.gitconfig.local"
assert_eq '.gitconfig.local picked up' "$(git config user.name)" 'override-user'

echo
echo '=== Local override: .tmux.conf.local ==='
echo 'set -g @custom_marker localok' > "$HOME/.tmux.conf.local"
mkdir -p "$HOME/.tmux/plugins/tpm"
printf '#!/bin/sh\nexit 0\n' > "$HOME/.tmux/plugins/tpm/tpm"
chmod +x "$HOME/.tmux/plugins/tpm/tpm"
marker=$(tmux -L "test_$$" -f "$HOME/.tmux.conf" new-session -d 'sleep 5' \; show-options -g -v @custom_marker 2>&1 || true)
tmux -L "test_$$" kill-server 2>/dev/null || true
assert_eq '.tmux.conf.local picked up' "$marker" 'localok'

echo
echo '=== Local override: .vimrc.local ==='
echo 'call writefile(["loaded"], "/tmp/vim_marker")' > "$HOME/.vimrc.local"
rm -f /tmp/vim_marker
vim -u "$HOME/.vimrc.local" -c 'qall!' -e -s >/dev/null 2>&1 || true
if [ -f /tmp/vim_marker ]; then
    assert_eq '.vimrc.local sourceable' "$(cat /tmp/vim_marker)" 'loaded'
else
    ng '.vimrc.local not loaded'
fi
if grep -q 'source ~/.vimrc.local' "$HOME/.vimrc"; then
    ok '.vimrc has source ~/.vimrc.local block'
else
    ng '.vimrc missing local override block'
fi

echo
echo '=== VSCode merge: settings.json ==='
cat > "$HOME/.vscode-settings.local.json" <<'JSON'
{
  "editor.fontSize": 99,
  "workbench.colorCustomizations": {
    "statusBar.background": "#ff0000"
  }
}
JSON
bash "$DOTFILES_DIR/link.sh" > /dev/null
read_json() {
    python3 -c "import json,sys;d=json.load(open('$HOME/.config/Code/User/settings.json'));print($1)"
}
assert_eq 'settings local key applied'             "$(read_json 'd["editor.fontSize"]')" '99'
assert_eq 'settings nested override'               "$(read_json 'd["workbench.colorCustomizations"]["statusBar.background"]')" '#ff0000'
assert_eq 'settings nested untouched key kept'     "$(read_json 'd["workbench.colorCustomizations"]["statusBar.foreground"]')" '#ffffff'

echo
echo '=== VSCode merge: keybindings.json (concat) ==='
cat > "$HOME/.vscode-keybindings.local.json" <<'JSON'
[
  { "key": "ctrl+shift+x", "command": "marker.local" }
]
JSON
bash "$DOTFILES_DIR/link.sh" > /dev/null
found=$(python3 -c "
import json
bindings = json.load(open('$HOME/.config/Code/User/keybindings.json'))
print('yes' if any(b.get('command') == 'marker.local' for b in bindings) else 'no')
")
assert_eq 'keybindings local entry appended' "$found" 'yes'

echo
echo "=== Result: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
