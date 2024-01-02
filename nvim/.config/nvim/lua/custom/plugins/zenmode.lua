  return {
    "folke/zen-mode.nvim",
    lazy = true,
    keys = {
      { '<leader>zz', '<cmd> ZenMode <cr>', 'ZenMode'},
    },
    opts = {
      window = {
        backdrop = 1,
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
        },
      },
      plugins = {
        options = {
          -- ruler = true,
          -- showcmd = true,
          laststatus = 0,
        },
        tmux = { enabled = true },
        gitsigns = { enabled = false },
      },
    }
  }
