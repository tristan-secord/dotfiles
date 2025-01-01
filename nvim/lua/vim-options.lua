vim.cmd 'set expandtab'
vim.cmd 'set tabstop=2'
vim.cmd 'set softtabstop=2'
vim.cmd 'set shiftwidth=2'
vim.cmd 'set autoindent'
vim.cmd 'set showmatch'
vim.cmd 'set ignorecase'
vim.cmd 'set number'
vim.cmd 'set relativenumber'
vim.cmd 'set smarttab'
vim.cmd 'set mouse=a'
vim.cmd 'set clipboard=unnamed'

vim.g.mapleader = " "

-- Window re-selection
vim.keymap.set('n', '<leader><Right>', '<C-w>W')
vim.keymap.set('n', '<leader><Left>', '<C-w>w')

-- Vertical / Horizontal Splits - REMOVE with tMux
vim.keymap.set('n', '<leader>vs', ':vs<CR>')
vim.keymap.set('n', '<leader>hs', ':sp<CR>')


