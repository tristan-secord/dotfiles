return {
  'oem/arachne.nvim',
  config = function ()
    require('arachne').setup({
      notes_directory = "~/arachne/notes"
    })

    vim.keymap.set('n', '<leader>Nn', function() return require('arachne').new() end)
    vim.keymap.set('n', '<leader>Nr', function() return require('arachne').rename() end)
    -- search notes
    vim.keymap.set('n', '<leader>Ns', function()
      require('fzf-lua').live_grep { cwd = vim.fn.expand("~/arachne/notes"), prompt_title = "<notes::search>" }
    end, { desc = "Search Notes" })
    -- find notes
    vim.keymap.set('n', '<leader>Nf', function()
      require('fzf-lua').files { cwd = vim.fn.expand("~/arachne/notes"), prompt_title = "<notes::files>" }
    end, { desc = "Find Notes" })
  end
}
