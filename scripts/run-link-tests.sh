#!/bin/bash
#
# link.sh の挙動を検証する。Dockerfile.test 内のコンテナで実行される想定。
# ホストで直接実行すると既存の dotfiles を書き換える可能性があるので、
# 通常は ./test.sh から呼ぶこと。
#
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
expect_symlink .gitconfig
expect_symlink .config/ghostty/config.ghostty
expect_symlink .config/fcitx5/config
expect_symlink .config/fcitx5/profile
expect_symlink .config/fcitx5/conf/mozc.conf
expect_symlink .config/sheldon/plugins.toml
expect_symlink .config/starship.toml
expect_symlink .config/user-dirs.dirs
expect_symlink .config/environment.d/envs.conf

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
echo '=== Idempotency: link.sh second run produces no new .bak files ==='
bak_before=$(find "$HOME" -maxdepth 4 -name '*.bak-*' 2>/dev/null | wc -l)
bash "$DOTFILES_DIR/link.sh" > /tmp/link_second_run.log 2>&1 || true
bak_after=$(find "$HOME" -maxdepth 4 -name '*.bak-*' 2>/dev/null | wc -l)
assert_eq 'no new backup files on re-run' "$bak_after" "$bak_before"
if grep -q '\[BAK \]' /tmp/link_second_run.log; then
    ng 're-run created backups: '"$(grep -c '\[BAK \]' /tmp/link_second_run.log)"' lines'
else
    ok 're-run did not create any backups'
fi
if grep -q '\[SKIP\]' /tmp/link_second_run.log; then
    ok 're-run logged SKIP for unchanged files'
else
    ng 're-run did not log SKIP'
fi

echo
echo '=== Idempotency: change content -> only the changed file is backed up ==='
# zshrc.local を更新（symlinkのターゲット変更ではないので、symlinkは触らない）
# 代わりに、外から ~/.zshrc を別物に上書きするケースをシミュレート
rm -f "$HOME/.zshrc"
echo '# stale content' > "$HOME/.zshrc"
bak_before=$(find "$HOME" -maxdepth 4 -name '*.bak-*' 2>/dev/null | wc -l)
bash "$DOTFILES_DIR/link.sh" > /tmp/link_third_run.log 2>&1
bak_after=$(find "$HOME" -maxdepth 4 -name '*.bak-*' 2>/dev/null | wc -l)
diff=$((bak_after - bak_before))
assert_eq 'exactly 1 new backup when 1 file is stale' "$diff" '1'
[ -L "$HOME/.zshrc" ] && ok '.zshrc restored as symlink' || ng '.zshrc not restored'

echo
echo "=== Result: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
