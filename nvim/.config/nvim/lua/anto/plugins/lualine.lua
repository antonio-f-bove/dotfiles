return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
      local theme = require 'lualine.themes.kanagawa-paper-ink'

      local function show_macro_recording()
        local recording_register = vim.fn.reg_recording()
        if recording_register == '' then
          return ''
        else
          return 'Recording @' .. recording_register
        end
      end

      vim.o.cmdheight = 0

      require('lualine').setup {
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
            { 'searchcount' },
          },
          lualine_y = { show_macro_recording },
        },
        -- winbar = {
        --   lualine_x = {},
        -- }
      }
    end,
    -- TODO: max line num instead of col num https://github.com/nvim-lualine/lualine.nvim
  },
}
