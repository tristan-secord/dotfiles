return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local treesitter = require("nvim-treesitter")

    treesitter.install({
      "lua",
      "javascript",
      "typescript",
      "css",
      "scss",
      "htmldjango",
      "html",
      "svelte",
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "lua",
        "javascript",
        "htmldjango",
        "html",
        "svelte",
      },
      callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr =
          "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
