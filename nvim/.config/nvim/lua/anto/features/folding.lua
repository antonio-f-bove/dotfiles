local M = {}

function M.textobject(_type)
  local start_line = vim.fn.line "'["
  local end_line = vim.fn.line "']"

  if start_line > 0 and end_line >= start_line then
    vim.cmd(('%d,%dfold'):format(start_line, end_line))
  end
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

  vim.cmd(('%d,%dfold'):format(start_line, end_line))
end

-- Manual folds, opened by default. `zf` folds motions and plugin textobjects
-- (e.g. `zfaf`, `zfai`) by driving them through operatorfunc/g@.
vim.o.foldmethod = 'manual'
vim.o.foldcolumn = '0'
vim.o.foldtext = ''
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldnestmax = 4

vim.keymap.set('n', 'zf', function()
  return M.operator()
end, { expr = true, desc = 'Fold motion/textobject' })

vim.keymap.set('x', 'zf', function()
  M.selection()
end, { desc = 'Fold selection' })

return M
