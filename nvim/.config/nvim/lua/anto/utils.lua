local M = {}

M.close_other_buffers = function()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_buf then
      -- require 'mini.bufremove'.delete(buf)
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end

M.list_visible_wins = function(tab_id)
  if not tab_id then
    tab_id = 0
  end

  local visible_wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab_id)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local is_listed = vim.fn.buflisted(buf) == 1
    if is_listed then
      table.insert(visible_wins, win)
    end
  end

  return visible_wins
end

return M
