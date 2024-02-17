local utils = require 'anto.utils'


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
local just_called_smart_center = false
local smart_center_win_group = vim.api.nvim_create_augroup('SmartCenterWin', { clear = true })
vim.api.nvim_create_autocmd({ 'VimResized', 'VimEnter' }, {
  pattern = '*',
  callback = function()
    print 'called'
    -- debounce
    if just_called_smart_center then
      print 'just called!'
      -- just_called_smart_center = false
      return
    end

    print 'executed'
    just_called_smart_center = true
    vim.defer_fn(function()
      just_called_smart_center = false
      print 'can call again'
    end, 2000)

    local vim2screen_ratio = utils.get_vim2screen_ratio()
    local win_list_len = #utils.list_visible_wins()

    if (vim2screen_ratio > 0.75) and (win_list_len == 1) then
      -- HACK: defer zen-mode opening to get around yabai redrawing more than once
      -- when maximizing a window (because of gaps!)
      -- vim.defer_fn(require 'zen-mode'.open, 300)
      require 'zen-mode'.open()
      return
    else
      require 'zen-mode'.close()
    end
  end,
  group = smart_center_win_group,
})
