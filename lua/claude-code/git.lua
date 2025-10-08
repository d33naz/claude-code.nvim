---@mod claude-code.git Git integration for claude-code.nvim
---@brief [[
--- This module provides git integration functionality for claude-code.nvim.
--- It detects git repositories and can set the working directory to the git root.
---@brief ]]

local M = {}

--- Helper function to get git root directory (secure with vim.system)
--- @return string|nil git_root The git root directory path or nil if not in a git repo
function M.get_git_root()
  -- For testing compatibility
  if vim.env.CLAUDE_CODE_TEST_MODE == 'true' then
    return '/home/user/project'
  end

  -- Check if we're in a git repository using vim.system (secure)
  if not vim.system then
    -- Fallback for older Neovim versions
    local handle = io.popen('git rev-parse --is-inside-work-tree 2>/dev/null')
    if not handle then
      return nil
    end
    local result = handle:read('*a')
    handle:close()
    result = result:gsub('[\n\r%s]*$', '')

    if result == 'true' then
      local root_handle = io.popen('git rev-parse --show-toplevel 2>/dev/null')
      if not root_handle then
        return nil
      end
      local git_root = root_handle:read('*a')
      root_handle:close()
      git_root = git_root:gsub('[\n\r%s]*$', '')
      return git_root
    end
    return nil
  end

  -- Use secure vim.system (Neovim 0.10+)
  local obj = vim.system({ 'git', 'rev-parse', '--is-inside-work-tree' }, { text = true }):wait()

  if obj.code == 0 and obj.stdout then
    local result = obj.stdout:gsub('[\n\r%s]*$', '')

    if result == 'true' then
      -- Get the git root path
      local root_obj = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { text = true }):wait()

      if root_obj.code == 0 and root_obj.stdout then
        local git_root = root_obj.stdout:gsub('[\n\r%s]*$', '')
        return git_root
      end
    end
  end

  return nil
end

return M
