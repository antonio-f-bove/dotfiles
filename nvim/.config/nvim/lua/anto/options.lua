vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- vim.o.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Set highlight on search
vim.o.hlsearch = true
-- vim.o.wrapscan = false

vim.o.inccommand = 'split' -- preview substitutions live, while typing

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

vim.wo.wrap = false
vim.wo.linebreak = false
vim.o.breakindent = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- vim.o.clipboard = 'unnamedplus'

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
-- vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true
vim.o.background = 'dark'

vim.opt.scrolloff = 5

vim.opt.splitright = true
vim.opt.splitbelow = true

-- Note: cf. NoSwapFiles augroup
vim.opt.autoread = true
vim.opt.swapfile = false

-- TODO: auto toggle: '' when only one window, on when window is split. Plus only buftype == '' should show winbar
vim.opt.winbar = '%=%m %f'

-- vim.o.conceallevel = 1
vim.o.conceallevel = 0

-- folding cf. https://www.jackfranklin.co.uk/blog/code-folding-in-vim-neovim/
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldcolumn = '0'
vim.o.foldtext = ''

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

vim.o.foldnestmax = 4

-- vim.o.cmdheight = 0
