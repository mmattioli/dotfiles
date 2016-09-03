" enable syntax highlighting
syntax on

" show line numbers
set number

" set the color scheme and background
set background=dark
colorscheme base16-solarized-dark

" each tab should 4 columns wide using spaces
set tabstop=4
set shiftwidth=4
set expandtab

" use soft wrapping at 80 columns
set linebreak
set wrap
set textwidth=80

" wrap git commit messages at 72 columns and enable spell checking
autocmd Filetype gitcommit setlocal spell textwidth=72
