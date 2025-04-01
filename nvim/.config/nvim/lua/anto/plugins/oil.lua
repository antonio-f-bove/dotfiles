return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["<C-s>"] = { "<cmd>w<cr>" },
      ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-v>"] = { "actions.select", opts = { vertical = true } },
    }
  },
  lazy = false,
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Oil" },
  }
}
