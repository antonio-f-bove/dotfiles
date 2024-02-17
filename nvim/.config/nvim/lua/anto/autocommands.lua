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


-- TODO: make it work with neotree
local smart_center_win_group = vim.api.nvim_create_augroup('SmartCenterWin', { clear = true })
vim.api.nvim_create_autocmd({ 'VimResized', 'VimEnter' }, {
  pattern = '*',
  callback = function()
    local u = require 'anto.utils'

    local vim2screen_ratio = u.get_vim2screen_ratio()
    local win_list_len = #u.list_visible_wins()

    if (vim2screen_ratio > 0.75) and (win_list_len == 1) then
      -- HACK: defer zen-mode opening to get around yabai redrawing more than once
      -- when maximizing a window (because of gaps!)
      vim.defer_fn(require 'zen-mode'.open, 300)
      vim.print(vim2screen_ratio, win_list_len)
      return
    else
      require 'zen-mode'.close()
    end
  end,
  group = smart_center_win_group,
})
