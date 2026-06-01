local M = {}

function M.file_exists(path)
  return path and vim.uv.fs_stat(path) ~= nil
end

function M.component_stem(path)
  return path:match('^(.*)%.component%.ts$')
    or path:match('^(.*)%.component%.html$')
    or path:match('^(.*)%.component%.css$')
    or path:match('^(.*)%.component%.scss$')
end

function M.open_file(win, path)
  if win and path and M.file_exists(path) then
    vim.api.nvim_set_current_win(win)
    vim.cmd.edit(vim.fn.fnameescape(path))
  end
end

function M.resolve_files(stem)
  local ts = stem .. '.component.ts'
  local html = stem .. '.component.html'
  local style = M.file_exists(stem .. '.component.css') and (stem .. '.component.css') or nil

  if not style and M.file_exists(stem .. '.component.scss') then
    style = stem .. '.component.scss'
  end

  return {
    ts = ts,
    html = html,
    style = style,
    has_ts = M.file_exists(ts),
    has_html = M.file_exists(html),
    has_style = style ~= nil,
  }
end

return M
