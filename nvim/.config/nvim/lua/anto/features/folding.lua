local M = {}

function M.fold_range(start_line, end_line)
  if start_line > 0 and end_line > start_line then
    vim.cmd(('%d,%dfold'):format(start_line, end_line))
  end
end

function M.textobject(_type)
  M.fold_range(vim.fn.line "'[", vim.fn.line "']")
end

function M.operator()
  vim.o.operatorfunc = "v:lua.require'anto.features.folding'.textobject"
  return 'g@'
end

function M.selection()
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  M.fold_range(start_line, end_line)
end

function M.fold_textobject(textobject)
  vim.o.operatorfunc = "v:lua.require'anto.features.folding'.textobject"
  vim.api.nvim_feedkeys('g@' .. textobject, 'm', false)
end

function M.fold_functions()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, nil, { error = false })
  if not parser then
    vim.notify('No treesitter parser for buffer', vim.log.levels.WARN, { title = 'Folding' })
    return
  end

  local query = vim.treesitter.query.get(parser:lang(), 'textobjects')
  if not query then
    vim.notify('No treesitter textobjects query for buffer', vim.log.levels.WARN, { title = 'Folding' })
    return
  end

  local captures = {
    ['function.outer'] = true,
    ['method.outer'] = true,
  }

  local ranges = {}
  local seen = {}

  for _, tree in ipairs(parser:parse()) do
    for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local capture = query.captures[id]
      if captures[capture] then
        local start_row, _, end_row, _ = node:range()
        local start_line = start_row + 1
        local end_line = end_row + 1
        local key = start_line .. ':' .. end_line

        if not seen[key] then
          seen[key] = true
          table.insert(ranges, { start_line, end_line })
        end
      end
    end
  end

  table.sort(ranges, function(a, b)
    return a[1] < b[1]
  end)

  for _, range in ipairs(ranges) do
    M.fold_range(range[1], range[2])
  end
end

function M.unfold_all()
  vim.cmd 'normal! zR'
end

function M.fold_text()
  local first_line = vim.fn.getline(vim.v.foldstart):gsub('^%s*', '')
  local line_count = vim.v.foldend - vim.v.foldstart + 1

  return ('%s -- 󰘖 %d lines'):format(first_line, line_count)
end

function M.set_window_options()
  vim.wo.foldmethod = 'manual'
  vim.wo.foldcolumn = '0'
  vim.wo.foldtext = "v:lua.require'anto.features.folding'.fold_text()"
  vim.wo.foldlevel = 99
  vim.wo.foldnestmax = 4
end

-- Manual folds, opened by default. `zf` folds motions and plugin textobjects
-- (e.g. `zfaf`, `zfai`) by driving them through operatorfunc/g@.
vim.o.foldlevelstart = 99
M.set_window_options()

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('anto_folding', { clear = true }),
  callback = function()
    M.set_window_options()
  end,
})

vim.keymap.set('n', 'zf', function()
  return M.operator()
end, { expr = true, desc = 'Fold motion/textobject' })

vim.keymap.set('x', 'zf', function()
  M.selection()
end, { desc = 'Fold selection' })

vim.keymap.set({ 'n', 'x' }, '<leader>zf', function()
  if vim.fn.mode():match '[vV\22]' then
    vim.api.nvim_feedkeys(vim.keycode '<esc>', 'n', false)
  end

  M.fold_textobject 'af'
end, { desc = 'Fold function' })

vim.api.nvim_create_user_command('FoldFunctions', function()
  M.fold_functions()
end, { desc = 'Fold all functions and methods' })

vim.api.nvim_create_user_command('UnfoldAll', function()
  M.unfold_all()
end, { desc = 'Open all folds' })

return M
