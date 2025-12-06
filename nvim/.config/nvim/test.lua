local ws = require 'anto.core.window_stack'

-- ws.push_jump()

local result = ws.save_layout()
print(vim.inspect(result))
