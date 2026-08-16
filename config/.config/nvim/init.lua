--
-- ミニマルな Neovim 設定
-- ref: https://www.khuedoan.com/posts/minimal-neovim-setup-from-scratch
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
vim.keymap.set("n", "j", "gj", { desc = "表示行単位で下へ移動" })
vim.keymap.set("n", "k", "gk", { desc = "表示行単位で上へ移動" })

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

-- quickfix での移動 ([q 前へ, ]q 次へ, [Q 最初へ, ]Q 最後へ) は
-- Neovim 0.11+ のデフォルトマッピングにある

-- escでハイライト解除
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "検索ハイライトを解除" })

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

-- ファイルを開いたら、そのファイルの git ルートへタブローカルで cd する
-- (telescope の find_files / git_files / live_grep がプロジェクトルート基準で動くようにするため)
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    if file == "" then
      return
    end
    local root = vim.fs.root(file, ".git")
    if root then
      vim.cmd.tcd(root)
    end
  end,
})

--
-- プラグイン (lazy.nvim)
--

-- コメントトグル (gc{motion}, gcc で1行) は Neovim 0.10+ のビルトイン機能を使う

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
  -- カラースキーム
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("onedark")
    end,
  },

  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- ファイラ: ディレクトリをバッファとして編集できる
  -- キーバインド: - (親ディレクトリを開く), 開いたバッファ内は通常の編集操作
  --   (dd で削除, o/O で新規作成, r でリネームなど) がそのままファイル操作になる。
  --   :w で確定
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

  -- ファジー検索 (fd/ripgrep は devbox で導入している)
  -- キーバインド: <Leader>f (ファイル検索), <Leader>g (git ファイル検索),
  --   <Leader>t (ctags 検索), <Leader>r (ripgrep 全文検索)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<Leader>f", "<Cmd>Telescope find_files<CR>", desc = "ファイル検索" },
      { "<Leader>g", "<Cmd>Telescope git_files<CR>", desc = "git ファイル検索" },
      { "<Leader>t", "<Cmd>Telescope tags<CR>", desc = "ctags 検索" },
      { "<Leader>r", "<Cmd>Telescope live_grep<CR>", desc = "ripgrep 全文検索" },
    },
  },

  -- surround
  -- キーバインド: ys{motion}{char} (囲む), cs{from}{to} (置換), ds{char} (削除)
  --   例: ysiw" (単語を"で囲む), cs"' ("を'に置換), ds" (囲みの"を削除)
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

  -- 括弧・クォートの自動閉じ
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- ファイルを開いたとき前回のカーソル位置に復帰
  {
    "farmergreg/vim-lastplace",
    event = "BufReadPost",
  },

  -- git
  -- キーバインド: :Neogit (ステータス画面。s/u でステージ/アンステージ、c でコミット)
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Neogit",
    opts = {},
  },

  -- サインカラムに git 差分マークを表示
  -- キーバインド: ]c/[c (ハンク間移動)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- sudo で保存
  -- キーバインド: w!! (コマンドラインで入力すると SudaWrite に展開される)
  {
    "lambdalisue/vim-suda",
    cmd = { "SudaWrite", "SudaRead" },
    init = function()
      vim.cmd.cnoreabbrev("w!!", "SudaWrite")
    end,
  },

  -- インデントのテキストオブジェクト
  -- キーバインド: ii/ai (同じインデントの範囲, 例: dii, vai)
  {
    "michaeljsmith/vim-indent-object",
    event = "VeryLazy",
  },

  -- ラベルジャンプ
  -- キーバインド: <Leader>s{char...} (画面内にラベルが表示され、押すとジャンプ)
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

  -- 補完
  -- キーバインド: Tab/S-Tab (次/前の候補), Enter (確定), Ctrl-e (キャンセル)
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
  -- キーバインド (LSP アタッチ時、Neovim 0.11+ のデフォルト):
  --   K (hover), grn (rename), gra (code action), grr (references),
  --   gri (implementation), gO (document symbols), ]d/[d (診断ジャンプ)
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
