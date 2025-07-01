return {
  { 'rebelot/kanagawa.nvim' },

  {
    'thesimonho/kanagawa-paper.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },

  { 'dasupradyumna/midnight.nvim', lazy = false, priority = 1000 },

  { 'navarasu/onedark.nvim', lazy = true },

  { 'catppuccin/nvim', lazy = true, name = 'catppuccin' },

  {
    'scottmckendry/cyberdream.nvim',
    lazy = false,
    config = function()
      require('cyberdream').setup {
        variant = 'default',
      }
    end,
  },
}
