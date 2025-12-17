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
        automatic_installation = true,
				ensure_installed = { "lua_ls", "elixirls", "pyright" },
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
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = "Open diagnostic float" })
		end,
	},
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      { "folke/neodev.nvim", opts = { pathStrict = true } },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure servers (new API)
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      })

      -- If you want to pass capabilities to others too:
      vim.lsp.config("lua_ls", { capabilities = capabilities })
      vim.lsp.config("pyright", { capabilities = capabilities })
      vim.lsp.config("elixirls", { capabilities = capabilities })

      -- Enable servers (new API)
      vim.lsp.enable({ "rust_analyzer", "lua_ls", "pyright", "elixirls" })

      -- Keymaps
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
  {
    "stevanmilic/nvim-lspimport",
    -- https://github.com/stevanmilic/nvim-lspimport/pull/9/commits/2c0dfc4674493ca3ef3eddca26480e124a3f2643
    commit = "2c0dfc4674493ca3ef3eddca26480e124a3f2643"
  }
}
