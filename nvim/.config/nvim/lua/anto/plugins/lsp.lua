local organize_ts_imports_cmd_name = 'OrganizeTSImports'

return {
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ui = {
            icons = {
              package_installed = '✓',
              package_pending = '➜',
              package_uninstalled = '✗',
            },
          },
        },
      },
      'neovim/nvim-lspconfig',
      {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        opts = {
          ensure_installed = {
            'prettier',
            'prettierd',
            -- 'eslint_d',
          },
        },
      },
    },
    opts = {
      -- list of servers for mason to install
      ensure_installed = {
        'html',
        'vtsls',
        'angularls',
        'cssls',
        'tailwindcss',
        'lua_ls',
        'astro',
        'rust_analyzer',
      },
    },
  },

  -- TODO: add custom commands for wanted actions (goto_project_config? restart_tsserver? select_ts_version)
  {
    'yioneko/nvim-vtsls',
    config = function()
      vim.api.nvim_create_user_command(organize_ts_imports_cmd_name, function()
        local bufnr = vim.api.nvim_get_current_buf()
        local commands = require("vtsls").commands

        commands.add_missing_imports(bufnr, function()
          commands.organize_imports(bufnr)
        end)
      end, {})
    end,
    cmd = organize_ts_imports_cmd_name
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

}
