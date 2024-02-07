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
local clean_up_group = vim.api.nvim_create_augroup('CleanUpNeotreeBuffer', { clear = true })
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
