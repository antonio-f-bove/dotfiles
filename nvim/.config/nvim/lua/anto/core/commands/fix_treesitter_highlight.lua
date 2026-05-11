vim.api.nvim_create_user_command('FixTreeSitterHighlight', function(opts)
  vim.cmd 'write | edit | TSBufEnable highlight'
end, { desc = 'Fix treesitter highlight' })
