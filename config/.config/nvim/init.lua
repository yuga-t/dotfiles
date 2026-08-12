--
-- 旧 .vimrc を踏襲したミニマルな Neovim 設定
-- ref: https://www.khuedoan.com/posts/minimal-neovim-setup-from-scratch
--
-- Neovim ではデフォルトが変わったため、.vimrc にあった以下の設定は不要:
--   showcmd / wildmenu / autoindent / incsearch / hlsearch / wrapscan /
--   autoread / nobackup / encoding / syntax on / filetype plugin indent on
--

--
-- 表示設定
--

-- 日本語の表示幅
vim.opt.ambiwidth = "double"

-- 行番号
vim.opt.number = true

-- 現在の行を強調
vim.opt.cursorline = true

-- Tab文字を複数の空白入力に
vim.opt.expandtab = true

-- 画面上でタブが占める幅
vim.opt.tabstop = 4

-- 自動インデントでずれる幅
vim.opt.shiftwidth = 4

-- 連続した空白に対してタブキーでカーソルが動く幅
vim.opt.softtabstop = 4

-- 折返し時に表示行単位で移動できるように
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

--
-- 検索
--

-- 大文字と小文字を区別しない
vim.opt.ignorecase = true

-- 大文字が含まれていれば区別して検索
vim.opt.smartcase = true

-- vimgrep するとウィンドウで検索結果一覧を表示する
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "*grep*",
  command = "cwindow",
})

-- quickfix での移動 ([q ]q [Q ]Q) は Neovim 0.11+ のデフォルトマッピングにある

-- esc連打でハイライト解除
vim.keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>")

--
-- その他
--

-- スワップファイル不要
vim.opt.swapfile = false

-- undo 履歴をファイルに永続化
vim.opt.undofile = true

-- yank, put する時にクリップボードを使う
-- (wl-clipboard または xsel が必要。packages.sh の apt で導入している)
vim.opt.clipboard = "unnamedplus"

-- 新しいウィンドウを下/右に開く
vim.opt.splitbelow = true
vim.opt.splitright = true

-- truecolor を明示的に有効化 (lualine/flash.nvim の表示を安定させる)
vim.opt.termguicolors = true

-- Leaderキー (プラグインの読み込みより前に設定する必要がある)
vim.g.mapleader = " "

--
-- プラグイン (lazy.nvim)
--

-- コメントトグル (vim-commentary の gc) は Neovim 0.10+ のビルトイン機能を使う

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- ステータスライン (vim-airline の代替)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- ファイラ (vim-fern の代替): ディレクトリをバッファとして編集できる
  {
    "stevearc/oil.nvim",
    -- `nvim <dir>` で直接開けるように遅延読み込みしない
    lazy = false,
    opts = {
      view_options = {
        -- 隠しファイルを表示
        show_hidden = true,
      },
    },
    keys = {
      { "-", "<Cmd>Oil<CR>", desc = "親ディレクトリを開く" },
    },
  },

  -- fzf (バイナリは devbox で導入している)
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    keys = {
      { "<Leader>f", "<Cmd>Files<CR>", desc = "ファイル検索" },
      { "<Leader>g", "<Cmd>GFiles<CR>", desc = "git ファイル検索" },
      { "<Leader>t", "<Cmd>Tags<CR>", desc = "ctags 検索" },
      { "<Leader>r", "<Cmd>Rg<CR>", desc = "ripgrep 全文検索" },
    },
  },

  -- surround (vim-surround の Lua 版。ys / cs / ds は同じ)
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- ファイルごとにインデント幅を自動検出
  {
    "tpope/vim-sleuth",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- git
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },

  -- sudo で保存 (旧 vimrc の w!! の代替)
  {
    "lambdalisue/vim-suda",
    cmd = { "SudaWrite", "SudaRead" },
    init = function()
      -- w!! で SudaWrite を呼ぶ (旧 vimrc 互換)
      vim.cmd.cnoreabbrev("w!!", "SudaWrite")
    end,
  },

  -- インデントのテキストオブジェクト (ii, ai)
  {
    "michaeljsmith/vim-indent-object",
    event = "VeryLazy",
  },

  -- ラベルジャンプ (easymotion の代替)
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        -- 通常の / 検索や f/t は素の挙動のまま
        search = { enabled = false },
        char = { enabled = false },
      },
    },
    keys = {
      {
        "<Leader>s",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "ラベルジャンプ",
      },
    },
  },

  -- 補完 (coc.nvim の代替)
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = {
        -- Enter で確定、Tab / Shift+Tab で次/前の候補
        preset = "enter",
      },
    },
  },

  -- LSP サーバー設定の定義集。有効化は Neovim 0.11+ の vim.lsp.enable() で行う
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- blink.cmp の補完 capabilities を全 LSP サーバーに適用
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- LSP サーバー本体は packages.sh (devbox) で管理する
      -- バイナリが存在するものだけ有効化する (インストール後は Neovim を再起動)
      local servers = {
        clangd = "clangd",
        gopls = "gopls",
        rust_analyzer = "rust-analyzer",
        ts_ls = "typescript-language-server",
        pyright = "pyright-langserver",
        yamlls = "yaml-language-server",
        jsonls = "vscode-json-language-server",
        taplo = "taplo",
      }
      for name, bin in pairs(servers) do
        if vim.fn.executable(bin) == 1 then
          vim.lsp.enable(name)
        end
      end
    end,
  },
})

--
-- local override
--

local local_config = vim.fn.stdpath("config") .. "/local.lua"
if vim.uv.fs_stat(local_config) then
  dofile(local_config)
end
