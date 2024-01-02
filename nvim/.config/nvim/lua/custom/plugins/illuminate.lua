return {
    'RRethy/vim-illuminate',
    lazy = true,
    event = 'BufEnter',
    config = function ()
      require'illuminate'.configure({
        filetypes_denylist = {
          'fugitive', 'help', 'checkhealth'
        },
      })
      vim.keymap.set('n', ']]', function ()
        require'illuminate'.goto_next_reference()
      end, { desc = 'goto next reference' })
      vim.keymap.set('n', '[[', function ()
        require'illuminate'.goto_prev_reference()
      end, { desc = 'goto prev reference' })
    end
  }
