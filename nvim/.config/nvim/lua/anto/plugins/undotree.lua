return {

  {
    'mbbill/undotree',
    config = function()
      vim.api.nvim_set_var('undotree_SetFocusWhenToggle', true)
      vim.api.nvim_set_var('undotree_WindowLayout', 3)
      vim.api.nvim_set_var('undotree_SplitWidth', 32)
    end,
    opts = {},
    lazy = true,
    keys = {
      { '<leader>u', '<cmd> UndotreeToggle <cr>', desc = ':UndotreeToggle' },
    },
  },

}
