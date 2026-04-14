return {
  {
    'rmagatti/auto-session',
    config = function()
      vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
      require('auto-session').setup {
        log_level = 'error',
        suppress_dirs = { '~/', '~/projects', '~/Downloads', '/' },
      }

      -- FIX: not working? + make command

      --  vim.api.nvim_create_user_command('DeleteCurrentNvimAutosession', function()
      --     local sessions_path = '/home/anto/.local/share/nvim/sessions/'
      --  end)
    end,
  },

  { 'ethanholz/nvim-lastplace', opts = {} },
}
