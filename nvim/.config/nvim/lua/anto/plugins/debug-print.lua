local js_like = {
  left = 'console.trace("',
  right = '")',
  mid_var = '", ',
  right_var = ')',
}

local function signal_name(expr)
  return expr:gsub('^this%.', ''):gsub('%(%s*%)$', '')
end

local function insert_signal_effect(expr)
  expr = expr or vim.fn.expand('<cword>')
  local name = signal_name(expr)
  local id = 'DEBUGPRINT_' .. name
  local line = ('#%s = effect(() => console.log(%q, this.%s()));'):format(id, name, expr)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local indent = vim.fn.matchstr(vim.api.nvim_get_current_line(), '^%s*')

  vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. line })
  vim.cmd('silent! normal! ==')
end

return {
  'andrewferrier/debugprint.nvim',
  dependencies = {
    -- 'echasnovski/mini.nvim', -- Optional: Needed for line highlighting (full mini.nvim plugin)
    -- ... or ...
    'echasnovski/mini.hipatterns', -- Optional: Needed for line highlighting ('fine-grained' hipatterns plugin)

    -- "nvim-telescope/telescope.nvim", -- Optional: If you want to use the `:Debugprint search` command with telescope.nvim
    'folke/snacks.nvim', -- Optional: If you want to use the `:Debugprint search` command with snacks.nvim
  },

  lazy = false,  -- Required to make line highlighting work before debugprint is first used
  version = '*', -- Remove if you DON'T want to use the stable version
  opts = {
    display_counter = false,
    display_location = false,
    keymaps = {
      normal = {
        plain_below = 'g??',
      },
    },
    filetypes = {
      ['javascript'] = js_like,
      ['javascriptreact'] = js_like,
      ['typescript'] = js_like,
      ['typescriptreact'] = js_like,
    },
  },
  keys = {
    {
      '<leader>fd',
      '<cmd> Debugprint search <cr>',
      mode = '',
      desc = '[Find] [D]ebug statements',
    },
    {
      'g?s',
      function()
        insert_signal_effect()
      end,
      ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
      desc = '[D]ebug [S]ignal with effect',
    },
  },
}
