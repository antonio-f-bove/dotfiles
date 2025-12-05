local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context',
      'windwp/nvim-ts-autotag',
    },
    build = ':TSUpdate',
  },

  { import = 'anto.plugins' },
  -- { import = 'anto.plugins.lsp' },
}, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})

-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'go', 'lua', 'python', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'markdown', 'markdown_inline', 'html', 'angular' },

    auto_install = true,

    highlight = { enable = true },
    indent = { enable = true },
    autotag = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<cr>',
        node_incremental = '<cr>',
        scope_incremental = '<M-cr>', -- FIX: alacritty might not allow it
        node_decremental = '<bs>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          -- [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          -- [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          -- ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          -- ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a>'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>a<'] = '@parameter.inner',
        },
      },
    },
  }

  require('treesitter-context').setup {
    enable = true,
    max_lines = 2,
    -- trim_scope = '',
    line_numbers = true,
    mode = 'cursor',
    on_attach = function(buf)
      -- exclude html
      local filetype = vim.bo[buf].filetype
      return filetype ~= 'html'
    end,
  }
  -- Toggle
  vim.keymap.set('n', '<leader>tc', '<cmd>TSContextToggle<cr>', { desc = 'Toggle context', silent = true })
end, 0)
