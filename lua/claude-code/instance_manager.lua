---@mod claude-code.instance_manager Multi-instance management utilities
---@brief [[
--- This module provides utilities for managing and monitoring multiple
--- Claude Code instances across different git repositories.
---
--- Features:
--- - List all active instances
--- - Switch between instances
--- - Get instance statistics
--- - Clean up orphaned instances
---@brief ]]

local M = {}

--- Get the terminal module (lazy load to avoid circular dependency)
--- @return table Terminal module
local function get_terminal()
  return require('claude-code.terminal')
end

--- Get the git module
--- @return table Git module
local function get_git()
  return require('claude-code.git')
end

--- Get all active Claude Code instances
--- @return table instances List of instance information
function M.list_instances()
  local terminal = get_terminal()
  local instances = {}

  for instance_id, bufnr in pairs(terminal.terminal.instances) do
    local is_valid = vim.api.nvim_buf_is_valid(bufnr)
    local is_loaded = is_valid and vim.api.nvim_buf_is_loaded(bufnr)

    table.insert(instances, {
      id = instance_id,
      bufnr = bufnr,
      is_valid = is_valid,
      is_loaded = is_loaded,
      is_current = instance_id == terminal.terminal.current_instance,
      name = vim.fn.fnamemodify(instance_id, ':t'), -- Get directory name only
    })
  end

  -- Sort by instance ID for consistent ordering
  table.sort(instances, function(a, b)
    return a.id < b.id
  end)

  return instances
end

--- Get the current active instance
--- @return table|nil instance Current instance info or nil
function M.get_current_instance()
  local terminal = get_terminal()
  local current_id = terminal.terminal.current_instance

  if not current_id then
    return nil
  end

  local bufnr = terminal.terminal.instances[current_id]
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end

  return {
    id = current_id,
    bufnr = bufnr,
    is_valid = vim.api.nvim_buf_is_valid(bufnr),
    is_loaded = vim.api.nvim_buf_is_loaded(bufnr),
    is_current = true,
    name = vim.fn.fnamemodify(current_id, ':t'),
  }
end

--- Get statistics about all instances
--- @return table stats Instance statistics
function M.get_stats()
  local instances = M.list_instances()
  local stats = {
    total = #instances,
    valid = 0,
    loaded = 0,
    orphaned = 0,
    current = nil,
  }

  for _, instance in ipairs(instances) do
    if instance.is_valid then
      stats.valid = stats.valid + 1
    end
    if instance.is_loaded then
      stats.loaded = stats.loaded + 1
    end
    if not instance.is_valid then
      stats.orphaned = stats.orphaned + 1
    end
    if instance.is_current then
      stats.current = instance.id
    end
  end

  return stats
end

--- Clean up orphaned instances (invalid buffers)
--- @return number count Number of instances cleaned up
function M.cleanup_orphaned()
  local terminal = get_terminal()
  local cleaned = 0

  for instance_id, bufnr in pairs(terminal.terminal.instances) do
    if not vim.api.nvim_buf_is_valid(bufnr) then
      terminal.terminal.instances[instance_id] = nil
      cleaned = cleaned + 1
    end
  end

  return cleaned
end

--- Switch to a specific instance by ID
--- @param instance_id string Instance identifier (git root path)
--- @return boolean success True if switched successfully
function M.switch_to_instance(instance_id)
  local terminal = get_terminal()
  local bufnr = terminal.terminal.instances[instance_id]

  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    vim.notify(
      'Instance not found or invalid: ' .. instance_id,
      vim.log.levels.ERROR,
      { title = 'Claude Code' }
    )
    return false
  end

  -- Change to the instance's directory
  local success = pcall(vim.cmd.cd, instance_id)
  if not success then
    vim.notify(
      'Failed to change directory to: ' .. instance_id,
      vim.log.levels.ERROR,
      { title = 'Claude Code' }
    )
    return false
  end

  -- Update current instance
  terminal.terminal.current_instance = instance_id

  vim.notify(
    'Switched to instance: ' .. vim.fn.fnamemodify(instance_id, ':t'),
    vim.log.levels.INFO,
    { title = 'Claude Code' }
  )

  return true
end

--- Get instance for current working directory
--- @return string|nil instance_id Instance ID for current directory
function M.get_instance_for_cwd()
  local git = get_git()
  local git_root = git.get_git_root()

  if git_root then
    return git_root
  else
    return vim.fn.getcwd()
  end
end

--- Check if instance exists for a given ID
--- @param instance_id string Instance identifier
--- @return boolean exists True if instance exists
function M.instance_exists(instance_id)
  local terminal = get_terminal()
  local bufnr = terminal.terminal.instances[instance_id]
  return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr)
end

--- Get buffer number for an instance
--- @param instance_id string Instance identifier
--- @return number|nil bufnr Buffer number or nil if not found
function M.get_instance_buffer(instance_id)
  local terminal = get_terminal()
  return terminal.terminal.instances[instance_id]
end

--- Print formatted instance list (for debugging/commands)
--- @return string output Formatted instance list
function M.format_instance_list()
  local instances = M.list_instances()
  local stats = M.get_stats()

  if #instances == 0 then
    return 'No Claude Code instances active'
  end

  local lines = {
    string.format('Claude Code Instances (%d total, %d valid)', stats.total, stats.valid),
    string.rep('─', 60),
  }

  for i, instance in ipairs(instances) do
    local status_icon = instance.is_current and '●' or '○'
    local status = instance.is_valid and 'valid' or 'orphaned'
    local name = instance.name

    table.insert(
      lines,
      string.format('%s [%d] %s (%s)', status_icon, i, name, status)
    )
  end

  if stats.current then
    table.insert(lines, '')
    table.insert(lines, 'Current: ' .. vim.fn.fnamemodify(stats.current, ':t'))
  end

  return table.concat(lines, '\n')
end

--- Interactive instance picker using vim.ui.select
--- @param callback function Callback function called with selected instance
function M.pick_instance(callback)
  local instances = M.list_instances()

  if #instances == 0 then
    vim.notify('No Claude Code instances available', vim.log.levels.WARN, { title = 'Claude Code' })
    return
  end

  local items = {}
  for _, instance in ipairs(instances) do
    local current_marker = instance.is_current and '● ' or '  '
    local status = instance.is_valid and '' or ' (orphaned)'
    table.insert(items, string.format('%s%s%s', current_marker, instance.name, status))
  end

  vim.ui.select(items, {
    prompt = 'Select Claude Code Instance:',
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx then
      local selected_instance = instances[idx]
      if callback then
        callback(selected_instance)
      end
    end
  end)
end

--- Create a new instance for current directory
--- @param plugin_module table The main plugin module
--- @param config table Plugin configuration
--- @return boolean success True if instance created
function M.create_instance_for_cwd(plugin_module, config)
  -- This will be handled by the toggle function in terminal.lua
  -- We just need to ensure we're in the right directory
  local instance_id = M.get_instance_for_cwd()

  if M.instance_exists(instance_id) then
    vim.notify(
      'Instance already exists for: ' .. vim.fn.fnamemodify(instance_id, ':t'),
      vim.log.levels.INFO,
      { title = 'Claude Code' }
    )
    return false
  end

  -- Call toggle to create the instance
  if plugin_module and plugin_module.toggle then
    plugin_module.toggle()
    return true
  end

  return false
end

return M
