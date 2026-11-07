" Basic .vimrc

" Plugin Management (vim-plug)
call plug#begin('~/.vim/plugged')

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Colorschemes
Plug 'morhetz/gruvbox'

" LSP and Autocompletion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" ============================================================================
" COC.NVIM CONFIGURATION
" ============================================================================

" coc.nvim requires these settings
set hidden
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Use tab for trigger completion and navigate
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion manually
inoremap <silent><expr> <c-space> coc#refresh()

" Navigate diagnostics
nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Show documentation
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight symbol under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Rename symbol
nmap <leader>rn <Plug>(coc-rename)

" Format selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Organize imports for Go
autocmd BufWritePre *.go :silent call CocAction('runCommand', 'editor.action.organizeImport')

" ============================================================================
" COLORS & UI
" ============================================================================

set termguicolors
set background=dark

" Use silent! to prevent error before plugin is installed
silent! colorscheme gruvbox

" make cursorline blend in
highlight CursorLine   cterm=none gui=none ctermbg=235 guibg=#3c3836
highlight SignColumn   ctermbg=235 guibg=#3c3836
set cursorline
set signcolumn=yes

" Enable syntax highlighting
syntax on

" Enable line numbers
set number
set relativenumber

" Set indentation (4 spaces)
set tabstop=4
set shiftwidth=4
set expandtab

" Enable auto-indenting
set autoindent
set smartindent

" Use jk to exit insert mode
inoremap jk <Esc>

" Show matching brackets
set showmatch

" Better search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Enable mouse support
set mouse=a

" Set encoding
set encoding=utf-8

" Clipboard - macOS uses 'unnamed'
set clipboard=unnamed

" Set leader key to space
let mapleader = " "

" ============================================================================
" FZF KEYBINDINGS
" ============================================================================

nnoremap <leader>sf :Files<CR>
nnoremap <leader>ss :Rg<CR>
nnoremap <leader>sb :Buffers<CR>

" Better colors for FZF
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
