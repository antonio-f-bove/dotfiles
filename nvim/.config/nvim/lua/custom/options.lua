local o = vim.opt

o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

o.scrolloff = 5

o.splitright = true
o.splitbelow = true
o.undofile = true
o.autoread = true
-- NOTE: should evaluate this one
-- o.autoread

-- TODO: auto toggle: '' when only one window, on when window is split. Plus only buftype == '' should show winbar
o.winbar = '%=%m %f'
-- vim.api.nvim_create_user_command('ToggleWinbar', function() 
--
-- end)

local toggle_cursorline = vim.api.nvim_create_augroup('ToggleCursorline', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
	callback = function ()
		vim.wo.cursorline = true
	end,
	group = toggle_cursorline,
	pattern = '*',
})
vim.api.nvim_create_autocmd('BufLeave', {
	callback = function ()
		vim.wo.cursorline = false
	end,
	group = toggle_cursorline,
	pattern = '*',
})
