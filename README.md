# dotfiles

## Supported OS

- Debian based Linux

## Install

初回インストール（git/clone + dotfilesリンク + パッケージ）:

```bash
curl -fsSL https://raw.github.com/yuga-t/dotfiles/main/install.sh | bash
```

`install.sh` はブートストラップ専用。内部で以下を呼び出す。

- `link.sh` — `config/` 配下を `$HOME` にシンボリックリンク（既存ファイルはタイムスタンプ付きでバックアップ）
- `packages.sh` — apt/curl でパッケージインストール

各スクリプトは単独でも実行できる。設定ファイルの差分を反映したいだけなら `./link.sh` を再実行すればよい。

## Local override

ホスト固有の設定は git に上げず、以下のローカルファイルに書く（存在すれば自動的に読み込まれる）。

| 用途 | dotfile | ローカルオーバーライド |
|---|---|---|
| zsh env | `~/.zshenv` | `~/.zshenv.local` |
| zsh rc | `~/.zshrc` | `~/.zshrc.local` |
| tmux | `~/.tmux.conf` | `~/.tmux.conf.local` |
| vim | `~/.vimrc` | `~/.vimrc.local` |
| git | `~/.gitconfig` | `~/.gitconfig.local` |
| VSCode 設定 | `~/.config/Code/User/settings.json`(生成物) | `~/.vscode-settings.local.json` |
| VSCode キーバインド | `~/.config/Code/User/keybindings.json`(生成物) | `~/.vscode-keybindings.local.json` |

### VSCode について

VSCodeの `settings.json` / `keybindings.json` は**シンボリックリンクではなく実ファイル**として `link.sh` が生成する。

- ベース: `config/.config/Code/User/{settings,keybindings}.json`（git管理）
- ローカル: `~/.vscode-{settings,keybindings}.local.json`（git管理外）
- 生成物: `~/.config/Code/User/{settings,keybindings}.json`
- マージ規則:
  - settings: dictのディープマージ（ローカル優先）
  - keybindings: arrayのconcat（ローカルを末尾に追加。VSCodeは後勝ち）

VSCode上で設定を編集すると実ファイルへ反映されるが、**`./link.sh` を再実行すると上書きされる**（旧ファイルは`.bak-...`として残る）。コミットしたい変更は手動で `config/.config/Code/User/settings.json` に反映すること。

## Test

`link.sh` の動作と各種ローカルオーバーライドの仕組みを Docker で検証できる:

```bash
./test.sh
```

中身は `Dockerfile.test` をビルドして `scripts/run-link-tests.sh` をコンテナ内で走らせるだけ。ネットワーク経由のパッケージインストールはテストしない（あくまで `link.sh` とローカルオーバーライドの挙動を確認する用途）。

## Tips

### autostart fcitx5

```bash
mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart
```

ref: https://fcitx-im.org/wiki/Setup_Fcitx_5
