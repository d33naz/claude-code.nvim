#!/usr/bin/env lua
---@brief [[
--- Configuration Validation & Conflict Detection Utility
---
--- Usage:
---   lua config/validate-config.lua <profile_path>
---   lua config/validate-config.lua config/team-profiles/backend.lua
---
--- Features:
--- - Validates configuration syntax and structure
--- - Detects keymap conflicts with common Neovim plugins
--- - Checks for deprecated options
--- - Provides actionable error messages
---@brief ]]

-- Common keymap conflicts to check
local COMMON_KEYMAPS = {
  -- LSP keymaps
  { key = '<leader>ca', plugin = 'LSP', action = 'Code Actions' },
  { key = '<leader>cr', plugin = 'LSP', action = 'Rename' },
  { key = '<leader>cd', plugin = 'LSP', action = 'Diagnostics' },
  { key = '<leader>cf', plugin = 'LSP', action = 'Format' },

  -- Telescope
  { key = '<leader>ff', plugin = 'Telescope', action = 'Find Files' },
  { key = '<leader>fg', plugin = 'Telescope', action = 'Live Grep' },
  { key = '<leader>fb', plugin = 'Telescope', action = 'Buffers' },

  -- NvimTree
  { key = '<leader>e', plugin = 'NvimTree', action = 'Explorer' },
  { key = '<leader>nt', plugin = 'NvimTree', action = 'Toggle' },

  -- Git
  { key = '<leader>gg', plugin = 'LazyGit', action = 'Toggle' },
  { key = '<leader>gs', plugin = 'Git', action = 'Status' },
  { key = '<leader>gc', plugin = 'Git', action = 'Commit' },

  -- Terminal
  { key = '<C-\\>', plugin = 'Terminal', action = 'Toggle Terminal' },
  { key = '<leader>tt', plugin = 'ToggleTerm', action = 'Toggle' },
}

local errors = {}
local warnings = {}
local info = {}

--- Add error message
local function add_error(message)
  table.insert(errors, '❌ ERROR: ' .. message)
end

--- Add warning message
local function add_warning(message)
  table.insert(warnings, '⚠️  WARNING: ' .. message)
end

--- Add info message
local function add_info(message)
  table.insert(info, 'ℹ️  INFO: ' .. message)
end

--- Validate window configuration
local function validate_window(window)
  if not window then
    add_error('Missing window configuration')
    return false
  end

  if type(window.split_ratio) ~= 'number' then
    add_error('window.split_ratio must be a number')
    return false
  end

  if window.split_ratio <= 0 or window.split_ratio > 1 then
    add_error('window.split_ratio must be between 0 and 1 (got: ' .. tostring(window.split_ratio) .. ')')
    return false
  end

  local valid_positions = { 'top', 'bottom', 'left', 'right', 'botright', 'topleft', 'vertical', 'float' }
  local position_valid = false
  for _, pos in ipairs(valid_positions) do
    if window.position == pos then
      position_valid = true
      break
    end
  end

  if not position_valid then
    add_error('Invalid window.position: ' .. tostring(window.position))
    return false
  end

  -- Validate float configuration if position is float
  if window.position == 'float' and window.float then
    if not window.float.width or not window.float.height then
      add_error('Floating window requires width and height')
      return false
    end
  end

  -- Deprecated option check
  if window.height_ratio then
    add_warning('window.height_ratio is deprecated, use window.split_ratio instead')
  end

  add_info('Window configuration valid (' .. window.position .. ' split, ' .. (window.split_ratio * 100) .. '%)')
  return true
end

--- Validate keymaps and detect conflicts
local function validate_keymaps(keymaps)
  if not keymaps then
    add_warning('No keymaps configuration found')
    return true
  end

  local used_keymaps = {}

  -- Check toggle keymaps
  if keymaps.toggle then
    if keymaps.toggle.normal and keymaps.toggle.normal ~= false then
      table.insert(used_keymaps, keymaps.toggle.normal)
    end
    if keymaps.toggle.terminal and keymaps.toggle.terminal ~= false then
      table.insert(used_keymaps, keymaps.toggle.terminal)
    end

    -- Check variant keymaps
    if keymaps.toggle.variants then
      for variant_name, keymap in pairs(keymaps.toggle.variants) do
        if keymap and keymap ~= false then
          table.insert(used_keymaps, keymap)
        end
      end
    end
  end

  -- Check for conflicts with common plugins
  local conflicts = {}
  for _, used_key in ipairs(used_keymaps) do
    for _, common in ipairs(COMMON_KEYMAPS) do
      if used_key == common.key then
        table.insert(conflicts, {
          key = used_key,
          plugin = common.plugin,
          action = common.action,
        })
      end
    end
  end

  if #conflicts > 0 then
    for _, conflict in ipairs(conflicts) do
      add_warning(string.format(
        'Keymap conflict: %s is commonly used by %s (%s)',
        conflict.key,
        conflict.plugin,
        conflict.action
      ))
    end
  else
    add_info('No keymap conflicts detected with common plugins')
  end

  add_info('Found ' .. #used_keymaps .. ' configured keymaps')
  return true
end

--- Validate command variants
local function validate_command_variants(variants)
  if not variants then
    add_info('No command variants configured')
    return true
  end

  local count = 0
  for name, args in pairs(variants) do
    if args and args ~= false then
      if type(args) ~= 'string' then
        add_error('Command variant "' .. name .. '" must be a string or false')
        return false
      end
      count = count + 1
    end
  end

  add_info('Configured ' .. count .. ' command variants')
  return true
end

--- Validate git configuration
local function validate_git(git)
  if not git then
    add_warning('No git configuration found, using defaults')
    return true
  end

  if type(git.use_git_root) ~= 'boolean' then
    add_error('git.use_git_root must be a boolean')
    return false
  end

  if type(git.multi_instance) ~= 'boolean' then
    add_error('git.multi_instance must be a boolean')
    return false
  end

  if git.multi_instance then
    add_info('Multi-instance mode enabled (per-repo isolation)')
  else
    add_info('Single instance mode (global)')
  end

  return true
end

--- Validate refresh configuration
local function validate_refresh(refresh)
  if not refresh then
    add_warning('No refresh configuration found, using defaults')
    return true
  end

  if type(refresh.enable) ~= 'boolean' then
    add_error('refresh.enable must be a boolean')
    return false
  end

  if type(refresh.updatetime) ~= 'number' or refresh.updatetime < 0 then
    add_error('refresh.updatetime must be a positive number')
    return false
  end

  if type(refresh.timer_interval) ~= 'number' or refresh.timer_interval < 0 then
    add_error('refresh.timer_interval must be a positive number')
    return false
  end

  if refresh.updatetime < 50 then
    add_warning('refresh.updatetime < 50ms may cause performance issues')
  end

  if refresh.timer_interval < 500 then
    add_warning('refresh.timer_interval < 500ms may cause excessive file system checks')
  end

  add_info('File refresh enabled (' .. refresh.updatetime .. 'ms updatetime, ' .. refresh.timer_interval .. 'ms interval)')
  return true
end

--- Load and validate configuration file
local function validate_config_file(filepath)
  print('🔍 Validating configuration: ' .. filepath)
  print('')

  -- Load the configuration file
  local config
  local success, err = pcall(function()
    config = dofile(filepath)
  end)

  if not success then
    add_error('Failed to load configuration file: ' .. tostring(err))
    return false
  end

  if type(config) ~= 'table' then
    add_error('Configuration must return a table')
    return false
  end

  -- Validate each section
  local valid = true
  valid = validate_window(config.window) and valid
  valid = validate_keymaps(config.keymaps) and valid
  valid = validate_command_variants(config.command_variants) and valid
  valid = validate_git(config.git) and valid
  valid = validate_refresh(config.refresh) and valid

  return valid
end

--- Print results
local function print_results()
  print('')
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  print('  VALIDATION RESULTS')
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  print('')

  if #errors > 0 then
    print('ERRORS:')
    for _, err in ipairs(errors) do
      print('  ' .. err)
    end
    print('')
  end

  if #warnings > 0 then
    print('WARNINGS:')
    for _, warn in ipairs(warnings) do
      print('  ' .. warn)
    end
    print('')
  end

  if #info > 0 then
    print('INFO:')
    for _, msg in ipairs(info) do
      print('  ' .. msg)
    end
    print('')
  end

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')

  if #errors > 0 then
    print('❌ VALIDATION FAILED - ' .. #errors .. ' error(s), ' .. #warnings .. ' warning(s)')
    return false
  else
    print('✅ VALIDATION PASSED - 0 errors, ' .. #warnings .. ' warning(s)')
    return true
  end
end

--- Main execution
local function main()
  local args = {...}

  if #args == 0 then
    print('Usage: lua config/validate-config.lua <config_file>')
    print('')
    print('Examples:')
    print('  lua config/validate-config.lua config/team-profiles/backend.lua')
    print('  lua config/validate-config.lua config/team-profiles/frontend.lua')
    print('  lua config/validate-config.lua config/team-profiles/devops.lua')
    os.exit(1)
  end

  local filepath = args[1]

  -- Check if file exists
  local file = io.open(filepath, 'r')
  if not file then
    print('❌ ERROR: File not found: ' .. filepath)
    os.exit(1)
  end
  file:close()

  -- Validate configuration
  local valid = validate_config_file(filepath)

  -- Print results
  local success = print_results()

  -- Exit with appropriate code
  os.exit(success and 0 or 1)
end

-- Run if executed directly
if arg and arg[0] and arg[0]:match('validate%-config%.lua$') then
  main(unpack(arg))
end

return {
  validate_config_file = validate_config_file,
  validate_window = validate_window,
  validate_keymaps = validate_keymaps,
  validate_command_variants = validate_command_variants,
  validate_git = validate_git,
  validate_refresh = validate_refresh,
}
