---@mod claude-code.instance_commands Instance management commands
---@brief [[
--- This module provides Vim commands for managing multiple Claude Code instances.
---
--- Commands:
--- - :ClaudeCodeInstances - List all instances
--- - :ClaudeCodeInstanceSwitch - Interactive instance picker
--- - :ClaudeCodeInstanceCleanup - Clean orphaned instances
--- - :ClaudeCodeInstanceStats - Show instance statistics
---@brief ]]

local M = {}

--- Register instance management commands
--- @param plugin_module table The main plugin module
function M.register_commands(plugin_module)
  local instance_manager = require('claude-code.instance_manager')

  -- List all instances
  vim.api.nvim_create_user_command('ClaudeCodeInstances', function()
    local output = instance_manager.format_instance_list()
    vim.notify(output, vim.log.levels.INFO, { title = 'Claude Code Instances' })
  end, {
    desc = 'List all Claude Code instances',
  })

  -- Interactive instance switcher
  vim.api.nvim_create_user_command('ClaudeCodeInstanceSwitch', function()
    instance_manager.pick_instance(function(instance)
      if instance and instance.is_valid then
        instance_manager.switch_to_instance(instance.id)
      elseif instance then
        vim.notify(
          'Cannot switch to orphaned instance: ' .. instance.name,
          vim.log.levels.ERROR,
          { title = 'Claude Code' }
        )
      end
    end)
  end, {
    desc = 'Switch to a different Claude Code instance',
  })

  -- Clean up orphaned instances
  vim.api.nvim_create_user_command('ClaudeCodeInstanceCleanup', function()
    local cleaned = instance_manager.cleanup_orphaned()
    vim.notify(
      string.format('Cleaned up %d orphaned instance(s)', cleaned),
      vim.log.levels.INFO,
      { title = 'Claude Code' }
    )
  end, {
    desc = 'Clean up orphaned Claude Code instances',
  })

  -- Show instance statistics
  vim.api.nvim_create_user_command('ClaudeCodeInstanceStats', function()
    local stats = instance_manager.get_stats()
    local current_name = stats.current and vim.fn.fnamemodify(stats.current, ':t') or 'None'

    local message = string.format(
      [[Instance Statistics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total:    %d
Valid:    %d
Loaded:   %d
Orphaned: %d
Current:  %s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━]],
      stats.total,
      stats.valid,
      stats.loaded,
      stats.orphaned,
      current_name
    )

    vim.notify(message, vim.log.levels.INFO, { title = 'Claude Code Stats' })
  end, {
    desc = 'Show Claude Code instance statistics',
  })

  -- Show current instance
  vim.api.nvim_create_user_command('ClaudeCodeInstanceCurrent', function()
    local current = instance_manager.get_current_instance()
    if current then
      vim.notify(
        'Current instance: ' .. current.name .. '\nPath: ' .. current.id,
        vim.log.levels.INFO,
        { title = 'Claude Code' }
      )
    else
      vim.notify('No active Claude Code instance', vim.log.levels.WARN, { title = 'Claude Code' })
    end
  end, {
    desc = 'Show current Claude Code instance',
  })

  -- Create instance for current directory
  vim.api.nvim_create_user_command('ClaudeCodeInstanceCreate', function()
    instance_manager.create_instance_for_cwd(plugin_module, plugin_module.config)
  end, {
    desc = 'Create Claude Code instance for current directory',
  })
end

return M
