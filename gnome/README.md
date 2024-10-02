# gnome のショートカット設定

ref: https://askubuntu.om/questions/26056/where-are-gnome-keyboard-shortcuts-stored

### Export

```bash
dconf dump / | sed -n '/\[org.gnome.desktop.wm.keybindings/,/^$/p' > shortcuts.conf
```

### Import

```bash
dconf load / < shortcuts.conf
```

