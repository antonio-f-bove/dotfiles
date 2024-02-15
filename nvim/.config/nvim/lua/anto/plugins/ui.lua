return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      {
        's1n7ax/nvim-window-picker',
        version = '2.*',
        config = function()
          require 'window-picker'.setup({
            filter_rules = {
              include_current_win = false,
              autoselect_one = true,
              -- filter using buffer options
              bo = {
                -- if the file type is one of following, the window will be ignored
                filetype = { 'neo-tree', "neo-tree-popup", "notify" },
                -- if the buffer type is one of following, the window will be ignored
                buftype = { 'terminal', "quickfix" },
              },
            },
          })
        end,
      },
    },
    config = function()
      -- Unless you are still migrating, remove the deprecated commands from v1.x
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true },
        },
        window = {
          mappings = {
            ['<cr>'] = function()
              local visible_wins = {}
              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                local buf = vim.api.nvim_win_get_buf(win)
                local is_listed = vim.fn.buflisted(buf) == 1
                if is_listed then
                  table.insert(visible_wins, win)
                end
              end
              vim.print(#visible_wins)

              -- local picked_window = visible_wins[1]
              -- if #visible_wins > 1 then
              --
              -- end
              return 'open'
            end,
            ['<c-v>'] = 'open_vsplit',
            ['v'] = 'open_vsplit',
            ['<c-s>'] = 'open_split',
            ['s'] = 'open_vsplit',
          }
        }
      })
    end,
    keys = {
      { '<leader>e', '<cmd> Neotree toggle <cr>' },
      { '<c-n>',     '<cmd> Neotree focus <cr>' },
    }
  }
}
