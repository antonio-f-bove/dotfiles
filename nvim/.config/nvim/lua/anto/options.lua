vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

vim.wo.wrap = false
vim.wo.linebreak = false

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

vim.opt.scrolloff = 5

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.autoread = true
-- NOTE: should evaluate this one
-- o.autoread

-- TODO: auto toggle: '' when only one window, on when window is split. Plus only buftype == '' should show winbar
vim.opt.winbar = '%=%m %f'
-- vim.wo.winbar = nil
-- vim.api.nvim_create_autocmd('BufWinEnter', {
--   pattern = '*',
--   callback = function(args)
--     local buftype = vim.api.nvim_buf_get_option(args.buf, 'buftype')
--     print(buftype)
--     if buftype == '' then
--       print('yes ' .. args.file)
--       vim.wo.winbar = '%=%m %f'
--     else
--       print('no ' .. args.file)
--     end
--   end,
--   group = vim.api.nvim_create_augroup('SetWinbarOnNormalBufs', { clear = true })
-- })
-- vim.api.nvim_create_user_command('ToggleWinbar', function()
--   local wb = vim.wo.winbar
--   print('before ' .. wb)
--   if wb == nil then
--     vim.wo.winbar = '%=%m %f'
--   else
--     vim.wo.winbar = ''
--   end
--   print('after ' .. wb)
-- end, { desc = 'Toggle winbar'})

local toggle_cursorline = vim.api.nvim_create_augroup('ToggleCursorline', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.wo.cursorline = true
  end,
  group = toggle_cursorline,
  pattern = '*',
})
vim.api.nvim_create_autocmd('BufLeave', {
  callback = function()
    vim.wo.cursorline = false
  end,
  group = toggle_cursorline,
  pattern = '*',
})
