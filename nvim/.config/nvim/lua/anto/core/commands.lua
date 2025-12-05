vim.api.nvim_create_user_command('GrepRange', function(opts)
  local pattern = opts.args
  local range_start = opts.line1
  local range_end = opts.line2

  print(pattern, range_start, range_end)

  if pattern == "" then
    vim.notify(':GrepRange needs a <pattern>', vim.log.levels.ERROR)
  end

  vim.cmd("vim /" .. pattern .. '/ %')

  local qf = vim.fn.getqflist()
  local filtered = {}

  for _, item in ipairs(qf) do
    if item.lnum >= range_start and item.lnum <= range_end then
      table.insert(filtered, item)
    end
  end

  vim.fn.setqflist(filtered, 'r')
  vim.cmd("copen")
end, { nargs = "+", range = true })
