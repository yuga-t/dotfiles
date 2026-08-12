# dotfiles

## Supported OS

- Debian based Linux

## Install

初回インストール（git/clone + dotfilesリンク + パッケージ）:

```bash
curl -fsSL https://raw.githubusercontent.com/yuga-t/dotfiles/main/install.sh | bash
```

`install.sh` は Git の導入とブートストラップを行う。内部で以下を呼び出す。

- `link.sh` — `config/` 配下を `$HOME` にシンボリックリンク
- `packages.sh` — Devbox の導入、Devbox パッケージ、apt/curl でホスト依存パッケージをインストール

各スクリプトは単独でも実行できる。

### 再実行時の挙動

| スクリプト | 再実行できるか | 何が起きるか |
|---|---|---|
| `install.sh` | ◯ | git の `pull` + `link.sh` + `packages.sh` を順に再実行 |
| `link.sh` | ◯ (idempotent) | 変化のないファイルはスキップ。差分があるものだけバックアップ + 更新 |
| `packages.sh` | ◯ | apt は毎回更新、Devbox は不足分を追加、Cica は導入済みならスキップ |

`link.sh` のファイル別ルール:

- **シンボリックリンク**: 既に正しい場所を指していれば `[SKIP]`。違う場所を指している/通常ファイルだった場合は `[BAK ]` で `.bak-<ナノ秒つきUTC ISO8601>` に退避してから新規リンク

つまり「設定ファイルの差分を反映したいだけ」なら `./link.sh` を何度叩いても安全で、不要な `.bak-...` は増えない。

## Local override

ホスト固有の設定は git に上げず、以下のローカルファイルに書く（存在すれば自動的に読み込まれる）。

| 用途 | dotfile | ローカルオーバーライド |
|---|---|---|
| zsh env | `~/.zshenv` | `~/.zshenv.local` |
| zsh rc | `~/.zshrc` | `~/.zshrc.local` |
| neovim | `~/.config/nvim/init.lua` | `~/.config/nvim/local.lua` |
| git | `~/.gitconfig` | `~/.gitconfig.local` |

### 初回セットアップで必須: `~/.gitconfig.local`

`~/.gitconfig` には `user.email` を書いていないので、`git commit` する前に `~/.gitconfig.local` で設定する。

```ini
[user]
  email = your@email.example
```

## Test

`install.sh` の初回セットアップを Docker で検証できる:

```bash
./test.sh
```

`Dockerfile` に現在の作業ツリーをコピーし、ローカルの `install.sh` をコンテナ内で実行する。Docker では Nix daemon を起動できないため Devbox 導入だけをスキップし、clone・link・apt・特殊インストール経路を検証する。Devbox 自体は実環境で確認する。

## Devbox

CLI ツールは `packages.sh` から `devbox global add` で導入する。Devbox をインストールした後、リポジトリのルートで以下を実行する:

```bash
./packages.sh
```

`install.sh` は clone に必要な Git を apt で導入する。`packages.sh` は Devbox の未導入パッケージを追加するだけなので、手動で試しているグローバルパッケージを上書きで削除しない。

`~/.zshrc` は `devbox global shellenv` を評価するため、以後の zsh では `devbox shell` なしで利用できる。パッケージの解決結果は Devbox のグローバル環境側で保持される。

`zsh`、`fcitx5`、`fcitx5-mozc`、`ddcutil`、`wl-clipboard` など、デスクトップ環境やホスト固有の機能に依存するものは apt で管理する。`neovim`、`herdr`、`hunk` も Devbox で管理する。

ディスプレイのないリモート専用ホストでは `HEADLESS=true ./packages.sh` を実行する。クリップボード (`xsel`、`wl-clipboard`)、モニタ制御 (`ddcutil`)、IME (`fcitx5`、`fcitx5-mozc`) の apt パッケージと Cica フォントの導入をスキップする。

Neovim の LSP サーバーも Devbox で管理する (`gopls`、`clang-tools`、`pyright`、`typescript-language-server`、`yaml-language-server`、`vscode-langservers-extracted`、`taplo`)。例外として `rust-analyzer` は rustc とのバージョンを揃えるため rustup で管理する (`rustup component add rust-analyzer`)。他の言語を使い始めたら `devbox global add` で追加し、`packages.sh` のリストと `init.lua` の `servers` テーブルにも反映する。

## Tips

### autostart fcitx5

```bash
mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart
```

ref: https://fcitx-im.org/wiki/Setup_Fcitx_5

### GNOME ショートカット

dconf 経由でエクスポート/インポートする手順は [`gnome/README.md`](gnome/README.md) を参照。`install.sh` からは自動適用されない（手動運用）。
