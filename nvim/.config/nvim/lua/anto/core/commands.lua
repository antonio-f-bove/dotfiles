vim.api.nvim_create_user_command('GrepRange', function(opts)
  local pattern = opts.args
  local range_start = opts.line1
  local range_end = opts.line2

  print(pattern, range_start, range_end)

  if pattern == '' then
    vim.notify(':GrepRange needs a <pattern>', vim.log.levels.ERROR)
  end

  vim.cmd('vim /' .. pattern .. '/ %')

  local qf = vim.fn.getqflist()
  local filtered = {}

  for _, item in ipairs(qf) do
    if item.lnum >= range_start and item.lnum <= range_end then
      table.insert(filtered, item)
    end
  end

  vim.fn.setqflist(filtered, 'r')
  vim.cmd 'copen'
end, { nargs = '+', range = true })

vim.api.nvim_create_user_command('FixTreeSitterHighlight', function(opts)
  vim.cmd 'write | edit | TSBufEnable highlight'
end, { desc = 'Fix treesitter highlight' })

vim.api.nvim_create_user_command('TmuxJoinPi', function()
  if not vim.env.TMUX or vim.env.TMUX == '' then
    vim.notify('Not inside a tmux session ($TMUX is not set)', vim.log.levels.ERROR)
    return
  end

  local function systemlist(cmd)
    local out = vim.fn.systemlist(cmd)
    local code = vim.v.shell_error
    return out, code
  end

  -- Current pane/window info
  local curr, curr_code = systemlist("tmux display-message -p '#{pane_id}|#{window_id}|#{window_name}'")
  if curr_code ~= 0 or not curr[1] then
    vim.notify('Failed to query tmux current pane/window', vim.log.levels.ERROR)
    return
  end

  local target_pane_id, current_window_id, current_window_name = curr[1]:match('^([^|]+)|([^|]+)|(.+)$')
  if not target_pane_id or not current_window_id then
    vim.notify('Failed to parse tmux current pane/window', vim.log.levels.ERROR)
    return
  end

  if current_window_name == 'pi' then
    vim.notify("You're currently in the 'pi' window; refusing to join it into itself", vim.log.levels.WARN)
    return
  end

  -- Find a window named "pi" in the current session
  local wins, wins_code = systemlist("tmux list-windows -F '#{window_id}|#{window_name}'")
  if wins_code ~= 0 then
    vim.notify('Failed to list tmux windows', vim.log.levels.ERROR)
    return
  end

  local pi_window_id
  for _, line in ipairs(wins) do
    local win_id, win_name = line:match('^([^|]+)|(.+)$')
    if win_name == 'pi' then
      pi_window_id = win_id
      break
    end
  end

  if not pi_window_id then
    vim.notify("No tmux window named 'pi' found in this session", vim.log.levels.INFO)
    return
  end

  -- Presume the "pi" window has exactly one pane; take the first pane id returned.
  local panes, panes_code = systemlist("tmux list-panes -t " .. vim.fn.shellescape(pi_window_id) .. " -F '#{pane_id}'")
  if panes_code ~= 0 or not panes[1] then
    vim.notify("Failed to list panes for tmux window 'pi'", vim.log.levels.ERROR)
    return
  end

  local src_pane_id = panes[1]

  -- Join as a left/right split (tmux calls this -h). Without -b it is created to the right.
  local _, join_code = systemlist(
    'tmux join-pane -s '
      .. vim.fn.shellescape(src_pane_id)
      .. ' -t '
      .. vim.fn.shellescape(target_pane_id)
      .. ' -h'
  )

  if join_code ~= 0 then
    vim.notify("Failed to join 'pi' pane into the current window", vim.log.levels.ERROR)
    return
  end
end, { desc = 'If a tmux window named "pi" exists, join its pane into the current window on the right' })
