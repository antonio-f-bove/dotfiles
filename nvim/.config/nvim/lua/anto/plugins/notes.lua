local notes_dir = vim.fn.getenv 'NOTES_HOME'

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons', 'saghen/blink.cmp' },
    ---
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      heading = {
        sign = false,
        -- signs = {},
        backgrounds = {},
      },
      checkbox = {
        custom = {
          todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
          cancelled = { raw = '[!]', rendered = '󰜺 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
        },
      },
      completions = { blinck = { enabled = true } },
    },
  },
  {
    'zk-org/zk-nvim',
    event = {
      'BufReadPre ' .. notes_dir .. '/*.md',
      'BufNewFile ' .. notes_dir .. '/*.md',
    },
    config = function()
      require('zk').setup {
        -- Can be "telescope", "fzf", "fzf_lua", "minipick", "snacks_picker",
        -- or select" (`vim.ui.select`).
        picker = 'snacks_picker',

        lsp = {
          -- `config` is passed to `vim.lsp.start(config)`
          config = {
            name = 'zk',
            cmd = { 'zk', 'lsp' },
            filetypes = { 'markdown' },
            -- on_attach = ...
            -- etc, see `:h vim.lsp.start()`
          },

          -- automatically attach buffers in a zk notebook that match the given filetypes
          auto_attach = {
            enabled = true,
          },
        },
      }
    end,
  },
}
