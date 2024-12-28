local wezterm = require 'wezterm'

local cfg = wezterm.config_builder()

cfg.color_scheme = 'Bamboo Multiplex'

-- ref: https://zenn.dev/paiza/articles/9ca689a0365b05
cfg.font = wezterm.font_with_fallback({
    { family = "Cica" },
    { family = "Cica", assume_emoji_presentation = true },
})

cfg.font_size = 17.0

cfg.window_background_opacity = 0.95

cfg.audible_bell = 'Disabled'

cfg.hide_tab_bar_if_only_one_tab = true

cfg.use_ime = true

cfg.xim_im_name = "fcitx"

cfg.warn_about_missing_glyphs = false

-- マウスを動かすと消えるので
-- ref: https://github.com/wez/wezterm/issues/1742#issuecomment-1075333507
local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-theme"})
if success then
  cfg.xcursor_theme = stdout:gsub("'(.+)'\n", "%1")
end

local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-size"})
if success then
  cfg.xcursor_size = tonumber(stdout)
end

local act = wezterm.action

-- ref: https://qiita.com/sonarAIT/items/0571c869e5f9ab3be817
cfg.keys = {
  -- Ctrl+左矢印でカーソルを前の単語に移動
  {
    key = "LeftArrow",
    mods = "CTRL",
    action = act.SendKey {
      key = "b",
      mods = "META",
    },
  },
  -- Ctrl+右矢印でカーソルを次の単語に移動
  {
    key = "RightArrow",
    mods = "CTRL",
    action = act.SendKey {
      key = "f",
      mods = "META",
    },
  },
  -- Ctrl+Backspaceで前の単語を削除
  {
    key = "Backspace",
    mods = "CTRL",
    action = act.SendKey {
      key = "w",
      mods = "CTRL",
    },
  },
}

-- ウィンドウを最大で開く
-- ref: https://github.com/wez/wezterm/issues/284#issuecomment-1177628870
local mux = wezterm.mux

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  window:gui_window():maximize()
end)

return cfg
