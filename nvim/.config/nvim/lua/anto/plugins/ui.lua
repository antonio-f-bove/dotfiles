return {

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      presets = {
        -- command_palette = true,
        bottom_search = true,  -- use a classic bottom cmdline for search
        command_palette = false,
        inc_rename = false,    -- enables an input dialog for inc-rename.nvim
        long_message_to_split = true,
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
      -- notify = {
      --   enabled = false,
      -- },
      -- -- views = {
      -- --
      -- -- },
      -- routes = {
      --   view = 'mini',
      --   filter = { event = 'msg_showmode' },
      -- },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      -- messages = {
      --   enabled = true,            -- enables the Noice messages UI
      --   -- view_search = false,
      --   view = "mini",             -- default view for messages
      --   view_error = "mini",       -- view for errors
      --   view_warn = "mini",        -- view for warnings
      --   view_history = "messages", -- view for :messages
      -- },
      -- lsp = {
      --   message = { view = "mini" }
      -- }
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    keys = {
      { '<leader><esc>', '<cmd>Noice dismiss<cr>', { 'n' } },
      {
        "<s-enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = 'c',
        { desc = "Redirect Cmdline" }
      }
    }
  },

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
            ['<cr>'] = (#require 'anto.utils'.is_vim_single_win() == 1 and 'open') or 'open_with_window_picker',
            ['<c-v>'] = 'open_vsplit',
            ['v'] = 'open_vsplit',
            ['<c-s>'] = 'open_split',
            ['s'] = 'open_split',
          }
        }
      })
    end,
    keys = {
      { '<leader>e',  '<cmd> Neotree toggle <cr>' },
      { '<c-w><c-w>', '<cmd> Neotree focus <cr>' },
    }
  },

  {
    -- NOTE: keeping the winbar is not an option for now
    "folke/zen-mode.nvim",
    lazy = true,
    event = 'VeryLazy',
    keys = {
      { '<leader>zz', '<cmd> ZenMode <cr>', 'ZenMode' },
    },
    opts = {
      window = {
        backdrop = 0,
        width = 150,
        options = {
          number = true,
          relativenumber = true,
          signcolumn = "yes",
        },
      },
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = false,
        },
        tmux = { enabled = false }, -- disables the tmux statusline
      },
      on_open = function(win)
        -- vim.print(win)
        -- vim.cmd('Neotree action=close')
        -- vim.cmd('UndotreeClose')
      end,
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    config = function()
      local theme = require 'lualine.themes.catppuccin-macchiato'
      theme.normal.c.bg = nil

      require 'lualine'.setup({
        options = {
          icons_enabled = true,
          theme = 'catppuccin-macchiato',
          component_separators = '|',
          section_separators = '',
          globalstatus = true,
        },
        sections = {
          lualine_x = {
            {
              require 'noice'.api.statusline.mode.get_hl,
              cond = require 'noice'.api.statusline.mode.has,
              color = { fg = '#ff9e64' }
            },
            -- {
            --   require("noice").api.status.search.get_hl,
            --   cond = require("noice").api.status.search.has,
            --   color = { fg = "#ff9e64" },
            -- },
            {
              'searchcount',
              maxcount = 999,
              timeout = 500,
            }
          }
        }
      })
    end,
    -- TODO: max line num instead of col num https://github.com/nvim-lualine/lualine.nvim
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    config = function()
      require 'ibl'.setup({
        indent = {
          char = "▏", -- This is a slightly thinner char than the default one, check :help ibl.config.indent.char
        },
        scope = {
          enabled = false,
          show_start = false,
          show_end = false,
        }
      })
      -- disable indentation on the first level
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
    end,
  },
}
