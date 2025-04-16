return {
  "windwp/nvim-autopairs",
  event = "InsertCharPre",
  config = function()
    require("nvim-autopairs").setup({})
  end
}
