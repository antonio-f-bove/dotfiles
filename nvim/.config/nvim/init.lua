--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
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

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  {
    'nvimtools/none-ls.nvim',
    lazy = true,
    config = function()
      local none_ls = require 'none-ls'
      none_ls.setup({
        sources = {
          none_ls.builtins.diagnostics.ruff,
        }
      })
    end
  },

  { 'folke/which-key.nvim', opts = {} },

  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    config = function()
      local theme = require 'lualine.themes.catppuccin-macchiato'
      theme.normal.c.bg = nil

      require 'lualine'.setup({
        options = {
          icons_enabled = true,
          theme = 'catppuccin-macchiato',
          component_separators = '|',
          section_separators = '',
          globalstatus = true,
        },
        sections = {
          lualine_x = {
            {
              require 'noice'.api.statusline.mode.get_hl,
              cond = require 'noice'.api.statusline.mode.has,
              color = { fg = '#ff9e64' }
            },
            -- {
            --   require("noice").api.status.search.get_hl,
            --   cond = require("noice").api.status.search.has,
            --   color = { fg = "#ff9e64" },
            -- },
            {
              'searchcount',
              maxcount = 999,
              timeout = 500,
            }
          }
        }
      })
    end,
    -- TODO: max line num instead of col num https://github.com/nvim-lualine/lualine.nvim
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    config = function()
      require 'ibl'.setup({
        indent = {
          char = "▏", -- This is a slightly thinner char than the default one, check :help ibl.config.indent.char
        },
        scope = {
          enabled = false,
          show_start = false,
          show_end = false,
        }
      })
      -- disable indentation on the first level
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
    end,
  },

  {
    'numToStr/Comment.nvim',
    opts = {
      toggler = {
        line = '<leader>/',
        block = '<leader>?',
      },
      opleader = {
        line = '<leader>/',
        block = '<leader>?',
      },
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
    },
    build = ':TSUpdate',
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      presets = {
        -- command_palette = true,
        bottom_search = true,  -- use a classic bottom cmdline for search
        command_palette = false,
        inc_rename = false,    -- enables an input dialog for inc-rename.nvim
        long_message_to_split = true,
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
      -- notify = {
      --   enabled = false,
      -- },
      -- -- views = {
      -- --
      -- -- },
      -- routes = {
      --   view = 'mini',
      --   filter = { event = 'msg_showmode' },
      -- },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      -- messages = {
      --   enabled = true,            -- enables the Noice messages UI
      --   -- view_search = false,
      --   view = "mini",             -- default view for messages
      --   view_error = "mini",       -- view for errors
      --   view_warn = "mini",        -- view for warnings
      --   view_history = "messages", -- view for :messages
      -- },
      -- lsp = {
      --   message = { view = "mini" }
      -- }
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    keys = {
      { '<leader><esc>', '<cmd>Noice dismiss<cr>', { 'n' } },
      {
        "<s-enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = 'c',
        { desc = "Redirect Cmdline" }
      }
    }
  },

  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {},
    -- config = function()
    --   -- BUG: doesn't work -> https://github.com/windwp/nvim-autopairs#you-need-to-add-mapping-cr-on-nvim-cmp-setupcheck-readmemd-on-nvim-cmp-repo
    --   local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    --   local cmp = require('cmp')
    --   cmp.event:on(
    --     'confirm_done',
    --     cmp_autopairs.on_confirm_done()
    --   )
    -- end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = true,
  },

  -- TODO: filter out NOTE comments
  {
    "folke/todo-comments.nvim",
    event = 'VeryLazy',
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { '<leader>ft', '<cmd> TodoTelescope <cr>', '[F]ind [T]odos' },
    }
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/anto/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/anto/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'anto.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
require 'anto.options'
require 'anto.autocommands'

-- [[ Basic Keymaps ]]
require 'anto.mappings'

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    sorting_strategy = 'ascending',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.55,
        results_width = 0.8
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    mappings = {
      -- TODO: add actions.to_fuzzy_refine to toggle fuzzy/non fuzzy search. meant to be used in live_grep
      i = {
        ['<c-x>'] = actions.delete_buffer,
        ['<c-s>'] = actions.select_horizontal,
        ['<c-v>'] = actions.select_vertical,
        ["<c-l>"] = actions.cycle_previewers_next,
        ["<c-h>"] = actions.cycle_previewers_prev,
        ["<c-a>"] = actions.toggle_all,
        ["<c-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
        ['<c-e>'] = function(prompt_bufnr)
          local action_utils = require 'telescope.actions.utils'
          local action_state = require 'telescope.actions.state'
          local selected = {}
          action_utils.map_selections(prompt_bufnr, function(entry, index, row)
            vim.print(entry)
            vim.print(index)
            vim.print(row)
            -- selected[index] = entry.value
          end)
          -- .map_entries(prompt_bufnr, function(entry) vim.print(entry) end)
        end
      },
      n = {
        ['xx'] = actions.delete_buffer,
        -- TODO: write implementations
        -- ['xj'] = actions.delete_buffer_under,
        -- ['xk'] = actions.delete_buffer_above,
        ['<c-s>'] = actions.select_horizontal,
        ['<c-v>'] = actions.select_vertical,
        ["<c-l>"] = actions.cycle_previewers_next,
        ["<c-h>"] = actions.cycle_previewers_prev,
        ["<c-a>"] = actions.toggle_all,
        ["<c-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

-- vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end

local responsive_telescope_picker = function(builtin, opts)
  if not opts then
    opts = {}
  end
  if require 'anto.utils'.get_vim2screen_ratio() < 0.7 then
    builtin(require('telescope.themes').get_dropdown(opts))
  else
    builtin(opts)
  end
end

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>fo', function()
  responsive_telescope_picker(require('telescope.builtin').oldfiles)
end, { desc = '[F]ind [o]ld files' })
vim.keymap.set('n', '<leader>fb', function()
  responsive_telescope_picker(require('telescope.builtin').buffers)
end, { desc = '[F]ind [b]uffers' })
vim.keymap.set('n', '<leader><tab>', function()
  responsive_telescope_picker(require('telescope.builtin').buffers)
end, { desc = '[F]ind [b]uffers' })
vim.keymap.set('n', '<leader>f/', function()
  responsive_telescope_picker(require('telescope.builtin').current_buffer_fuzzy_find)
end, { desc = '[/] Fuzzily search in current buffer' })
-- vim.keymap.set('n', '<leader>f/', telescope_live_grep_open_files, { desc = '[F]ind [/] in Open Files' })
vim.keymap.set('n', '<leader>fs', function()
  responsive_telescope_picker(require('telescope.builtin').builtin)
end, { desc = '[F]ind [S]elect Telescope' })
vim.keymap.set('n', '<leader>fk', function()
  responsive_telescope_picker(require('telescope.builtin').keymaps)
end, { desc = '[F]ind [K]eymaps' })
vim.keymap.set('n', '<leader>fa', function()
  responsive_telescope_picker(require('telescope.builtin').git_files)
end, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>ff', function()
  responsive_telescope_picker(require('telescope.builtin').find_files)
end, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fh', function()
  responsive_telescope_picker(require('telescope.builtin').help_tags)
end, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fc', function()
  responsive_telescope_picker(require('telescope.builtin').grep_string)
end, { desc = '[F]ind current [W]ord' })
vim.keymap.set('x', '<leader>f', function()
  responsive_telescope_picker(require('telescope.builtin').grep_string,
    { search = require 'anto.utils'.get_visual_selection() })
end, { desc = '[F]ind visual selection' })
vim.keymap.set('n', '<leader>fw', function()
  responsive_telescope_picker(require('telescope.builtin').live_grep)
end, { desc = '[F]ind by [G]rep' })
-- vim.keymap.set('n', '<leader>fW', ':LiveGrepGitRoot<cr>', { desc = '[F]ind by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>fd', function()
  responsive_telescope_picker(require('telescope.builtin').diagnostics)
end, { desc = '[F]ind [D]iagnostics' })
vim.keymap.set('n', '<leader>fr', function()
  responsive_telescope_picker(require('telescope.builtin').resume)
end, { desc = '[F]ind [R]esume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'go', 'lua', 'python', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim',
      'bash', 'markdown', 'markdown_inline', 'java', 'html' },

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
          -- ['ac'] = '@class.outer',
          -- ['ic'] = '@class.inner',
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
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>ra', vim.lsp.buf.rename, '[R]ename [a]ll')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- HACK: conficted with tmux navigator
  -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  -- ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  -- ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  gopls = {},
  pyright = {},
  ruff_lsp = {},
  -- rust_analyzer = {},
  tsserver = {},
  html = { filetypes = { 'html', 'twig', 'hbs' } },
  jdtls = {
    -- setup = {}
  },
  emmet_language_server = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- HACK: ?? toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      diagnostics = { disable = { 'missing-fields' }, globals = { 'vim' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    -- FIX: I'd like it not only to autocomplete the word but also the boilerplate
    ['<Tab>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    -- ["<c-a>"] = cmp.mapping.complete {
    --   config = {
    --     sources = {
    --       { name = "cody" },
    --     },
    --   },
    -- },

    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_locally_jumpable() then
    --     luasnip.expand_or_jump()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    -- ['<S-Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.locally_jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
  },
  sources = {
    { name = 'cody' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
}

-- TODO: setup command line cmp
-- `:` cmdline setup.
-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     {
--       name = 'cmdline',
--       option = {
--         ignore_cmds = { 'Man', '!' }
--       }
--     }
--   })
-- })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
