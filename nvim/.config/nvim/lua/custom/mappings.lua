local set = vim.keymap.set

local toggle_option = function(option)
	local curr_val = vim.api.nvim_get_option_value(option, {})
	vim.api.nvim_set_option_value(option, not curr_val, {})
end

local close_split = function ()
	local api = vim.api
	print('yo')
	-- local buftype = vim.bo.readonly
	local buftype = vim.bo.buftype
	print(buftype)
end

set('n', '<leader>+', function ()
	vim.cmd('so')
end, { desc = 'Source file' })

set('i', 'jk', '<c-[>')
set('n', '<leader><leader>', '<cmd> e # <cr>')
set('n', 'Q', '@q')

set({ 'n', 'i' }, '<c-s>', '<cmd> w <cr>', { desc = 'Save file' })
set('n', 'ZA', '<cmd> xa <cr>', { desc = 'xa' })
-- set('n', 'ZZ', '<cmd> x <cr>', { desc = 'x' })
set('n', 'ZQ', '<cmd> qa! <cr>', { desc = 'qa!' })
-- TODO: close tab if it was the last buffer (or window) in the tab. leaderX to close buffer AND split
-- don't close vim even if it was the last buffer -> empty buffer
set('n', '<leader>x', '<cmd> bp | conf bd# <cr>') -- -> better bdelete
set('n', '<leader>X', function ()
	close_split()
end)

set('n', '<tab>', '<cmd> bnext <cr>')
set('n', '<s-tab>', '<cmd> bprev <cr>')
set('n', '<leader><tab>', '<cmd> tabclose <cr>')

set({'n', 'v', 'o'}, 'gh', '^')
set({'n', 'v', 'o'}, 'gl', '$')

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
-- TODO: toggle wrap, spell

-- Noice stuff
set('n', '<leader>nn', '<cmd> Noice dismiss <cr>', { desc = 'Dismiss notifications' })
set('n', '<leader>nh', '<cmd> Noice history <cr>', { desc = 'Noice history' })
-- set('n', '<leader>nn', '<cmd> Noice dismiss <cr>', { desc = 'Dismiss notifications' })
-- set('n', '<leader>nn', '<cmd> Noice dismiss <cr>', { desc = 'Dismiss notifications' })
