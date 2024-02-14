-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
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

  {
    'glacambre/firenvim',
    cond = not not vim.g.started_by_firenvim,
    build = function()
      require("lazy").load({ plugins = { "firenvim" }, wait = true })
      vim.fn["firenvim#install"](0)
    end,

    -- configure FireNvim here:
    config = function()
      vim.g.firenvim_config = {
        -- config values, like in my case:
        localSettings = {
          [".*"] = {
            takeover = "never",
          },
        },
      }
    end
  },
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
}
