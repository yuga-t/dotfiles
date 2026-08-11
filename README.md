# dotfiles

## Supported OS

- Debian based Linux

## Install

初回インストール（git/clone + dotfilesリンク + パッケージ）:

```bash
curl -fsSL https://raw.github.com/yuga-t/dotfiles/main/install.sh | bash
```

`install.sh` は Devbox の導入とブートストラップを行う。内部で以下を呼び出す。

- `link.sh` — `config/` 配下を `$HOME` にシンボリックリンク
- `packages.sh` — apt/curl でパッケージインストール

各スクリプトは単独でも実行できる。

### 再実行時の挙動

| スクリプト | 再実行できるか | 何が起きるか |
|---|---|---|
| `install.sh` | ◯ | git の `pull` + `link.sh` + `packages.sh` を順に再実行 |
| `link.sh` | ◯ (idempotent) | 変化のないファイルはスキップ。差分があるものだけバックアップ + 更新 |
| `packages.sh` | ◯ (idempotent) | apt も curl 経由のインストールも、既に入っているものはスキップする |

`link.sh` のファイル別ルール:

- **シンボリックリンク**: 既に正しい場所を指していれば `[SKIP]`。違う場所を指している/通常ファイルだった場合は `[BAK ]` で `.bak-<ナノ秒つきUTC ISO8601>` に退避してから新規リンク

つまり「設定ファイルの差分を反映したいだけ」なら `./link.sh` を何度叩いても安全で、不要な `.bak-...` は増えない。

## Local override

ホスト固有の設定は git に上げず、以下のローカルファイルに書く（存在すれば自動的に読み込まれる）。

| 用途 | dotfile | ローカルオーバーライド |
|---|---|---|
| zsh env | `~/.zshenv` | `~/.zshenv.local` |
| zsh rc | `~/.zshrc` | `~/.zshrc.local` |
| vim | `~/.vimrc` | `~/.vimrc.local` |
| git | `~/.gitconfig` | `~/.gitconfig.local` |

### 初回セットアップで必須: `~/.gitconfig.local`

`~/.gitconfig` には `user.email` を書いていないので、`git commit` する前に `~/.gitconfig.local` で設定する。

```ini
[user]
  email = your@email.example
```

## Test

`link.sh` の動作と各種ローカルオーバーライドの仕組みを Docker で検証できる:

```bash
./test.sh
```

中身は `Dockerfile.test` をビルドして `scripts/run-link-tests.sh` をコンテナ内で走らせるだけ。ネットワーク経由のパッケージインストールはテストしない（あくまで `link.sh` とローカルオーバーライドの挙動を確認する用途）。

## Devbox

CLI ツールは [`devbox-global.json`](devbox-global.json) を正本として管理する。Devbox をインストールした後、リポジトリのルートで以下を実行する:

```bash
devbox global pull ./devbox-global.json
```

`install.sh` は clone 前に GitHub 上の `devbox-global.json` を pull するため、Git も Devbox から提供される。これにより、`install.sh` とグローバルパッケージ定義で Git を二重管理しない。

`~/.zshrc` は `devbox global shellenv` を評価するため、以後の zsh では `devbox shell` なしで利用できる。パッケージの解決結果は Devbox のグローバル環境側で保持される。

`fcitx5`、`fcitx5-mozc`、`ddcutil`、`wl-clipboard` など、デスクトップ環境やホスト固有の機能に依存するものは引き続き apt で管理する。`herdr` と `hunk` も Devbox で管理する。

## Tips

### autostart fcitx5

```bash
mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart
```

ref: https://fcitx-im.org/wiki/Setup_Fcitx_5

### GNOME ショートカット

dconf 経由でエクスポート/インポートする手順は [`gnome/README.md`](gnome/README.md) を参照。`install.sh` からは自動適用されない（手動運用）。
