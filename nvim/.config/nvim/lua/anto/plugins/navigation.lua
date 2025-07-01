return {

  {
    'christoomey/vim-tmux-navigator',
    lazy = true,
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
    },
  },

  {
    'RRethy/vim-illuminate',
    -- event = "LazyFile", -- INFO: https://github.com/LazyVim/LazyVim/discussions/1583
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { 'lsp' },
      },
      filetypes_denylist = {
        'fugitive',
        'help',
        'checkhealth',
      },
    },
    config = function(_, opts)
      require('illuminate').configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set('n', key, function()
          require('illuminate')['goto_' .. dir .. '_reference'](false)
          vim.cmd 'norm! zz'
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference', buffer = buffer })
      end

      map(']]', 'next')
      map('[[', 'prev')

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map(']]', 'next', buffer)
          map('[[', 'prev', buffer)
        end,
      })
    end,
    keys = {
      { ']]', desc = 'Next Reference' },
      { '[[', desc = 'Prev Reference' },
    },
  },

  {
    'ggandor/leap.nvim',
    config = function()
      require('leap').create_default_mappings()
      -- require'leap.user'.set_repeat_keys('<enter>', '<backspace>')
    end,
    -- TODO:
    -- dependencies = {
    --   'repeat.vim'
    -- }
  },

  {
    'chrisgrieser/nvim-spider',
    keys = {
      {
        'gh',
        "<cmd>lua require('spider').motion('b')<CR>",
        mode = { 'n', 'o', 'x' },
      },
      {
        'gl',
        "<cmd>lua require('spider').motion('w')<CR>",
        mode = { 'n', 'o', 'x' },
      },
    },
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'

      harpoon.setup {}

      vim.keymap.set('n', '<leader>|', function()
        print 'hello ;'
        harpoon:list():add()
      end)
      vim.keymap.set('n', '<leader>\\', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      vim.keymap.set('n', 'H', function()
        harpoon:list():prev()
      end)
      vim.keymap.set('n', 'L', function()
        harpoon:list():next()
      end)
    end,
  },

  -- {
  --     "leath-dub/snipe.nvim",
  --     keys = {
  --       { "<leader><tab>", function() require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu" }
  --     },
  --     config = function()
  --       require 'snipe'.setup({
  --         ui = {
  --           position = 'center',
  --           text_align = 'file-first',
  --         },
  --         hints = {
  --           dictionary = 'asdfghl'
  --         }
  --       })
  --
  --       vim.api.nvim_create_augroup('SnipeKeymaps', { clear = true })
  --       vim.api.nvim_create_autocmd('FileType', {
  --         group = 'SnipeKeymaps',
  --         pattern = 'snipe-menu',
  --         callback = function()
  --           vim.keymap.set('n', '<tab>', function()
  --             require 'snacks.picker'.buffers()
  --           end, { buffer = true })
  --         end,
  --       })
  --     end,
  --   }
}
