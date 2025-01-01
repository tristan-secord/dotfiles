return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.keymap.set("n", "<leader>nn", ":Neotree toggle<CR>")

    require("neo-tree").setup({
      event_handlers = {
        {
          event = "file_open_requested",
          handler = function()
            vim.cmd("Neotree close")
          end
        }
      }
    })
	end
}
