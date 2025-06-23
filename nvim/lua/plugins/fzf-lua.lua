return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  config = function()
    local km = vim.keymap

    km.set("n", "<leader>ff", require("fzf-lua").files, { desc = "FZF Files" })
    km.set("n", "<leader>fr", require("fzf-lua").registers, { desc = "Registers" })
    km.set("n", "<leader>fm", require("fzf-lua").marks, { desc = "Marks" })
    km.set("n", "<leader>fk", require("fzf-lua").keymaps, { desc = "Keymaps" })
    km.set("n", "<leader>fg", require("fzf-lua").live_grep, { desc = "FZF Grep" })
    km.set("n", "<leader>fb", require("fzf-lua").buffers, { desc = "FZF Buffers" })
    km.set("v", "<leader>f8", require("fzf-lua").grep_visual, { desc = "FZF Selection" })
    km.set("n", "<leader>f7", require("fzf-lua").grep_cword, { desc = "FZF Word" })
    km.set("n", "<leader>fj", require("fzf-lua").helptags, { desc = "Help Tags" })
    km.set("n", "<leader>gc", require("fzf-lua").git_bcommits, { desc = "Browse File Commits" })
    km.set("n", "<leader>gs", require("fzf-lua").git_status, { desc = "Git Status" })
    km.set("n", "<leader>s", require("fzf-lua").spell_suggest, { desc = "Spelling Suggestions" })
    km.set("n", "<leader>cj", require("fzf-lua").lsp_definitions, { desc = "Jump to Definition" })
  end
}
