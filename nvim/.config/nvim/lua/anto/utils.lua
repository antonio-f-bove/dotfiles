local M = {}

M.close_other_buffers = function()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_buf then
      -- TODO: ask if written buffer may save the changes?
      require 'mini.bufremove'.delete(buf)
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

M.get_vim2screen_ratio = function()
  -- vim.fn.system("yabai -m query --windows --space | jq '. | length'")
  local tot_screen_width = vim.fn.system("yabai -m query --displays --display | jq '.frame.w'")
  local vim_win_width = vim.fn.system(
    [[yabai -m query --windows --space | jq '.[] | select(.app == "Alacritty") | .frame.w']])

  return vim_win_width / tot_screen_width
end

return M
