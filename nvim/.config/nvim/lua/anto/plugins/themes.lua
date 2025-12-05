return {
  { 'rebelot/kanagawa.nvim' },

  {
    'thesimonho/kanagawa-paper.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      vim.cmd.colorscheme 'kanagawa-paper'
    end,
  },

  { 'dasupradyumna/midnight.nvim', lazy = false, priority = 1000 },

  { 'navarasu/onedark.nvim', lazy = true },

  { 'catppuccin/nvim', lazy = true, name = 'catppuccin' },

  {
    'scottmckendry/cyberdream.nvim',
    lazy = false,
    -- config = function()
    --   require('cyberdream').setup {
    --     variant = 'default',
    --   }
    -- end,
  },
}
