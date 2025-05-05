return {
  'kevinhwang91/nvim-bqf',
  dependecies = {
    { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
    { 'junegunn/fzf',                    run = function() vim.fn['fzf#install']() end },
  },
}
