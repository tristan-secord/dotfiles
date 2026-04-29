return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        extension = {
          jinja = "htmldjango",
          jinja2 = "htmldjango",
          j2 = "htmldjango",
        },
      })
    end,
  },
}
