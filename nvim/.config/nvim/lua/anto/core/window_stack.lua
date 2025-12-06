local M = {}

-- destination_bufnr -> layout
local jump_stack = {}

function M.push_jump()
  table.insert(jump_stack, M.save_layout())

  local bufnr = vim.api.nvim_get_current_buf()
  print('bn ' .. tostring(bufnr))
  vim.keymap.set('n', )
end

-- Save the current window layout and associated buffers
function M.save_layout()
  local layout = vim.fn.winlayout()
  -- print('in layout ' .. vim.inspect(layout))
  local buffers = {}
  local function collect_buffers(node)
    if node[1] == 'leaf' then
      table.insert(buffers, vim.api.nvim_win_get_buf(node[2]))
    else
      for i = 2, #node do
        collect_buffers(node[i])
      end
    end
  end
  collect_buffers(layout)
  return { layout = layout, buffers = buffers }
end

-- Restore a saved window layout and buffers
function M.restore_layout(state)
  vim.cmd 'only' -- Close all splits to start fresh
  local layout = state.layout
  local buffers = state.buffers
  local idx = 1
  local function recreate(node)
    if node[1] == 'leaf' then
      vim.api.nvim_win_set_buf(0, buffers[idx])
      idx = idx + 1
    else
      local cmd = node[1] == 'vsplit' and 'vsplit' or 'split'
      vim.cmd(cmd)
      if node[1] == 'vsplit' then
        vim.cmd 'wincmd h' -- Focus left window
      else
        vim.cmd 'wincmd k' -- Focus top window
      end
      recreate(node[2])
      vim.cmd 'wincmd l' -- Focus right/bottom window
      recreate(node[3])
    end
  end
  recreate(layout)
end

function M.pop_jump()
  if #jump_stack > 0 then
    local state = table.remove(jump_stack)
    M.restore_layout(state)
    return true
  end
  return false
end

return M
