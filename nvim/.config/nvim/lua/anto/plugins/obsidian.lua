local vault_path = vim.fn.getenv('VAULT_PATH')
-- print('init', vault_path)

local function to_id_string(str)
  return str
      :gsub('[^%w%s]', '')
      :lower()
      :gsub('^%s+', '')
      :gsub('%s+$', '')
      :gsub('%s+', '-')
end

local function get_obsidian_commands()
  local commands = vim.api.nvim_get_commands({})
  local obsidian_cmds = {}

  for name, _ in pairs(commands) do
    if name:match("^Obsidian") then
      table.insert(obsidian_cmds, { label = name, command = name })
    end
  end

  -- table.sort(obsidian_cmds)
  return obsidian_cmds
end

local function pick_obsidian_cmd()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local obsidian_cmds = get_obsidian_commands()

  pickers.new({}, {
    prompt_title = "Obsidian",
    finder = finders.new_table {
      results = obsidian_cmds,
      entry_maker = function(entry)
        return {
          value = entry.command,
          display = entry.label,
          ordinal = entry.label,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(bufnum, map)
      actions.select_default:replace(function()
        actions.close(bufnum)
        local selection = action_state.get_selected_entry()
        vim.cmd(selection.value)
      end)
      return true
    end,
  }):find()
end

local function get_date_string(human_readable)
  if human_readable then
    return os.date("%A %d %b %Y, %H:%M")
  end

  return os.date("%Y%m%d%H%M")
end

return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    -- ft = "markdown",
    event = {
      "BufReadPre " .. vault_path .. "/*.md",
      "BufNewFile " .. vault_path .. "/*.md",
    },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
      -- optional
      -- TODO: should replace with snacks?
      {
        "nvim-telescope/telescope.nvim",
        config = true,
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },

        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
          heading = {
            sign = false,
            -- signs = {},
            backgrounds = {},
          },
          checkbox = {
            custom = {
              todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
              cancelled = { raw = '[!]', rendered = '󰜺 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
            }
          },
        },
      },
    },
    config = function()
      require('obsidian').setup({
        ui = { enable = false, },
        workspaces = {
          {
            name = "notes",
            path = vault_path,
          },
        },
        daily_notes = {
          folder = "dailies",
          date_format = "%Y-%m-%d-%A",
          default_tags = { "daily-notes" },
          template = nil
        },
        new_notes_location = 'current_dir',
        note_path_func = function(spec)
          local filename = get_date_string() .. '-' .. to_id_string(spec.title)
          local path = vault_path .. '/' .. filename .. '.md'
          return path
        end,
        note_frontmatter_func = function(note)
          local now = get_date_string(true)
          note:add_field('updated_at', now)

          if note.title then
            note:add_field('title', note.title)
          end

          local out = { id = note.id, tags = note.tags, updated_at = now, title = note.title }

          -- if note.get_field('created_at') then
          --   note:add_field('created_at', now)
          --   out.created_at = now
          -- end

          -- `note.metadata` contains any manually added fields in the frontmatter.
          -- So here we just make sure those fields are kept in the frontmatter.
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end,

        -- TODO: sync notes!
        -- callbacks = {
        --   leave_note = function()
        --     vim.fn.system('obsidian')
        --   end,
        -- },
        -- FIX: boh?
        -- follow_img_func = function()
        -- end,
      })

      vim.keymap.set({ 'n', 'x' }, '<leader>oo', pick_obsidian_cmd)

      -- vim.opt.conceallevel = 2
      vim.opt.wrap = true
      -- vim.wo.linebreak = true -- ?
    end,
  },

}
