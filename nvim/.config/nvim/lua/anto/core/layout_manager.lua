-- INFO: great stackoverflow solution
-- https://vi.stackexchange.com/questions/22543/parsing-winlayout-for-toggling-multiple-windows-at-once/22545#22545

-- Storage for the layout state (now a list of states)
local state = {}

-- Recursive function to add buffer numbers to the layout tree
local function add_buf_to_layout(layout)
  if layout[1] == 'leaf' then
    -- layout[2] is the window ID in the original return from winlayout()
    local win_id = layout[2]
    -- We append the buffer number as the 3rd element
    table.insert(layout, vim.api.nvim_win_get_buf(win_id))
  else
    -- Iterate over children (rows or columns)
    for _, child_layout in ipairs(layout[2]) do
      add_buf_to_layout(child_layout)
    end
  end
end

-- Save the current layout
local function save_buffer_layout(bufnr)
  local new_state = {
    buf_layout = vim.fn.winlayout(),
    resize_cmd = vim.fn.winrestcmd(),
    bufnr = bufnr,
  }
  add_buf_to_layout(new_state.buf_layout)
  table.insert(state, new_state)
end

-- Recursive function to apply the layout
local function apply_layout(layout)
  if layout[1] == 'leaf' then
    -- The buffer number is stored in the 3rd element (index 3)
    local bufnr = layout[3]
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      -- Switch to the saved buffer
      vim.api.nvim_win_set_buf(0, bufnr)
    end
  else
    local type = layout[1]
    local children = layout[2]

    -- Determine split method
    -- 'col' in winlayout means windows stacked vertically (split)
    -- 'row' in winlayout means windows side-by-side (vsplit)
    local split_cmd = (type == 'col') and 'rightbelow split' or 'rightbelow vsplit'

    -- Keep track of the windows we are creating.
    -- We start with the current window (which will be the first child)
    local wins = { vim.api.nvim_get_current_win() }

    -- Create splits for subsequent children (starting from the 2nd child)
    for _ = 2, #children do
      vim.cmd(split_cmd)
      table.insert(wins, vim.api.nvim_get_current_win())
    end

    -- Recurse into child windows
    for i, win_id in ipairs(wins) do
      vim.api.nvim_set_current_win(win_id)
      apply_layout(children[i])
    end
  end
end

-- Restore the layout
local function restore_buffer_layout(bufnr)
  local state_to_restore
  if bufnr then
    -- Find the state with the matching buf_number
    for i, s in ipairs(state) do
      if s.bufnr == bufnr then
        -- HERE: instead of removing just this element, we should truncate the list at i (excluding i)
        state_to_restore = table.remove(state, i)
        break
      end
    end
  else
    -- Pop the last state
    if #state > 0 then
      state_to_restore = table.remove(state)
    end
  end

  if not state_to_restore then
    return false
  end

  -- Create a clean slate: new buffer, only window
  vim.cmd 'new'
  vim.cmd 'wincmd o'

  -- Recursively restore buffers
  apply_layout(state_to_restore.buf_layout)

  -- Resize windows
  if state_to_restore.resize_cmd and state_to_restore.resize_cmd ~= '' then
    vim.cmd(state_to_restore.resize_cmd)
  end

  return true
end

-- Register User Commands
vim.api.nvim_create_user_command('SaveBufferLayout', save_buffer_layout, {})
vim.api.nvim_create_user_command('RestoreBufferLayout', restore_buffer_layout, {})

return {
  save = save_buffer_layout,
  restore = restore_buffer_layout,
}
