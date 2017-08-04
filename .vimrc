" Enable syntax highlighting.
syntax on

" Show line numbers.
set number

" Set the color scheme and background.
set background=dark
let g:solarized_termtrans=1
let g:solarized_termcolors=256
colorscheme solarized

" Each tab should 4 columns wide using spaces.
set tabstop=4
set shiftwidth=4
set expandtab

" Use soft wrapping at 100 columns.
set linebreak
set wrap
set textwidth=100

" Show the cursor position.
set ruler

" Wrap git commit messages at 72 columns and enable spell checking.
autocmd Filetype gitcommit setlocal spell textwidth=72
