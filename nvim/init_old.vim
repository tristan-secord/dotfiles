" vim.g.mapleader = "<Space>" " Set leader
:set showmatch               " show matching 
:set ignorecase              " case insensitive
:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop
:set mouse=a


call plug#begin("~/.vim/plugged")

 " Telescope
 Plug 'nvim-lua/plenary.nvim'          
 Plug 'nvim-telescope/telescope.nvim'
 " GH Vim Airline
 Plug 'https://github.com/vim-airline/vim-airline'
 " NERDTree Nav
 Plug 'preservim/nerdtree'
 " Commenting gcc & gc
 Plug 'https://github.com/tpope/vim-commentary'
 " Dev Icons
 Plug 'https://github.com/ryanoasis/vim-devicons'
 " Vim Terminal
 Plug 'https://github.com/tc50cal/vim-terminal'
 " Multiple Cursors
 Plug 'https://github.com/terryma/vim-multiple-cursors'
 " Themes
 Plug 'https://github.com/ap/vim-css-color'
 Plug 'https://github.com/rafi/awesome-vim-colorschemes'

 " Plugin Section
 "Plug 'nvim-lua/plenary.nvim'          
 "Plug 'nvim-telescope/telescope.nvim'
 " Plug 'dracula/vim'
 " Plug 'ryanoasis/vim-devicons'
 " Plug 'SirVer/ultisnips'
 " Plug 'honza/vim-snippets'  
 " Plug 'scrooloose/nerdtree'
 " Plug 'preservim/nerdcommenter'
 " Plug 'mhinz/vim-startify'
 " Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

let mapleader = " "

nnoremap <C-f> :NERDTreeFocus<Cr>
nnoremap <C-n> :NERDTree<Cr>
nnoremap <C-t> :NERDTreeToggle<Cr>

map <leader><tab> :bnext<Cr>

map <leader>t :Terminal bash<Cr>

let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"
