return {
  {
    "chrisgrieser/nvim-spider",
    keys = {
      {
        "H",
        "<cmd>lua require('spider').motion('b')<CR>",
        mode = { "n", "o", "x" },
      },
      {
        "L",
        "<cmd>lua require('spider').motion('w')<CR>",
        mode = { 'n', 'o', 'x' },
      },
    },
  },

  {
    'echasnovski/mini.bufremove',
    version = 'false',
    config = function()
      require 'mini.bufremove'.setup()
    end,
    keys = {
      { '<leader>x', '<cmd>lua MiniBufremove.delete()<CR>' },
      { '<leader>XO', function()
        require 'anto.utils'.close_other_buffers()
      end },
    }
  },

  { 'ethanholz/nvim-lastplace', opts = {} },

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
