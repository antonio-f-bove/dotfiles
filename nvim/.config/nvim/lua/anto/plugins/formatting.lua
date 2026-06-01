return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  config = function()
    local util = require 'conform.util'
    local js_based_config = { 'prettier', lsp_format = 'fallback', stop_after_first = true }
    -- local js_based_config = { 'prettierd', 'prettier', lsp_format = 'fallback', stop_after_first = true }
    local prettier_config = { cwd = util.root_file { '.prettierrccc' }, require_cwd = true } -- HACK: do not format with prettier for now

    require('conform').setup {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end

        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        typescript = js_based_config,
        javascript = js_based_config,
        astro = js_based_config,
        json = js_based_config,
        -- html = { 'prettierd', 'prettier', stop_after_first = true },
        -- htmlangular = { 'prettierd', 'prettier', stop_after_first = true },
        -- htmlangular = js_based_config,
        lua = { 'stylua' },
      },
      formatters = {
        prettier = prettier_config,
        prettierd = prettier_config,
      },
    }

    -- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#command-to-toggle-format-on-save
    vim.api.nvim_create_user_command('ToggleAutoFormat', function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = not vim.b.disable_autoformat
      else
        vim.g.disable_autoformat = not vim.g.disable_autoformat
      end
    end, {
      desc = 'Toggle autoformat-on-save',
      bang = true,
    })
  end,
}
