local utils = require 'anto.utils'

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('<leader>ra', vim.lsp.buf.rename, '[R]ename [A]ll')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

    -- local client = vim.lsp.get_client_by_id(event.data.client_id)
    -- if client and utils.client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    --   map('<leader>th', function()
    --     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    --   end, '[T]oggle Inlay [H]ints')
    -- end

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- local opts = { buffer = ev.buf, silent = true }

    -- set keybinds
    -- opts.desc = "Show LSP references"
    -- keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references
    --
    -- opts.desc = "Go to declaration"
    -- keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration
    --
    -- opts.desc = "Show LSP definition"
    -- keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definition
    --
    -- opts.desc = "Show LSP implementations"
    -- keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
    --
    -- opts.desc = "Show LSP type definitions"
    -- keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions
    --
    -- opts.desc = "See available code actions"
    -- keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection
    --
    -- opts.desc = "Smart rename"
    -- keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

    -- map('<leader>d', '<cmd>Telescope diagnostics bufnr=0<CR>', 'Show buffer diagnostics')

    -- opts.desc = "Show line diagnostics"
    -- keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line
    --
    -- opts.desc = "Go to previous diagnostic"
    -- keymap.set("n", "[d", function()
    --   vim.diagnostic.jump({ count = -1, float = true })
    -- end, opts) -- jump to previous diagnostic in buffer
    -- --
    -- opts.desc = "Go to next diagnostic"
    -- keymap.set("n", "]d", function()
    --   vim.diagnostic.jump({ count = 1, float = true })
    -- end, opts) -- jump to next diagnostic in buffer
    --
    -- opts.desc = "Show documentation for what is under cursor"
    -- keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor
    --
    -- opts.desc = "Restart LSP"
    -- keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

    vim.defer_fn(function()
      local clients = vim.lsp.get_clients { bufnr = event.buf }
      local has_ts_ls = false
      local has_angularls = false
      local ts_client = nil

      for _, client in ipairs(clients) do
        if client.name == 'typescript-tools' then
          has_ts_ls = true
          ts_client = client
        elseif client.name == 'angularls' then
          has_angularls = true
        end
      end

      if has_ts_ls and has_angularls and ts_client then
        ts_client.server_capabilities.referencesProvider = false
        ts_client.server_capabilities.renameProvider = false
      end
    end, 100)
  end,
})

local severity = vim.diagnostic.severity

vim.diagnostic.config {
  signs = vim.g.have_nerd_font and {
    text = {
      [severity.ERROR] = '󰅚 ',
      [severity.WARN] = '󰀪 ',
      [severity.HINT] = '󰋽 ',
      [severity.INFO] = '󰌶 ',
    },
  } or {},
  -- virtual_text = {
  --   source = 'if_many',
  --   spacing = 2,
  --   format = function(diagnostic)
  --     local diagnostic_message = {
  --       [vim.diagnostic.severity.ERROR] = diagnostic.message,
  --       [vim.diagnostic.severity.WARN] = diagnostic.message,
  --       [vim.diagnostic.severity.INFO] = diagnostic.message,
  --       [vim.diagnostic.severity.HINT] = diagnostic.message,
  --     }
  --     return diagnostic_message[diagnostic.severity]
  --   end,
  -- },
}
