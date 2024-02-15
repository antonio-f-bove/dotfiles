local M = {}

M.close_other_buffers = function()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_buf then
      -- require 'mini.bufremove'.delete(buf)
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end

return M
