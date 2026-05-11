local function file_exists(path)
  return path and vim.uv.fs_stat(path) ~= nil
end

local function component_stem(path)
  return path:match('^(.*)%.component%.ts$')
      or path:match('^(.*)%.component%.html$')
      or path:match('^(.*)%.component%.css$')
      or path:match('^(.*)%.component%.scss$')
end

local function open_file(win, path)
  if win and path and file_exists(path) then
    vim.api.nvim_set_current_win(win)
    vim.cmd.edit(vim.fn.fnameescape(path))
  end
end

local function set_left_height(html_win, style_win)
  if not (html_win and style_win) then
    return
  end

  local total = vim.o.lines - vim.o.cmdheight
  local target = math.max(1, math.floor(total * (2 / 3)))
  pcall(vim.api.nvim_win_set_height, html_win, target)
end

vim.api.nvim_create_user_command('AngularComponentLayout', function()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local current_view = vim.fn.winsaveview()
  local current_path = vim.api.nvim_buf_get_name(current_buf)
  local stem = component_stem(current_path)

  if not stem then
    vim.notify('Not in Angular component file', vim.log.levels.WARN)
    return
  end

  vim.api.nvim_set_current_win(current_win)
  vim.cmd('silent! wincmd o')
  current_win = vim.api.nvim_get_current_win()

  local ts = stem .. '.component.ts'
  local html = stem .. '.component.html'
  local style = file_exists(stem .. '.component.css') and (stem .. '.component.css') or nil
  if not style and file_exists(stem .. '.component.scss') then
    style = stem .. '.component.scss'
  end

  local has_ts = file_exists(ts)
  local has_html = file_exists(html)
  local has_style = style ~= nil

  if not (has_ts or has_html or has_style) then
    vim.notify('No component files found', vim.log.levels.WARN)
    return
  end

  local ext = current_path:match('%.component%.([^.]+)$')
  local ts_win = ext == 'ts' and current_win or nil
  local html_win = ext == 'html' and current_win or nil
  local style_win = (ext == 'css' or ext == 'scss') and current_win or nil

  local left_count = (has_html and 1 or 0) + (has_style and 1 or 0)
  local left_win = current_win

  if ts_win == current_win then
    if left_count == 0 then
      return
    end

    vim.api.nvim_set_current_win(current_win)
    vim.cmd('leftabove vsplit')
    left_win = vim.api.nvim_get_current_win()
  elseif not ts_win and has_ts then
    vim.api.nvim_set_current_win(current_win)
    vim.cmd('rightbelow vsplit')
    ts_win = vim.api.nvim_get_current_win()
    open_file(ts_win, ts)
    left_win = current_win
  end

  if has_html and not html_win then
    if style_win == left_win then
      vim.api.nvim_set_current_win(left_win)
      vim.cmd('leftabove split')
      html_win = vim.api.nvim_get_current_win()
      open_file(html_win, html)
    else
      html_win = left_win
      open_file(html_win, html)
    end
  end

  if has_style and not style_win then
    if html_win and left_count > 1 then
      vim.api.nvim_set_current_win(html_win)
      vim.cmd('belowright split')
      style_win = vim.api.nvim_get_current_win()
      open_file(style_win, style)
    else
      style_win = left_win
      open_file(style_win, style)
    end
  end

  set_left_height(html_win, style_win)

  if vim.api.nvim_win_is_valid(current_win) then
    vim.api.nvim_set_current_win(current_win)
    pcall(vim.fn.winrestview, current_view)
  end
end, { desc = 'Open Angular component layout' })

vim.keymap.set('n', '<leader>aa', '<cmd>AngularComponentLayout<cr>')
