local utils = require 'anto.utils'

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local toggle_cursorline_group = vim.api.nvim_create_augroup('ToggleCursorline', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.wo.cursorline = true
  end,
  group = toggle_cursorline_group,
  pattern = '*',
})
vim.api.nvim_create_autocmd('BufLeave', {
  callback = function()
    vim.wo.cursorline = false
  end,
  group = toggle_cursorline_group,
  pattern = '*',
})


-- NOTE: Takes care of some of the buffers I don't want saved to the session when closing Neovim
local clean_up_group = vim.api.nvim_create_augroup('CleanUpBuffers', { clear = true })
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    local buf_handles = vim.api.nvim_list_bufs()

    for _, buffer in ipairs(buf_handles) do
      -- NOTE: could be abstracted into clean-up function
      local buftype = vim.api.nvim_buf_get_option(buffer, 'buftype')
      if buftype == 'nofile' then
        vim.api.nvim_buf_delete(buffer, {})
      end
    end
  end,
  group = clean_up_group
})

local no_swap_files_group = vim.api.nvim_create_augroup('NoSwapFiles', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  group = no_swap_files_group,
  pattern = '*',
  command = 'checktime',
})

local transparent_vim = vim.api.nvim_create_augroup('TransparentVim', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = transparent_vim,
  callback = function(ev)
    local highlights = {
      'Normal',
      'LineNr',
      'Folded',
      'NonText',
      'SpecialKey',
      'VertSplit',
      'SignColumn',
      'EndOfBuffer',
      -- 'TablineFill', -- this is specific to how I like my tabline to look like
    }
    for _, name in pairs(highlights) do vim.cmd.highlight(name .. ' guibg=none ctermbg=none') end
  end,
})


-- TODO: make it work with neotree
local smart_center_win_group = vim.api.nvim_create_augroup('SmartCenterWin', { clear = true })
vim.api.nvim_create_autocmd({ 'VimResized', 'VimEnter' }, {
  pattern = '*',
  callback = function(args)
    local vim2screen_ratio = vim.o.columns / vim.o.lines
    local is_sigle_window = utils.is_vim_single_win()
    print('ratio:' .. vim2screen_ratio .. '|is_single:', is_sigle_window)

    if (vim2screen_ratio > 3.1) and is_sigle_window then
      require 'zen-mode'.open()
    else
      require 'zen-mode'.close()
    end
  end,
  group = smart_center_win_group,
})
