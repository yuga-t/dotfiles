# dotfiles

## Supported OS

- Debian based Linux

## Install

初回インストール（git/clone + dotfilesリンク + パッケージ）:

```bash
curl -fsSL https://raw.github.com/yuga-t/dotfiles/main/install.sh | bash
```

`install.sh` はブートストラップ専用。内部で以下を呼び出す。

- `link.sh` — `config/` 配下を `$HOME` にシンボリックリンク（既存ファイルはバックアップ）
- `packages.sh` — apt/curl でパッケージインストール

各スクリプトは単独でも実行できる。設定ファイルの差分を反映したいだけなら `./link.sh` を再実行すればよい。

## Local override

ホスト固有の設定は git に上げず、以下のローカルファイルに書く（存在すれば自動的に読み込まれる）。

- `~/.zshenv.local`
- `~/.zshrc.local`
- `~/.tmux.conf.local`
- `~/.vimrc.local`
- `~/.gitconfig.local`

## Tips

### autostart fcitx5

```bash
mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart
```

ref: https://fcitx-im.org/wiki/Setup_Fcitx_5
