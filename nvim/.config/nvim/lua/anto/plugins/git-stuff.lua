local fugitive_diff_mode = 'parent'

local function fugitive_diff_command()
  if fugitive_diff_mode == 'working' then
    return 'keepalt Gvdiffsplit'
  end

  return 'keepalt Gvdiffsplit!'
end

local function only_with_quickfix()
  vim.cmd 'only'
  vim.cmd 'silent! copen'
  vim.cmd 'wincmd p'
end

local function sync_diff_folds()
  local current_win = vim.api.nvim_get_current_win()

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_option(win, 'diff') then
      vim.api.nvim_set_current_win(win)
      vim.wo.foldmethod = 'diff'
      vim.wo.foldlevel = 0
    end
  end

  vim.api.nvim_set_current_win(current_win)
end

local function fugitive_diff_current_commit()
  only_with_quickfix()
  vim.cmd(fugitive_diff_command())
  sync_diff_folds()
end

local function fugitive_diff_quickfix_commit(command)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  only_with_quickfix()
  vim.cmd(command)
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  vim.cmd(fugitive_diff_command())
  sync_diff_folds()
end

local function fugitive_diff_quickfix_entry()
  local idx = vim.fn.line '.'
  only_with_quickfix()
  vim.cmd('cc ' .. idx)
  vim.cmd(fugitive_diff_command())
  sync_diff_folds()
end

local function toggle_fugitive_diff_mode()
  fugitive_diff_mode = fugitive_diff_mode == 'parent' and 'working' or 'parent'
  vim.notify('Fugitive diff mode: ' .. fugitive_diff_mode)

  local qflist = vim.fn.getqflist { idx = 0, size = 0 }
  if qflist.size > 0 and qflist.idx > 0 then
    fugitive_diff_quickfix_commit('cc ' .. qflist.idx)
  end
end

return {
  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
    keys = {
      { '<leader>gp', '<cmd> G pull <cr>' },
      { '<leader>gP', '<cmd> G push <cr>' },
      { '<leader>ga', ':G commit -a -m RESET' },
      {
        '<leader>gh',
        function()
          pcall(vim.keymap.del, 'n', '<c-n>')
          pcall(vim.keymap.del, 'n', '<c-p>')
          pcall(vim.keymap.del, 'n', '<c-j>')

          vim.keymap.set('n', '<c-n>', function()
            fugitive_diff_quickfix_commit 'cnext'
          end)

          vim.keymap.set('n', '<c-p>', function()
            fugitive_diff_quickfix_commit 'cprev'
          end)

          vim.keymap.set('n', '<c-j>', toggle_fugitive_diff_mode)

          local cursor_pos = vim.api.nvim_win_get_cursor(0)
          vim.cmd '0Gclog'
          vim.api.nvim_win_set_cursor(0, cursor_pos)
          fugitive_diff_current_commit()
        end,
      },
      {
        '<leader>gq',
        function()
          -- "<cmd> Gedit | ccl <cr>" },
          vim.keymap.del('n', '<c-n>')
          vim.keymap.del('n', '<c-p>')
          pcall(vim.keymap.del, 'n', '<c-j>')
          vim.keymap.set('n', '<c-n>', '<cmd> cnext <cr>')
          vim.keymap.set('n', '<c-p>', '<cmd> cprev <cr>')
          vim.cmd 'Gedit'
          vim.cmd 'ccl'
          vim.cmd 'only'
        end,
      },
      { '<leader>gB', '<cmd>G blame<cr>' }
    },
    config = function()
      local enter_commit_mess_in_insert_mode = vim.api.nvim_create_augroup('EnterCommitMessInInsertMode',
        { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          vim.cmd ':startinsert'
        end,
        group = enter_commit_mess_in_insert_mode,
        pattern = 'gitcommit',
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(event)
          vim.keymap.set('n', '<CR>', fugitive_diff_quickfix_entry, { buffer = event.buf })
        end,
        pattern = 'qf',
      })
    end,
  },
  'tpope/vim-rhubarb',
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- Keep LSP/diagnostic signs above git signs in signcolumn.
      -- sign_priority = 5,
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk { preview = true }
            vim.cmd 'norm! zz'
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk { preview = true }
            vim.cmd 'norm! zz'
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = true }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },
}
