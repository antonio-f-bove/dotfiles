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

-- NOTE: shamelessly stolen from https://github.com/ibhagwan/fzf-lua/blob/f7f54dd685cfdf5469a763d3a00392b9291e75f2/lua/fzf-lua/utils.lua#L240
local tbl_length = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

M.get_visual_selection = function()
  -- this will exit visual mode
  -- use 'gv' to reselect the text
  local _, csrow, cscol, cerow, cecol
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '' then
    -- if we are in visual mode use the live position
    _, csrow, cscol, _ = unpack(vim.fn.getpos("."))
    _, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
    if mode == 'V' then
      -- visual line doesn't provide columns
      cscol, cecol = 0, 999
    end
    -- exit visual mode
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Esc>",
        true, false, true), 'n', true)
  else
    -- otherwise, use the last known visual position
    _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  end
  -- swap vars if needed
  if cerow < csrow then csrow, cerow = cerow, csrow end
  if cecol < cscol then cscol, cecol = cecol, cscol end
  local lines = vim.fn.getline(csrow, cerow)
  -- local n = cerow-csrow+1
  local n = tbl_length(lines)
  if n <= 0 then return '' end
  lines[n] = string.sub(lines[n], 1, cecol)
  lines[1] = string.sub(lines[1], cscol)
  return table.concat(lines, "\n")
end

return M
