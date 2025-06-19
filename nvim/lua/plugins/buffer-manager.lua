return {
  "j-morano/buffer_manager.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("buffer_manager").setup({
      width=0.8,
      height=0.5,

      select_menu_item_commands = {
        v = {
          key = "<C-v>",
          command = "vsplit"
        },
        h = {
          key = "<C-h>",
          command = "split"
        }
      },
      order_buffers = "lastused"
    })

    local opts = {noremap = true}
    local bmui = require("buffer_manager.ui")

    vim.keymap.set('n', '<leader><tab>', bmui.nav_next, opts)
    vim.keymap.set('n', '<leader><S-tab>', bmui.nav_prev, opts)

    vim.keymap.set({'t', 'n'}, '<leader>b', bmui.toggle_quick_menu, opts)
  end
}
