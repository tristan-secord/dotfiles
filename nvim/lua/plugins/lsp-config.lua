return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "ts_ls", "volar", "pyright", "elixirls", "rust_analyzer" },
			})
		end,
	},
	{
		"ErichDonGubler/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()

			vim.diagnostic.config({
				virtual_text = false,
				virtual_lines = true,
			})

			vim.keymap.set("", "<leader>l", require("lsp_lines").toggle, { desc = "Toggle lsp lines" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
    dependencies = {
      { "folke/neodev.nvim", opts = { pathStrict = true } },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp"
    },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({ capabilities = capabilities })

			lspconfig.pyright.setup({ capabilities = capabilities })

      lspconfig.tailwindcss.setup({ capabilities = capabilities })

      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },
          },
        },
      })


      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
  { "stevanmilic/nvim-lspimport" }
}
