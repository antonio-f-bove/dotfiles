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
      { "<leader><tab>", function() Snacks.picker.buffers() end,       desc = "" },
      { "<leader>f/",    function() Snacks.picker.lines() end,         desc = "" },
      { "<leader>fr",    function() Snacks.picker.resume() end,        desc = "" },
      -- TODO: fj (files in same directory? same name?)

      -- TODO: abstract! I want to be able to also navigate node_modules
      {
        "<leader>sd",
        function()
          Snacks.picker.files({ dirs = { '/home/anto/.local/share/nvim/lazy' } })
        end,
        desc = ""
      },
      -- { '<leader>sl', function() Snacks.picker.lazy() end,                  desc = "" },

      -- git
      { "<leader>gb", function() Snacks.picker.git_branches() end,          desc = "Git Branches" },
      -- TODO: confirm => show instead of checkout
      { "<leader>gl", function() Snacks.picker.git_log() end,               desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end,          desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end,            desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end,             desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end,              desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end,          desc = "Git Log File" },

      -- LSP
      { "gd",         function() Snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
      { "gD",         function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
      { "gr",         function() Snacks.picker.lsp_references() end,        nowait = true,                  desc = "References" },
      { "gI",         function() Snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
      { "<leader>S",  function() Snacks.picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
      { "<leader>ds", function() Snacks.picker.lsp_symbols() end,           desc = "LSP Symbols" },
      { "<leader>dS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },

      -- bufdelete
      { "<leader>x",  function() Snacks.bufdelete.delete() end,             desc = "" },
      { "<leader>X",  function() Snacks.bufdelete.other() end,              desc = "" },

      -- zen
      { "<leader>zz", function() Snacks.zen() end,                          desc = "" },
    }
  },

  {
    "folke/todo-comments.nvim",
    event = 'VeryLazy',
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { '<leader>ft', function() Snacks.picker.todo_comments({ keywords = { 'TODO', 'FIXME', 'BUG', 'HACK', 'WARN', 'INFO' } }) end, '[F]ind [T]odos' },
    }
  },

}
