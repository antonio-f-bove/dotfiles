local ts_langs = { 'go', 'lua', 'python', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'markdown',
  'markdown_inline', 'html', 'angular' }

local function get_current_node()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, nil, { error = false })
  if not parser then
    return
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local tree = parser:parse()[1]
  if not tree then
    return
  end

  local root = tree:root()
  if not root then
    return
  end

  return root:named_descendant_for_range(row, col, row, col)
end

local function select_node(node)
  if not node then
    return
  end

  local srow, scol, erow, ecol = node:range()
  vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
  vim.cmd.normal { 'v', bang = true }

  if srow == erow and ecol > scol then
    vim.api.nvim_win_set_cursor(0, { erow + 1, ecol - 1 })
  else
    vim.api.nvim_win_set_cursor(0, { erow + 1, ecol })
  end
end

local function ts_incremental_selection()
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    require('vim.treesitter._select').select_parent(vim.v.count1)
    return
  end

  select_node(get_current_node())
end

local function ts_decremental_selection()
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    require('vim.treesitter._select').select_child(vim.v.count1)
  end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    init = function()
      local ts_runtime = vim.fn.stdpath 'data' .. '/lazy/nvim-treesitter/runtime'
      if vim.uv.fs_stat(ts_runtime) then
        vim.opt.rtp:prepend(ts_runtime)
      end
    end,
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
      'nvim-treesitter/nvim-treesitter-context',
      'windwp/nvim-ts-autotag',
    },
    config = function()
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      vim.api.nvim_create_user_command('TSInstallRequired', function()
        require('nvim-treesitter').install(ts_langs)
      end, {})

      vim.api.nvim_create_user_command('TSBufInfo', function()
        local bufnr = vim.api.nvim_get_current_buf()
        local filetype = vim.bo[bufnr].filetype
        local ok, parser = pcall(vim.treesitter.get_parser, bufnr, nil, { error = false })

        local lines = {
          'bufnr: ' .. bufnr,
          'filetype: ' .. filetype,
          'parser_available: ' .. tostring(ok and parser ~= nil),
        }

        if ok and parser then
          table.insert(lines, 'parser_lang: ' .. tostring(parser:lang()))
        end

        vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, { title = 'TSBufInfo' })
      end, {})

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('anto_treesitter', { clear = true }),
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if not ok then
            return
          end

          local filetype = vim.bo[args.buf].filetype
          if filetype ~= 'markdown' and filetype ~= 'markdown_inline' then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.keymap.set('n', '<cr>', ts_incremental_selection, { desc = 'Treesitter incremental selection' })
      vim.keymap.set('x', '<cr>', ts_incremental_selection, { desc = 'Treesitter expand selection' })
      vim.keymap.set('x', '<M-cr>', function()
        require('vim.treesitter._select').select_parent(vim.v.count1)
      end, { desc = 'Treesitter scope selection' })
      vim.keymap.set('x', '<bs>', ts_decremental_selection, { desc = 'Treesitter shrink selection' })

      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      vim.keymap.set({ 'x', 'o' }, 'aa', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'ia', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'af', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'if', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
      end)

      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
      end)

      vim.keymap.set('n', '<leader>a>', function()
        require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
      end)
      vim.keymap.set('n', '<leader>a<', function()
        require('nvim-treesitter-textobjects.swap').swap_previous '@parameter.inner'
      end)

      require('nvim-ts-autotag').setup {}

      do
        local internal = require 'nvim-ts-autotag.internal'
        local old_rename_tag = internal.rename_tag

        internal.rename_tag = function()
          local parser = vim.treesitter.get_parser(0, nil, { error = false })
          if not parser then
            return
          end

          return old_rename_tag()
        end
      end

      require('treesitter-context').setup {
        enable = true,
        max_lines = 2,
        line_numbers = true,
        mode = 'cursor',
        on_attach = function(buf)
          local filetype = vim.bo[buf].filetype
          return filetype ~= 'html'
        end,
      }

      vim.keymap.set('n', '<leader>tc', '<cmd>TSContext toggle<cr>', { desc = 'Toggle context', silent = true })
    end,
  },
}
