return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      {
        's1n7ax/nvim-window-picker',
        version = '2.*',
        config = function()
          require 'window-picker'.setup({
            hint = 'floating-big-letter',
            filter_rules = {
              include_current_win = false,
              autoselect_one = true,
              -- filter using buffer options
              bo = {
                -- if the file type is one of following, the window will be ignored
                filetype = { 'neo-tree', "neo-tree-popup", "notify" }, -- TODO: filter fidget
                -- if the buffer type is one of following, the window will be ignored
                buftype = { 'terminal', "quickfix" },
              },
            },
          })
        end,
      },
    },
    config = function()
      -- Unless you are still migrating, remove the deprecated commands from v1.x
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true },
        },
        window = {
          mappings = {
            ['<cr>'] = (#require 'anto.utils'.list_visible_wins() == 1 and 'open') or 'open_with_window_picker',
            ['<c-v>'] = 'open_vsplit',
            ['v'] = 'open_vsplit',
            ['<c-s>'] = 'open_split',
            ['s'] = 'open_split',
          }
        }
      })
    end,
    keys = {
      { '<leader>e', '<cmd> Neotree toggle <cr>' },
      { '<c-n>',     '<cmd> Neotree focus <cr>' },
    }
  },

  {
    "folke/zen-mode.nvim",
    lazy = true,
    keys = {
      { '<leader>zz', '<cmd> ZenMode <cr>', 'ZenMode' },
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
}
