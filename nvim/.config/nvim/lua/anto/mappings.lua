local set = vim.keymap.set

local toggle_option = function(...)
	local opts = { ... }
	for _, option in ipairs(opts) do
		local curr_val = vim.api.nvim_get_option_value(option, {})
		vim.api.nvim_set_option_value(option, not curr_val, {})
	end
end

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
set('n', 'ZQ', '<cmd> qa! <cr>', { desc = 'qa!' })

set('n', '<tab>', '<cmd> bnext <cr>')
set('n', '<s-tab>', '<cmd> bprev <cr>')
-- set('n', '<leader><tab>', '<cmd> tabclose <cr>')

-- quickfix and loclist movement
set('n', ']q', '<cmd> cnext <cr>')
set('n', '[q', '<cmd> cprev <cr>')
set('n', ']Q', '<cmd> clast <cr>')
set('n', '[Q', '<cmd> cfirst <cr>')
set('n', ']l', '<cmd> lnext <cr>')
set('n', '[l', '<cmd> lprev <cr>')
set('n', ']L', '<cmd> llast <cr>')
set('n', '[L', '<cmd> lfirst <cr>')

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
set('n', '<leader>ts', function() toggle_option('spell') end)

set('n', '==', '<cmd>Format<cr>')

-- insert tricks
-- set('i', '<leader><leader>', '_')
