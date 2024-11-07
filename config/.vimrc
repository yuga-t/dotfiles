"
" 表示設定
"

" 入力中のコマンドを表示
set showcmd

" 日本語の表示幅
set ambiwidth=double 

" 行番号
set number

" 現在の行を強調
set cursorline

" コマンドラインの補完
set wildmenu

" Tab文字を複数の空白入力に
set expandtab

" 画面上でタブが占める幅
set tabstop=4

" 自動インデントでずれる幅
set shiftwidth=4

" 連続した空白に対してタブキーでカーソルが動く幅
set softtabstop=4

" 改行時に前の行のインデントを継続する
set autoindent

" ブロックに応じてインデント
set smartindent

" 折返し時に表示業単位で移動できるように
nnoremap j gj
nnoremap k gk

" シンタックスハイライト
syntax on

"
" 検索
"

" 大文字と小文字を区別しない
set ignorecase

" 大文字が含まれていれば区別して検索
set smartcase

" 最後まで行ったら最初に戻る
set wrapscan

" インクリメンタル検索
set incsearch

" ハイライト
set hlsearch

" vimgrep するとウィンドウで検索結果一覧を表示する
autocmd QuickFixCmdPost *grep* cwindow

" esc連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

"
" その他
"

" 文字コード系
set encoding=utf-8
set fileencodings=utf-8
set fileformats=unix

" バックアップファイル不要
set nobackup

" スワップファイル不要
set noswapfile

" 編集中のファイルに変更があれば反映
set autoread

" yank, put する時にクリップボードを使う
" arch: gvim が必要な場合がある ref: https://wiki.archlinux.jp/index.php/Vim
" debian: vim-gtk3 が必要な場合がある
set clipboard=unnamedplus

" sudoでファイルを保存する
" ref: https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
cmap w!! w !sudo tee > /dev/null %

" Leaderキー
let mapleader = "\<space>"

"
" プラグイン
"

call plug#begin()
  Plug 'vim-airline/vim-airline'

  Plug 'preservim/nerdtree'

  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-surround'

  Plug 'jreybert/vimagit'

  Plug 'easymotion/vim-easymotion'

  Plug 'michaeljsmith/vim-indent-object'

  Plug 'github/copilot.vim'

  Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

"
" nerdtree
"

map <C-n> :NERDTreeToggle<CR>

" ドットファイルを表示
let NERDTreeShowHidden=1

"
" fzf
"

nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>g :GFiles<CR>

" ctags
nnoremap <silent> <leader>t :Tags<CR>

" ripgrep
nnoremap <silent> <leader>r :Rg<CR>

"
" commentary
"

" ref: https://github.com/tpope/vim-commentary?tab=readme-ov-file#installation
filetype plugin indent on

"
" easymotion
"

" <Leader><Leader> ではなく <Leader> で動くように
" ref: https://github.com/easymotion/vim-easymotion?tab=readme-ov-file#default-bindings 
map <Leader> <Plug>(easymotion-prefix)

let g:EasyMotion_do_mapping = 0 " Disable default mappings
let g:EasyMotion_smartcase = 1 " Turn on case-insensitive feature

" <Leader>s{char} to move to {char}
map  <Leader>s <Plug>(easymotion-bd-f)
nmap <Leader>s <Plug>(easymotion-overwin-f)

"
" coc.nvim
"

let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-go', 'coc-clangd']

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')
