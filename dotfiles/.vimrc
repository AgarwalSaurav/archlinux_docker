" Do not pretend to be compatible with vi
set nocompatible

" Enable full color support
set t_Co=256			" 256 colors
set encoding=utf-8

" Do not redraw while executing macro
set lazyredraw

" Disable filetype recognition for plugins
" but make sure to turn it on after loading plugins
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=~/.vim/bundle/put-sentences
call vundle#begin()
Plugin 'catppuccin/vim', { 'as': 'catppuccin' }
Plugin 'preservim/nerdtree'
Plugin 'christoomey/vim-tmux-navigator'
" Plugin 'dense-analysis/ale'
" Plugin 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')
Plugin 'godlygeek/tabular'
Plugin 'iamcco/markdown-preview.nvim'
" Plugin 'preservim/vim-markdown'
"
Plugin 'github/copilot.vim'

" Plugin 'dpelle/vim-LanguageTool'
Plugin 'NLKNguyen/papercolor-theme'
" Plugin 'gosukiwi/vim-atom-dark'

Plugin 'bfrg/vim-cpp-modern'

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Helpers for UNIX
Plugin 'tpope/vim-eunuch'

" vim theme
" Plugin 'nightsense/snow'
"
" Git wrapper
Plugin 'tpope/vim-fugitive'

" Handy bracket bindings for ex commands
Plugin 'tpope/vim-unimpaired'

" Enable repeating supported plugin maps with "."
Plugin 'tpope/vim-repeat'

" Comment stuff out
Plugin 'tpope/vim-commentary'

" Quoting/parenthesizing made simple
Plugin 'tpope/vim-surround'
Plugin 'machakann/vim-sandwich'

Plugin 'lervag/vimtex'
Plugin 'jiangmiao/auto-pairs'

" Vim status bar
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Targets
Plugin 'wellle/targets.vim'

" Ultisnips
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

" Plugin 'iamcco/markdown-preview.nvim'
" All of your Plugins must be added before the following line
call vundle#end()            " required
let g:copilot_filetypes = {'markdown': v:true}
" Enable syntax and plugins
filetype plugin indent on
syntax enable

" To ignore plugin indent changes, instead use:
" filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Set theme
set background=light
" colorscheme PaperColor
colorscheme catppuccin_latte
"" Provides tab-completion for all file-related tasks
" ** when looking for a file search recursively through subdirectories
" `:set path?` get current paths
" Use `:find` to look for a file, tab completion works as well
" Can use basic pattern recognition `:find *filename*` then hit tab
" Can also be specific `:find repo/*filename*` then hit tab
set path+=**
set wildignore+=**/.git/** "ignore certain folders

" Display all matching files when we tab complete
set wildmenu

" Each time you open a git object using fugitive it creates a new buffer. This means that your buffer listing can quickly become swamped with fugitive buffers.
" Here’s an autocommand that prevents this from becomming an issue:
autocmd BufReadPost fugitive://* set bufhidden=delete

" `:ls` gives the list of files that are open
" `:b` can then be used to load the buffer. Any unique substring will work.
" If there are multiple buffers then we can use tab completion

" ## TAG JUMPING
" - Jump to tags
" - ^] to jump to tag under cursor
" - g^] for ambiguous tags
" - ^t to jump back up the tag stack
" - ! run as shell command. A file called tags is created in the folder.
" - command! MakeTags !ctags -R .

" ## File Browsing
" Tweaks for browsing
" - `:edit` a folder to open in the file browser
" - :sp/vs/tabnew to open in an h-split/v-split/tab
" - check |netrw-browse-maps| for more mappings
" let g:netrw_banner=1		" enable/disable annoying banner
let g:netrw_browser_split=4	" open in prior window
" let g:netrw_altv=1		" open splits to the right
" let g:netrw_liststyle=3		" tree view
" let g:netrw_list_hide=netrw_gitignore#Hide()
" let g:netrw_list_hide.=',\(^\|\s\s\)\zs\S\+'

" `:only` close everything else

" Split on the right and below
set splitright
set splitbelow

set esckeys
set shell=/bin/bash
"set term=screen-256color
set autoindent
set backupdir=~/.vim/backup
set directory=~/.vim/backup
set backupdir-=.
set undodir=~/.vim/undodir
set termguicolors
" set background=dark
" colorscheme snow
"colorscheme dracula

set undofile " Maintain undo history between sessions

set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set hlsearch      " highlight matches
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands

" Fuzzy finder: ignore stuff that can't be opened, and generated files
let g:fuzzy_ignore = "*.png;*.PNG;*.JPG;*.jpg;*.GIF;*.gif;vendor/**;coverage/**;tmp/**;rdoc/**;*.blg;*.bbl"

set tabstop=2
set shiftwidth=2
set softtabstop=2

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

" Enable syntax highlighting
syntax on

" Show the filename in the window titlebar
set title

" Use relative line numbers
"if exists("&relativenumber")
"	set relativenumber
"	au BufReadPost * set relativenumber
"endif
"
set number relativenumber

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set number norelativenumber
:augroup END

" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:SuperTabDefaultCompletionType = '<C-n>'

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

:set linebreak
:set cursorline
" Disable all blinking:
:set guicursor+=a:blinkon0
"
" compile your pdf with --synctex support:
let g:Tex_DefaultTargetFormat = 'pdf'
" Set the compilation output directory
" let g:Tex_Outputdir = 'build'
" let g:vimtex_compiler_latexmk = {'build_dir' : 'build'}
" let g:vimtex_compiler_latexmk = {
"     \ 'out_dir' : 'build',
"     \}

let g:tex_flavor = "pdflatex"
let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \ ],
    \ 'out_dir' : 'build',
    \}
let g:vimtex_view_method = 'zathura'
" hi CursorLine term=Bold cterm=None ctermbg=Black guibg=Black
let g:airline_powerline_fonts = 1
let g:airline_theme='minimalist'
let g:airline_theme = 'catppuccin_mocha'
"let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"
" let g:vimtex_complete_close_braces=1
" let g:vimtex_complete_bib=1
let g:vimtex_fold_enabled=1
"if $COLORTERM == 'gnome-terminal'
"      set t_Co=256
"endif
"
"if &term =~ '256color'
"    " disable Background Color Erase (BCE) so that color schemes
"    " render properly when inside 256-color tmux and GNU screen.
"    " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
"    set t_ut=
"endif
set shortmess+=c


" clever jumping to first and last character of the line
nmap H ^
vmap H ^
nmap L $
vmap L $

fun! CPPFormatSettings()
  setlocal equalprg=clang-format\ -style=google
endfun
autocmd FileType c,cpp,cuh,ch,cu call CPPFormatSettings()

set wrap linebreak nolist
au VimLeavePre * if v:this_session != '' | exec "mks! " . v:this_session | endif

" Fix: Adding brackets opens folds automatically
" https://stackoverflow.com/questions/4630892/vim-folds-open-up-when-giving-an-unmatched-opening-brace-parenthesis
autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif


set foldmethod=syntax

" Enable highlighting of C++11 attributes
let g:cpp_attributes_highlight = 1

" Highlight struct/class member variables (affects both C and C++ files)
let g:cpp_member_highlight = 1

highlight CursorLineNr cterm=NONE
" Disable error bells
set belloff=all
set noerrorbells
" set guifont=Source\Code\Pro\Medium\ 12
set guifont=SauceCodePro\ Nerd\ Font\ Medium\ 12
autocmd FileType bib setlocal nospell

nnoremap <silent> <A-S-h> :tabprevious<CR>
nnoremap <silent> <A-S-l> :tabnext<CR>

set expandtab

let g:tmux_navigator_no_mappings = 1

noremap <silent> <M-h> :<C-U>TmuxNavigateLeft<cr>
noremap <silent> <M-j> :<C-U>TmuxNavigateDown<cr>
noremap <silent> <M-k> :<C-U>TmuxNavigateUp<cr>
noremap <silent> <M-l> :<C-U>TmuxNavigateRight<cr>
noremap <silent> <M-\\> :<C-U>TmuxNavigatePrevious<cr>

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['add_blank_lines_for_python_control_statements', 'autopep8', 'autoflake', 'isort', 'yapf', 'black', 'autoimport', 'pycln', 'reorder-python-imports', 'ruff', 'ruff_format', 'prettier']
\}
