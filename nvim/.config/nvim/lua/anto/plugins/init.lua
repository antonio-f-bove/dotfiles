return {
  -- Detect tabstop and shiftwidth automatically
  -- 'tpope/vim-sleuth',
  'NMAC427/guess-indent.nvim',


  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
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
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = true,
  },

  {
    "leath-dub/snipe.nvim",
    keys = {
      { "<leader><tab>", function() require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu" }
    },
    config = function()
      require 'snipe'.setup({
        ui = {
          position = 'center',
          text_align = 'file-first',
        },
        hints = {
          dictionary = 'asdfghl'
        }
      })

      vim.api.nvim_create_augroup('SnipeKeymaps', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = 'SnipeKeymaps',
        pattern = 'snipe-menu',
        callback = function()
          vim.keymap.set('n', '<tab>', function()
            require 'snacks.picker'.buffers()
          end, { buffer = true })
        end,
      })
    end,
  }
}
