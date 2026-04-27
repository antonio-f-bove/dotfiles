local js_like = {
  left = 'console.trace("',
  right = '")',
  mid_var = '", ',
  right_var = ')',
}

return {
  'andrewferrier/debugprint.nvim',
  dependencies = {
    -- 'echasnovski/mini.nvim', -- Optional: Needed for line highlighting (full mini.nvim plugin)
    -- ... or ...
    'echasnovski/mini.hipatterns', -- Optional: Needed for line highlighting ('fine-grained' hipatterns plugin)

    -- "nvim-telescope/telescope.nvim", -- Optional: If you want to use the `:Debugprint search` command with telescope.nvim
    'folke/snacks.nvim', -- Optional: If you want to use the `:Debugprint search` command with snacks.nvim
  },

  lazy = false,  -- Required to make line highlighting work before debugprint is first used
  version = '*', -- Remove if you DON'T want to use the stable version
  opts = {
    display_counter = false,
    display_location = false,
    keymaps = {
      normal = {
        plain_below = 'g??',
      },
    },
    filetypes = {
      ['javascript'] = js_like,
      ['javascriptreact'] = js_like,
      ['typescript'] = js_like,
      ['typescriptreact'] = js_like,
    },
  },
  keys = {
    {
      '<leader>fd',
      '<cmd> Debugprint search <cr>',
      mode = '',
      desc = '[Find] [D]ebug statements',
    },
  },
}
