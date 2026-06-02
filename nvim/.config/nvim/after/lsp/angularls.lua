local utils = require 'anto.utils'

return {
  root_dir = function(bufnr, on_dir)
    local root = utils.angular_root(bufnr)

    if root then
      on_dir(root)
    end
  end,
}
