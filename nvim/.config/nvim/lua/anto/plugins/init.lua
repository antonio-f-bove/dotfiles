-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    lazy = true,
    'navarasu/onedark.nvim',
    priority = 1000,
  },
  { "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },

  {
    'mbbill/undotree',
    config = function()
      vim.api.nvim_set_var('undotree_SetFocusWhenToggle', true)
      vim.api.nvim_set_var('undotree_WindowLayout', 3)
      vim.api.nvim_set_var('undotree_SplitWidth', 32)
    end,
    opts = {},
    lazy = true,
    keys = {
      { '<leader>u', '<cmd> UndotreeToggle <cr>', desc = ':UndotreeToggle' },
    },
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = true,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    },
  },
}
