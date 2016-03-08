colorscheme Mustang
set number
syntax on

filetype plugin indent on

"whitespaces and indent
set wrap
set textwidth=120
"When indenting with >
set shiftwidth=4
set tabstop=4
"on pressing tab, insert 4 spaces
set expandtab

"Blink cursor instead of beeping 
set visualbell

"Encoding
set encoding=utf-8

"Searching
set ignorecase
set hlsearch
set smartcase
set showmatch

" Last line
set showmode
set showcmd

" a bit of lines in the end
autocmd InsertEnter * if winheight(0) - winline() < 5 | set scrolloff=9999 | endif
