return {
  -- Detect tabstop and shiftwidth automatically
  -- 'tpope/vim-sleuth',
  'NMAC427/guess-indent.nvim',

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
    -- config = function()
    --   -- BUG: doesn't work -> https://github.com/windwp/nvim-autopairs#you-need-to-add-mapping-cr-on-nvim-cmp-setupcheck-readmemd-on-nvim-cmp-repo
    --   local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    --   local cmp = require('cmp')
    --   cmp.event:on(
    --     'confirm_done',
    --     cmp_autopairs.on_confirm_done()
    --   )
    -- end,
  },

  {
    'kylechui/nvim-surround',
    version = '^3.0.0', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = true,
  },
}
