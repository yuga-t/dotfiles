# dotfiles

## Supported OS

- Debian based Linux

## Install

初回インストール（git/clone + dotfilesリンク + パッケージ）:

```bash
curl -fsSL https://raw.github.com/yuga-t/dotfiles/main/install.sh | bash
```

`install.sh` はブートストラップ専用。内部で以下を呼び出す。

- `link.sh` — `config/` 配下を `$HOME` にシンボリックリンク（VSCode 設定だけは実ファイルとしてマージ生成）
- `packages.sh` — apt/curl でパッケージインストール

各スクリプトは単独でも実行できる。

### 再実行時の挙動

| スクリプト | 再実行できるか | 何が起きるか |
|---|---|---|
| `install.sh` | ◯ | git の `pull` + `link.sh` + `packages.sh` を順に再実行 |
| `link.sh` | ◯ (idempotent) | 変化のないファイルはスキップ。差分があるものだけバックアップ + 更新 |
| `packages.sh` | △ | apt は冪等。curl 経由（starship/nvm/atuin/yazi 等）は再ダウンロード・再インストールされる |

`link.sh` のファイル別ルール:

- **シンボリックリンク**: 既に正しい場所を指していれば `[SKIP]`。違う場所を指している/通常ファイルだった場合は `[BAK ]` で `.bak-<ナノ秒つきUTC ISO8601>` に退避してから新規リンク
- **VSCode 生成ファイル**: ベース + ローカルからマージ結果を一時ファイルへ作り、現状と `cmp` で比較。同じなら `[SKIP]`、違うなら同様にバックアップして置換

つまり「設定ファイルの差分を反映したいだけ」なら `./link.sh` を何度叩いても安全で、不要な `.bak-...` は増えない。

## Local override

ホスト固有の設定は git に上げず、以下のローカルファイルに書く（存在すれば自動的に読み込まれる）。

| 用途 | dotfile | ローカルオーバーライド |
|---|---|---|
| zsh env | `~/.zshenv` | `~/.zshenv.local` |
| zsh rc | `~/.zshrc` | `~/.zshrc.local` |
| tmux | `~/.tmux.conf` | `~/.tmux.conf.local` |
| vim | `~/.vimrc` | `~/.vimrc.local` |
| git | `~/.gitconfig` | `~/.gitconfig.local` |
| VSCode 設定 | `~/.config/Code/User/settings.json`(生成物) | `~/.config/Code/User/settings.local.json` |
| VSCode キーバインド | `~/.config/Code/User/keybindings.json`(生成物) | `~/.config/Code/User/keybindings.local.json` |

### VSCode について

VSCodeの `settings.json` / `keybindings.json` は**シンボリックリンクではなく実ファイル**として `link.sh` が生成する。

- ベース: `config/.config/Code/User/{settings,keybindings}.json`（git管理）
- ローカル: `~/.config/Code/User/{settings,keybindings}.local.json`（git管理外）
- 生成物: `~/.config/Code/User/{settings,keybindings}.json`
- マージ規則:
  - settings: dictのディープマージ（ローカル優先）
  - keybindings: arrayのconcat（ローカルを末尾に追加。VSCodeは後勝ち）

VSCode上で設定を編集すると実ファイルへ反映されるが、**`./link.sh` を再実行するとベース＋ローカルのマージ結果で上書きされる**。VSCode UI で加えた変更が `~/.config/Code/User/*.local.json` にも `config/...settings.json` にも入っていない場合、その変更は失われる（旧ファイルは `.bak-...` として残るので復元可能）。コミットしたい変更は手動で `config/.config/Code/User/settings.json` に、マシン固有の変更は `~/.config/Code/User/settings.local.json` に反映するワークフローが基本。

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
