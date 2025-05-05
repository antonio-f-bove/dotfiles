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

-- [[
-- checks if vim shows only one visible window, excluding zen-mode's floating window and
-- neo-tree. Should refine this
-- ]]
M.is_vim_single_win = function(tab_id)
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

  local non_floating = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == ''
  end, visible_wins)

  return #non_floating == 1
end

-- M.get_vim2screen_ratio = function()
--   local tot_screen_width = vim.fn.system("yabai -m query --displays --display | jq '.frame.w'")
--   local vim_win_width = vim.fn.system(
--     [[yabai -m query --windows --space | jq '.[] | select(.app == "Alacritty") | .frame.w']])
--
--   return vim_win_width / tot_screen_width
-- end

local active_throttles = {}
M.throttle = function(callback, id, debounce_time)
  if not debounce_time then
    debounce_time = 100
  end

  if active_throttles[id] then
    print 'too soon!'
    return
  end

  active_throttles[id] = true
  vim.defer_fn(function() active_throttles[id] = nil end, debounce_time)
  callback()
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

M.get_path_to_deps = function()
  local cwd = vim.fn.getcwd()
  -- print('cwd: ' .. cwd)

  local lang_to_meta_map = {
    ts = {
      test = { 'package.json', 'tsconfig.json', 'jsconfig.json' },
      target = cwd .. '/node_modules',
    },
    lua = {
      -- FIX: this is generic to a lua project, should be more specific to nvim config
      test = { 'init.lua', 'main.lua', '.luarc.json' },
      target = vim.fn.expand('~') .. '/.local/share/nvim/lazy',
    }
  }

  for _, v in pairs(lang_to_meta_map) do
    for _, file in ipairs(v.test) do
      -- print(file)
      if vim.fn.filereadable(cwd .. '/' .. file) == 1 then
        return { v.target }
      end
    end
  end

  error('No valid dependency path found for this project!')
end

M.move_lines = function(direction)
  -- Get visual selection range
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  -- Get cursor and visual start positions to determine selection direction
  local cursor_line = vim.fn.line(".")
  local visual_line = vim.fn.getpos("v")[2]
  local is_cursor_on_top = cursor_line <= visual_line

  -- Can't move above line 1 or below last line
  if direction == "up" and start_line == 1 then return end
  if direction == "down" and end_line == vim.fn.line("$") then return end

  -- Move lines
  local target_line = (direction == "up" and start_line or end_line) + (direction == "up" and -1 or 1)
  vim.cmd(string.format(":'<,'>move %d", target_line))

  -- Adjust lines after move
  local delta = direction == "up" and -1 or 1
  start_line = start_line + delta
  end_line = end_line + delta

  -- Reselect lines in the same direction they were originally selected
  local new_cursor_line = is_cursor_on_top and start_line or end_line
  local new_anchor_line = is_cursor_on_top and end_line or start_line

  -- Restore selection
  vim.api.nvim_win_set_cursor(0, { new_cursor_line, 0 })
  vim.cmd("normal! V")
  vim.api.nvim_win_set_cursor(0, { new_anchor_line, 0 })
  vim.cmd("normal! V")

  -- Re-indent
  vim.cmd("normal! =")
end
return M
