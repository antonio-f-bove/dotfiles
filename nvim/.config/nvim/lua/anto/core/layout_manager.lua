-- INFO: great stackoverflow solution
-- https://vi.stackexchange.com/questions/22543/parsing-winlayout-for-toggling-multiple-windows-at-once/22545#22545

-- Storage for the layout state
local state = {
  buf_layout = nil,
  resize_cmd = nil,
}

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
local function save_buffer_layout()
  state.buf_layout = vim.fn.winlayout()
  state.resize_cmd = vim.fn.winrestcmd()
  add_buf_to_layout(state.buf_layout)
  print 'Buffer layout saved.'
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
local function restore_buffer_layout()
  if not state.buf_layout then
    print 'No layout saved.'
    return
  end

  -- Create a clean slate: new buffer, only window
  vim.cmd 'new'
  vim.cmd 'wincmd o'

  -- Recursively restore buffers
  apply_layout(state.buf_layout)

  -- Resize windows
  if state.resize_cmd and state.resize_cmd ~= '' then
    vim.cmd(state.resize_cmd)
  end
end

-- Register User Commands
vim.api.nvim_create_user_command('SaveBufferLayout', save_buffer_layout, {})
vim.api.nvim_create_user_command('RestoreBufferLayout', restore_buffer_layout, {})

-- return {
--   save_buffer_layout = save_buffer_layout,
--   restore_buffer_layout = restore_buffer_layout,
-- }
