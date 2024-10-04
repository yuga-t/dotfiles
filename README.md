# dotfiles

環境

- Arch or Debian based Linux
- GNOME Wayland

## インストール

```bash
curl -fsSL https://raw.github.com/yuga-t/dotfiles/main/install.sh | bash
```

## 既知の問題

### fcitx5 が自動起動しない

以下のコマンドで自動起動するようになるはず。
ref: https://fcitx-im.org/wiki/Setup_Fcitx_5 

```bash
mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart
```
