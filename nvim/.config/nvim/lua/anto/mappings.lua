local set = vim.keymap.set

local toggle_option = function(...)
	local opts = {...}
	for _, option in ipairs(opts) do
		local curr_val = vim.api.nvim_get_option_value(option, {})
		print(curr_val)
		vim.api.nvim_set_option_value(option, not curr_val, {})
	end
end

-- local close_split = function()
-- 	local api = vim.api
-- 	print('yooooooooooo')
-- 	-- local buftype = vim.bo.readonly
-- 	local buftype = vim.bo.buftype
-- 	print(buftype)
-- end

set('n', '<leader>+', function()
	vim.cmd('so ' .. vim.fn.expand('%:t'))
	print('INFO: ' .. vim.fn.expand('%:t') .. ' just sourced')
end, { desc = 'Source file' })

set('i', 'jk', '<c-[>')
set('n', '<leader><leader>', '<cmd> e # <cr>')
set('n', 'Q', '@q')
set('v', 'v', "<esc>m`ggVG")

set('n', '<leader>p', '"_diwP', { desc = 'Replace <aword> w/ yanked word' })

set({ 'n', 'i' }, '<c-s>', '<cmd> w <cr>', { desc = 'Save file' })
set('n', 'ZA', '<cmd> xa <cr>', { desc = 'xa' })
-- set('n', 'ZZ', '<cmd> x <cr>', { desc = 'x' })
set('n', 'ZQ', '<cmd> qa! <cr>', { desc = 'qa!' })
-- TODO: close tab if it was the last buffer (or window) in the tab. leaderX to close buffer AND split
-- don't close vim even if it was the last buffer -> empty buffer
set('n', '<leader>x', '<cmd> bp | conf bd# <cr>') -- -> better bdelete
set('n', '<leader>X', function()
	close_split()
end)

set('n', '<tab>', '<cmd> bnext <cr>')
set('n', '<s-tab>', '<cmd> bprev <cr>')
-- set('n', '<leader><tab>', '<cmd> tabclose <cr>')

set({ 'n', 'v', 'o' }, 'gh', '^')
set({ 'n', 'v', 'o' }, 'gl', '$')

set('n', '>', '>>')
set('n', '<', '<<')
set('v', '>', '>gv')
set('v', '<', '<gv')

-- Movement in INSERT mode
set('i', '<c-h>', '<Left>')
set('i', '<c-j>', '<Down>')
set('i', '<c-k>', '<Up>')
set('i', '<c-l>', '<Right>')

-- primeagen's
set("n", "J", "mzJ`z")
set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")
set("n", "n", "nzzzv")
set("n", "N", "Nzzzv")

-- Better redo
set('n', '<c-r>', '<Nop>')
set('n', 'U', '<c-r>')

set('n', '<Esc>', '<cmd> noh <cr>', { desc = 'Clear highlights' })

set('n', '|', '<c-w>|')
set('n', '_', '<c-w>_')

-- Toggles
set('n', '<leader>tr', function() toggle_option('relativenumber') end)
set('n', '<leader>ti', '<cmd> IBLToggle <cr>')
set('n', '<leader>tw', function() toggle_option('wrap', 'linebreak') end)
set('n', '<leader>th', function() toggle_option('hlsearch') end)
-- TODO: toggle spell
