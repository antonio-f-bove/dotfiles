return {
  { "rebelot/kanagawa.nvim" },
  {
    "thesimonho/kanagawa-paper.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    -- config = function()
    --   vim.cmd('colorscheme kanagawa-paper')
    -- end
  },
  {
    lazy = true,
    'navarasu/onedark.nvim',
    priority = 1000,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    -- priority = 1000,
    -- config = function()
    --   vim.cmd.colorscheme 'catppuccin-mocha'
    -- end,
  },
}
