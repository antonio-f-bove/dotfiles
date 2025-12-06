local set = vim.keymap.set

local toggle_option = function(...)
  local opts = { ... }
  for _, option in ipairs(opts) do
    local curr_val = vim.api.nvim_get_option_value(option, {})
    vim.api.nvim_set_option_value(option, not curr_val, {})
  end
end

set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
local severity = require('vim.diagnostic').severity
set('n', '[d', function()
  vim.diagnostic.goto_prev { severity = severity.ERROR }
end, { desc = 'Go to previous diagnostic message' })
set('n', ']d', function()
  vim.diagnostic.goto_next { severity = severity.ERROR }
end, { desc = 'Go to next diagnostic message' })
-- set('n', '[D', function()
--   vim.diagnostic.goto_prev()
-- end, { desc = 'Go to previous diagnostic message' })
-- set('n', ']D', function()
--   vim.diagnostic.goto_next()
-- end, { desc = 'Go to next diagnostic message' })

set('i', 'jk', '<c-[>')
set('n', '<leader><leader>', '<cmd> e # <cr>')
set('n', 'Q', '@q')
-- set('v', 'v', "<esc>m`ggVG") -- TODO: I want to be able to <c-o> to where visualized all

set('n', '<leader>p', '"_diwP', { desc = 'Replace <aword> w/ yanked word' })
set({ 'v', 'x' }, '<leader>p', '"_dP', { desc = 'Replace <aword> w/ yanked word' })
set('n', '<leader>*', '/<c-r>"<cr>', { desc = 'Find last yanked word' })

set('n', '<c-s>', '<cmd> wa <cr>', { desc = 'Save all files' })
set('n', 'ZA', '<cmd> xa <cr>', { desc = 'xa' })
set('n', 'ZQ', '<cmd> qa! <cr>', { desc = 'qa!' })

set('n', '<tab>', '<cmd> bnext <cr>')
set('n', '<s-tab>', '<cmd> bprev <cr>')
-- TODO: instead of <c-i>, which is the same as tab!
-- set('n', '<c-s-o>', function()
-- 	print('hello')
-- end)

-- quickfix and loclist movement
set('n', '<c-n>', '<cmd> cnext <cr>')
set('n', '<c-p>', '<cmd> cprev <cr>')

set('n', ']Q', '<cmd> clast <cr>')
set('n', '[Q', '<cmd> cfirst <cr>')
set('n', ']l', '<cmd> lnext <cr>')
set('n', '[l', '<cmd> lprev <cr>')
set('n', ']L', '<cmd> llast <cr>')
set('n', '[L', '<cmd> lfirst <cr>')

-- set({ 'n', 'v', 'o' }, 'gh', '^')
-- set({ 'n', 'v', 'o' }, 'gl', '$')

set('n', '>', '>>')
set('n', '<', '<<')
set('v', '>', '>gv')
set('v', '<', '<gv')

-- Movement in INSERT mode
set('i', '<c-h>', '<Left>')
set('i', '<c-j>', '<Down>')
set('i', '<c-k>', '<Up>')
set('i', '<c-l>', '<Right>')

-- primeagen's
set('n', 'J', 'mzJ`z')
set('n', '<C-d>', '<C-d>zz')
set('n', '<C-u>', '<C-u>zz')
set('n', 'n', 'nzzzv')
set('n', 'N', 'Nzzzv')
set('v', 'K', ":m '<-2<cr>gv=gv")
set('v', 'J', ":m '>+1<cr>gv=gv")
-- vim.keymap.set("v", "K", function() require('anto.utils').move_lines("up") end, { desc = "Move lines up" })
-- vim.keymap.set("v", "J", function() require('anto.utils').move_lines("down") end, { desc = "Move lines down" })

set('v', 'gJ', 'J')

-- set("n", "<c-o>", "<c-o>zzzv")
-- set("n", "<c-i>", "<c-i>zzzv")

-- Better redo
set('n', '<c-r>', '<Nop>')
set('n', 'U', '<c-r>')

set('n', '<Esc>', '<cmd> noh <cr>', { desc = 'Clear highlights' })

-- comments
set('n', '<leader>/', 'gcc', { remap = true })
set('x', '<leader>/', 'gcc<esc>', { remap = true })

-- Toggles
set('n', '<leader>tr', function()
  toggle_option 'relativenumber'
end, { desc = 'Toggle relnum' })
set('n', '<leader>tw', function()
  toggle_option('wrap', 'linebreak')
end, { desc = 'Toggle wrap' })
-- set('n', '<leader>th', function() toggle_option('hlsearch') end, { desc = 'Toggle hlsearch' })
set('n', '<leader>ts', function()
  toggle_option 'spell'
end, { desc = 'Toggle spell' })

-- set('n', '<leader>zf', 'vafojzf', { desc = 'fold aFunction' }) -- FIXME: why does it not work
set('n', '<leader>zf', 'zfai', { desc = 'fold aFunction' }) -- FIXME: why does it not work
set('n', '<leader>zt', 'vatojzf', { desc = 'fold aTag' })

set('n', '<leader>gd', function()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, _)
    if err then
      vim.notify('LSP error: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end

    if not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.WARN)
      return
    end

    -- Handle both single result and array of results
    local location = vim.tbl_islist(result) and result[1] or result

    -- close other splits if any
    vim.cmd 'only'

    -- Open vertical split
    vim.cmd 'vsplit'

    -- Jump to the definition in the new split
    -- vim.lsp.util.jump_to_location(location, 'utf-8')
    vim.lsp.util.show_document(location, 'utf-8')
  end)
end, { desc = 'Goto Definition in vsplit' })
