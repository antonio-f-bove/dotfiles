-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    -- NOTE: First, some plugins that don't require any configuration

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
      -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        { 'williamboman/mason.nvim', config = true },
        'williamboman/mason-lspconfig.nvim',

        -- Useful status updates for LSP
        { 'j-hui/fidget.nvim',       opts = {} },

        -- Additional lua configuration, makes nvim stuff amazing!
        'folke/neodev.nvim',
      },
    },

    {
      -- Autocompletion
      'hrsh7th/nvim-cmp',
      dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',

        -- Adds LSP completion capabilities
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',

        -- Adds a number of user-friendly snippets
        'rafamadriz/friendly-snippets',
      },
    },

    -- TODO: figure out null/none-ls
    -- {
    --   'nvimtools/none-ls.nvim',
    --   lazy = true,
    --   config = function()
    --     local null_ls = require 'null-ls'
    --     null_ls.setup({
    --       debug = true,
    --       sources = {
    --         -- null_ls.builtins.diagnostics.ruff,
    --         null_ls.builtins.completion.luasnip,
    --         null_ls.builtins.code_actions.refactoring,
    --         -- null_ls.builtins.formatting.rustywind,
    --       }
    --     })
    --   end
    -- },

    { 'folke/which-key.nvim', opts = {} },

    {
      'numToStr/Comment.nvim',
      opts = {
        toggler = {
          line = '<leader>/',
          block = '<leader>?',
        },
        opleader = {
          line = '<leader>/',
          block = '<leader>?',
        },
      },
    },

    {
      -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-treesitter/nvim-treesitter-context',
        'windwp/nvim-ts-autotag',
      },
      build = ':TSUpdate',
    },

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
      })

      vim.api.create_augroup('SnipeKeymaps', { clear = true })
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
