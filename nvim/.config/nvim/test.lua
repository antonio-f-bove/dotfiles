local ws = require 'anto.core.window_stack'
local lm = require 'anto.core.layout_manager'

-- ws.push_jump()

-- local result = ws.save_layout()
vim.cmd 'SaveBufferLayout'
vim.cmd 'only'
vim.cmd 'RestoreBufferLayout'
-- ws.restore_layout(result)
-- lm.print(vim.inspect(result))
