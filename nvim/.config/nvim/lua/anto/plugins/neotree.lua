-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

-- TODO: add autocommand that closes neotree upon vim exit, neotree buffers getting saved to the session
return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require 'neo-tree'.setup({
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    })

    local group = vim.api.nvim_create_augroup('CleanUpNeotreeBuffer', { clear = true })
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
      group = group
    })
  end,
  keys = {
    { '<leader>e', '<cmd> Neotree toggle <cr>' },
  }
}
