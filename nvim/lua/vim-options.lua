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
-- Over SSH there's no pbcopy/xclip to reach the *local* machine's clipboard,
-- so route yanks through OSC 52 instead — the terminal (Ghostty allows OSC 52
-- writes by default) picks the escape sequence off the SSH stream itself and
-- sets the system clipboard from there. Untouched when running locally.
if vim.env.SSH_TTY then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

vim.cmd 'set clipboard=unnamed'

vim.g.mapleader = " "

-- Window re-selection
vim.keymap.set('n', '<leader><Right>', '<C-w>W')
vim.keymap.set('n', '<leader><Left>', '<C-w>w')

-- Vertical / Horizontal Splits - REMOVE with tMux
vim.keymap.set('n', '<leader>vs', ':vs<CR>')
vim.keymap.set('n', '<leader>hs', ':sp<CR>')


