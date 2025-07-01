local vault_path = vim.fn.getenv 'VAULT_PATH'
-- print('init', vault_path)

local function to_id_string(str)
  return str:gsub('[^%w%s]', ''):lower():gsub('^%s+', ''):gsub('%s+$', ''):gsub('%s+', '-')
end

local function get_date_string(human_readable)
  if human_readable then
    return os.date '%A %d %b %Y, %H:%M'
  end

  return os.date '%Y%m%d%H%M'
end

return {
  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  --
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   opts = {
  --     heading = {
  --       sign = false,
  --       -- signs = {},
  --       backgrounds = {},
  --     },
  --     checkbox = {
  --       custom = {
  --         todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
  --         cancelled = { raw = '[!]', rendered = '󰜺 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
  --       },
  --     },
  --   },
  -- },
  {
    'zk-org/zk-nvim',
    event = {
      'BufReadPre ' .. vault_path .. '/*.md',
      'BufNewFile ' .. vault_path .. '/*.md',
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
