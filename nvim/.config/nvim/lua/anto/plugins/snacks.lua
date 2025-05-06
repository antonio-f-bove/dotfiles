local picker_sources = {
  explorer = {
    layout = {
      layout = {
        position = "right",
        width = 100,
      }
    },
  },
}

return {

  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    --@type snacks.Config
    opts = {
      notifier = { enabled = true },
      picker = {
        enabled = true,
        sources = picker_sources,
        -- TODO: <c-a> should inverse selection if some entries are selected already
        -- win = {
        --   list = {
        --     ['<c-j>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
        --     ['<c-k>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
        --     ['<c-w>'] = { 'cycle_win', mode = { 'i', 'n' } },
        --   }
        -- }
      },
      explorer = {
        -- TODO: wider explorer, on the right? Won't configure
        enabled = true,

      },
      input = { enabled = true },
      indent = {
        enabled = true,
        animate = { enabled = false },
        scope = { enabled = false },
      },
      bufdelete = { enabled = true },
      scope = { enabled = true }, -- TODO: fix treesitter scope too!
      -- statuscolumn = { enabled = true },
      zen = {
        enabled = true,
        toggles = {
          dim = false,
          git_signs = true,
        }
      },
      quickfile = { enabled = true },
      bigfile = { enabled = true },
    },
    keys = {
      { "<leader>n",     function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader><esc>", function() Snacks.notifier.hide() end,        desc = "Dismiss All Notifications" },
      --
      -- pickers & explorer
      { "<leader>e",     function() Snacks.explorer() end,             desc = "File explorer" },
      { "<leader>fs",    function() Snacks.picker() end,               desc = "" },
      { "<leader>ff",    function() Snacks.picker.files() end,         desc = "" },
      { "<leader>FF",    function() Snacks.picker.smart() end,         desc = "" },
      { "<leader>fw",    function() Snacks.picker.grep() end,          desc = "" },
      { "<leader>fc",    function() Snacks.picker.grep_word() end,     desc = "" },
      { "<leader>f",     function() Snacks.picker.grep_word() end,     desc = "",                         mode = { 'x' } },
      { "<leader>fo",    function() Snacks.picker.recent() end,        desc = "" },
      { "<leader>fh",    function() Snacks.picker.help() end,          desc = "" },
      { "<leader>fk",    function() Snacks.picker.keymaps() end,       desc = "" },
      -- { "<leader>fC",    function() Snacks.picker.files() end,   desc = "find config" },
      { "<leader>fb",    function() Snacks.picker.buffers() end,       desc = "" },
      { "<leader>f/",    function() Snacks.picker.lines() end,         desc = "" },
      { "<leader>fr",    function() Snacks.picker.resume() end,        desc = "" },
      -- TODO: fj (files in same directory? same name?)

      -- TODO: abstract! I want to be able to also navigate node_modules
      {
        "<leader>sd",
        function()
          local dirs = require 'anto.utils'.get_path_to_deps()
          -- print(vim.inspect('dirs', dirs))
          Snacks.picker.files({ dirs = dirs })
        end,
        desc = ""
      },
      { '<leader>sp', function() Snacks.picker.lazy() end,            desc = "" },

      -- git
      -- { "<leader>gb", function() Snacks.picker.git_branches() end,     desc = "Git Branches" },
      -- TODO: confirm => show instead of checkout
      { "<leader>gl", function() Snacks.picker.git_log() end,         desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end,    desc = "Git Log Line" },
      -- TODO: picker should grep revision contents instead of file names
      { "<leader>gs", function() Snacks.picker.git_status() end,      desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end,       desc = "Git Stash" },
      -- { "<leader>gd", function() Snacks.picker.git_diff() end,         desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end,    desc = "Git Log File" },

      -- LSP
      { "gd",         function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      {
        "<leader>gd",
        function()
          local params = vim.lsp.util.make_position_params()
          vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, _)
            if err or not result then return end

            vim.cmd('vsplit')   -- open a vertical split
            vim.cmd('wincmd l') -- go to the new window

            -- use the built-in handler to jump to the location
            vim.lsp.util.jump_to_location(result[1] or result)
          end)

          -- Snacks.picker.lsp_definitions()
        end,
        desc = "Goto Definition in vsplit"
      },
      { "gD",         function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
      {
        "gr",
        function()
          Snacks.picker.lsp_references({
            include_declaration = false,
            include_current = true,
          })
        end,
        nowait = true,
        desc = "References"
      },
      { "gI",         function() Snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
      { "<leader>D",  function() Snacks.picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
      { "<leader>ds", function() Snacks.picker.lsp_symbols() end,           desc = "LSP Symbols" },
      { "<leader>dS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },

      -- bufdelete
      { "<leader>x",  function() Snacks.bufdelete.delete() end,             desc = "" },
      {
        "<leader>X",
        function()
          vim.cmd('only')
          Snacks.bufdelete.other()
        end,
        desc = ""
      },

      -- zen
      { "<leader>zz", function() Snacks.zen() end, desc = "" },
    }
  },

  {
    "folke/todo-comments.nvim",
    event = 'VeryLazy',
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        ACTIVE = { color = 'info' }
      }
    },
    keys = {
      { '<leader>ft', function() Snacks.picker.todo_comments({ keywords = { 'TODO', 'FIXME', 'FIX', 'BUG', 'HACK', 'WARN', 'INFO' } }) end, '[F]ind [T]odos' },

      { '<leader>fa', function() Snacks.picker.todo_comments({ keywords = { 'ACTIVE' } }) end,                                              '[F]ind [A]ctive' },
      -- { '<leader>sa', 'OACTIVE:<esc><leader>/' }
      { '<leader>sa',
        function()
          vim.cmd('normal! OACTIVE: ')
          require('Comment.api').toggle.linewise()
          vim.cmd('write!')
        end,
        { desc = 'Set ACTIVE' }
      },
      -- TODO: Remove all ACTIVE tags
      -- {'<leader>sA', },
    },
  },
}
