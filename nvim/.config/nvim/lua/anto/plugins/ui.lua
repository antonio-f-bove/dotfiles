return {

  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     -- "rcarriga/nvim-notify",
  --   },
  --   opts = {
  --     presets = {
  --       -- command_palette = true,
  --       bottom_search = true,  -- use a classic bottom cmdline for search
  --       command_palette = false,
  --       inc_rename = false,    -- enables an input dialog for inc-rename.nvim
  --       long_message_to_split = true,
  --       lsp_doc_border = true, -- add a border to hover docs and signature help
  --     },
  --     notify = {
  --       enabled = false,
  --     },
  --     -- -- views = {
  --     -- --
  --     -- -- },
  --     -- routes = {
  --     --   view = 'mini',
  --     --   filter = { event = 'msg_showmode' },
  --     -- },
  --     override = {
  --       ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
  --       ["vim.lsp.util.stylize_markdown"] = true,
  --       ["cmp.entry.get_documentation"] = true,
  --     },
  --     messages = {
  --       enabled = false, -- enables the Noice messages UI
  --       --   -- view_search = false,
  --       --   view = "mini",             -- default view for messages
  --       --   view_error = "mini",       -- view for errors
  --       --   view_warn = "mini",        -- view for warnings
  --       --   view_history = "messages", -- view for :messages
  --       -- },
  --       -- lsp = {
  --       --   message = { view = "mini" }
  --     }
  --   },
  --   keys = {
  --     { '<leader><esc>', '<cmd>Noice dismiss<cr>' },
  --     {
  --       "<s-enter>",
  --       function()
  --         require("noice").redirect(vim.fn.getcmdline())
  --       end,
  --       mode = 'c',
  --       { desc = "Redirect Cmdline" }
  --     }
  --   }
  -- },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
      local theme = require 'lualine.themes.kanagawa-paper-ink'

      local function show_macro_recording()
        local recording_register = vim.fn.reg_recording()
        if recording_register == "" then
          return ""
        else
          return "Recording @" .. recording_register
        end
      end

      vim.o.cmdheight = 0

      require 'lualine'.setup({
        options = {
          icons_enabled = true,
          theme = theme,
          component_separators = '|',
          section_separators = '',
          globalstatus = true,
        },
        sections = {
          lualine_x = {
            --     {
            --       require 'noice'.api.statusline.mode.get_hl,
            --       cond = require 'noice'.api.statusline.mode.has,
            --       color = { fg = '#ff9e64' }
            --     },
            --     -- {
            --     --   require("noice").api.status.search.get_hl,
            --     --   cond = require("noice").api.status.search.has,
            --     --   color = { fg = "#ff9e64" },
            --     -- },
            { 'searchcount', }
          },
          lualine_y = { show_macro_recording },
        },
        -- winbar = {
        --   lualine_x = {},
        -- }
      })
    end,
    -- TODO: max line num instead of col num https://github.com/nvim-lualine/lualine.nvim
  },

}
