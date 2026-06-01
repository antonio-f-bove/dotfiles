local component = require 'anto.core.commands.angular_component_utils'

vim.api.nvim_create_user_command('AngularTemplateStyleLayout', function()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local current_view = vim.fn.winsaveview()
  local current_path = vim.api.nvim_buf_get_name(current_buf)
  local stem = component.component_stem(current_path)

  if not stem then
    vim.notify('Not in Angular component file', vim.log.levels.WARN)
    return
  end

  vim.api.nvim_set_current_win(current_win)
  vim.cmd('silent! wincmd o')
  current_win = vim.api.nvim_get_current_win()

  local files = component.resolve_files(stem)
  if not (files.has_html or files.has_style) then
    vim.notify('No html or style component files found', vim.log.levels.WARN)
    return
  end

  local ext = current_path:match('%.component%.([^.]+)$')
  local html_win = ext == 'html' and current_win or nil
  local style_win = (ext == 'css' or ext == 'scss') and current_win or nil
  local left_win = current_win

  if files.has_html then
    html_win = current_win
    component.open_file(html_win, files.html)
    left_win = html_win
  end

  if files.has_style then
    if files.has_html then
      vim.api.nvim_set_current_win(left_win)
      vim.cmd('rightbelow vsplit')
      style_win = vim.api.nvim_get_current_win()
      component.open_file(style_win, files.style)
    else
      style_win = current_win
      component.open_file(style_win, files.style)
    end
  end

  if vim.api.nvim_win_is_valid(current_win) then
    vim.api.nvim_set_current_win(current_win)
    pcall(vim.fn.winrestview, current_view)
  end
end, { desc = 'Open Angular template/style layout' })
