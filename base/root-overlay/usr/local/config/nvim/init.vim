" Text Encoding
set encoding=utf-8

" enable syntax highlighting
syntax on

" disable errorsounds
set noerrorbells

" Change Vim's terminal colors according to colorscheme you/your plugin provide
set termguicolors

" Show line number (hybrid)
set number relativenumber

" Show Status bar at the bottom of screen (0: never 1: only if there are at least two windows 2: always)
set laststatus=2

" Automatically wrap text that extends beyond the screen length
set wrap

" stop default tab size of 8 spaces to use indentation of 4 spaces
set softtabstop=4

" In Insert mode: Use the appropriate number of spaces to insert a <Tab>
set expandtab

" Number of spaces to use for each step of (auto)indent
set shiftwidth=4

" Number of spaces that a <Tab> in the file counts for
set tabstop=4

" Do smart autoindenting when starting a new line for known filetypes. Normally 'autoindent' should also be on when using 'smartindent'
set smartindent

" Copy indent from current line when starting a new line (typing <CR> in Insert mode or when using the "o" or "O" command)
set autoindent

" Show the line and column number of the cursor position, separated by a comma.
set ruler

" The command-lines that you enter are remembered in a history table. You can recall them with the up and down cursor keys.
set history=1000

" This is a list of directories which will be searched when using the gf, [f, ]f, ^Wf, :find, :sfind, :tabfind and other commands, provided that the file being searched for has a relative path (not starting with "/", "./" or "../")
set path+=**

" Highlight the text line of the cursor with CursorLine (horizontally)
set cursorline

" Indicates a fast terminal connection. More characters will be sent to the screen for redrawing, instead of using insert/delete line commands. Improves smoothness of redrawing when there are multiple windows and the terminal does not support a scrolling region.
set ttyfast

" Ignore case in search patterns.  Also used when searching in the tags file
set ignorecase

" Override the 'ignorecase' option if the search pattern contains upper case characters.
set smartcase

" Show partial command you type in the last line of the screen
set showcmd

" Show the mode you are currently using on the last line
set showmode

" When a bracket is inserted, briefly jump to the matching one
set showmatch

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

 " Toggle highlighting (Automatically remove highlighting after search)
set hlsearch!

" While searching though a file incrementally highlight matching characters as you type
set incsearch

" Enable commands auto completion menu after pressing TAB
set wildmenu

" There are certain files that we would never want to edit with Vim. Wildmenu will ignore files with these extensions
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Save undo history to an undo file when writing a buffer to a file, and restore undo history from the same file on buffer read (used with undodir)
set undofile

" Directory to story undo history to restore undo even after quitting vim (create the directory manually if doesn't pre-exist)
set undodir=~/.config/nvim/undo

" Save the whole buffer for undo when reloading it.
set undoreload=10000

" Make a backup before overwriting a file. The backup is removed after the file is successfully written, unless the 'backup' option is also on.
set writebackup

" Don't use a swapfile for the buffer as all text will be in memory(RAM)
set noswapfile

" enable filetype detection
filetype on

" enable plugins and load it for detected filetype
filetype plugin on

" Load an indent file for the detected file type
filetype indent on

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow splitright

" Auto completion settings
set complete+=kspell
set completeopt=menuone,longest
set shortmess+=c

" Resume your cursor from the last closing position rather than placing the cursor in the beginning 
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Copy/Paste/Cut (using system clipboard)
if has('unnamedplus')
    set clipboard=unnamed,unnamedplus
endif

" Enable 24-bit true colors if your terminal supports it.
if (has("termguicolors"))
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

" Include the separate file for plugins and plugin related keybindings (if exists)
if filereadable(expand("~/.config/nvim/plugins.vim"))
    source ~/.config/nvim/plugins.vim
endif

" Include the separate file for keybindings (if exists) (custom keybindings only! Plugin specific bindings are done in plugins.vim)
if filereadable(expand("~/.config/nvim/key-bindings.vim"))
    source ~/.config/nvim/key-bindings.vim
endif

