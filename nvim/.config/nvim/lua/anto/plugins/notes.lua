local notes_dir = vim.fn.getenv 'NOTES_HOME'

local function list_zk_commands()
  local commands = {
    { cmd = 'ZkNotes', desc = 'Open notes picker' },
    { cmd = 'ZkNew', desc = 'Create new note', opts = { 'title' } },
    { cmd = 'ZkMatch', desc = 'Search notes with match' },
    { cmd = 'ZkEdit', desc = 'Edit notes' },
    { cmd = 'ZkTags', desc = 'List all tags' },
    { cmd = 'ZkBacklinks', desc = 'Show backlinks for current note' },
    { cmd = 'ZkCd', desc = 'Change to notebook directory' },
    { cmd = 'ZkIndex', desc = 'Index the notebook' },
    { cmd = 'ZkBuffers', desc = 'Show buffers in notebook' },
  }

  vim.ui.select(commands, {
    prompt = 'Zk commands',
    format_item = function(item)
      return item.cmd .. ' ' .. item.desc
    end,
  }, function(choice)
    if not choice then
      return
    end

    local opts = {}
    if choice.opts then
      local function collect_inputs(i)
        if i > #choice.opts then
          require('zk.commands').get(choice.cmd)(opts)
          return
        end
        local opt = choice.opts[i]
        vim.ui.input({
          prompt = opt .. ': ',
        }, function(input)
          if input and input ~= '' then
            opts[opt] = input
          end
          collect_inputs(i + 1)
        end)
      end
      collect_inputs(1)
    else
      require('zk.commands').get(choice.cmd) {}
    end
  end)
end

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
    keys = {
      {
        '<leader>zn',
        list_zk_commands,
        mode = { 'n', 'x' },
        desc = 'List zk commands',
      },
    },
  },
}
