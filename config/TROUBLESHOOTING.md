# Troubleshooting Guide

## Quick Diagnostics

**Run these commands when experiencing issues:**

```vim
:checkhealth claude-code              " Health check
:lua vim.print(require('claude-code').config)  " Show config
:ClaudeCodeInstanceStats               " Multi-instance stats
:messages                              " Recent error messages
```

---

## Multi-Instance Issues

### Wrong Instance Activated

**Symptom:** Opening Claude Code shows wrong repository's context

**Diagnosis:**
```vim
:pwd                                   " Current directory
:ClaudeCodeInstanceCurrent             " Active instance
:lua print(require('claude-code.git').get_git_root())  " Git root
```

**Common Causes:**
1. Wrong working directory
2. Nested git repositories (submodules)
3. Symbolic links to different repos

**Solutions:**

```vim
" Solution 1: Change to correct directory
:cd /path/to/correct/repo
:ClaudeCode

" Solution 2: Verify git root detection
:lua print(require('claude-code.git').get_git_root())
" Should match expected repo

" Solution 3: Clean and recreate instance
:bd! <buffer-number>                   " Close wrong instance
:cd /correct/repo
:ClaudeCode                            " Create new instance
```

### Instance Not Found After Restart

**Symptom:** `:ClaudeCodeInstanceSwitch` shows no instances after Neovim restart

**Cause:** Instances are session-specific (intentional design)

**Explanation:**
- Instances only exist while Neovim is running
- Terminal buffers don't persist across restarts
- Conversation history is managed by Claude CLI (not plugin)

**Solutions:**

```vim
" Recreate instances by visiting repos
:cd ~/repos/frontend-app
:ClaudeCode                            " Instance 1 created

:cd ~/repos/backend-api
:ClaudeCode                            " Instance 2 created

" Resume previous conversations
:ClaudeCodeResume                      " Claude CLI feature
```

### Too Many Instances (Performance)

**Symptom:** Neovim slow with many instances

**Diagnosis:**
```vim
:ClaudeCodeInstanceStats
" Check total count

:ClaudeCodeInstances
" Review instance list
```

**Recommended Limits:**
- **Light usage:** Up to 10 instances
- **Moderate usage:** 10-20 instances
- **Heavy usage:** 20+ instances (monitor performance)

**Solutions:**

```vim
" Option 1: Close unused instances
:buffers                               " List all buffers
:bd! <buffer-number>                   " Delete specific buffer

" Option 2: Clean orphaned instances
:ClaudeCodeInstanceCleanup

" Option 3: Adjust refresh settings
lua << EOF
require('claude-code').setup({
  refresh = {
    updatetime = 200,      " Increase from 100ms
    timer_interval = 2000, " Increase from 1000ms
  }
})
EOF

" Option 4: Disable multi-instance temporarily
lua << EOF
require('claude-code').setup({
  git = { multi_instance = false }
})
EOF
```

### Orphaned Instances

**Symptom:** `:ClaudeCodeInstances` shows instances marked as "orphaned"

**Cause:** Buffer deleted but reference still exists

**Solutions:**

```vim
" Automatic cleanup
:ClaudeCodeInstanceCleanup

" Manual cleanup (if needed)
:lua require('claude-code.terminal').terminal.instances = {}
```

### Git Root Detection Failing

**Symptom:** Using CWD instead of git root

**Diagnosis:**
```vim
:lua print(require('claude-code.git').get_git_root())
" Returns nil if not in git repo
```

**Solutions:**

```bash
# Verify git repository
cd /path/to/repo
git rev-parse --show-toplevel

# If not a git repo, initialize
git init
```

**Workaround:** Use CWD-based instances
```lua
git = {
  use_git_root = false,   " Use current directory
  multi_instance = true,
}
```

---

## Configuration Issues

### Keymap Not Working

**Symptom:** Keymap doesn't trigger or triggers wrong action

**Diagnosis:**
```vim
" Check keymap registration
:nmap <leader>ai                       " See what it's mapped to
:verbose nmap <leader>ai               " See where defined

" Check for conflicts
lua << EOF
local keys = vim.api.nvim_get_keymap('n')
for _, map in ipairs(keys) do
  if map.lhs:match('<leader>') then
    print(map.lhs, map.rhs or map.callback)
  end
end
EOF
```

**Solutions:**

```lua
-- Change to unused keymap
keymaps = {
  toggle = {
    normal = '<leader>cc',   -- Different key
    terminal = '<C-,>',
  }
}
```

**Validation:**
```bash
lua config/validate-config.lua <your-config-file>
```

### Configuration Not Loading

**Symptom:** Changes to config have no effect

**Diagnosis:**
```vim
" Check current config
:lua vim.print(require('claude-code').config)

" Check if plugin loaded
:lua print(package.loaded['claude-code'])
```

**Solutions:**

```vim
" Option 1: Reload plugin
:Lazy reload claude-code.nvim

" Option 2: Restart Neovim
:qa!

" Option 3: Check for errors
:messages
:lua vim.print(require('claude-code').config)
```

**Common Mistakes:**
```lua
-- ❌ Wrong: Modifying after setup
require('claude-code').setup()
require('claude-code').config.window.position = 'float'  -- Won't work!

-- ✅ Correct: Pass config to setup
require('claude-code').setup({
  window = { position = 'float' }
})
```

### Floating Window Not Appearing

**Symptom:** `:ClaudeCode` with `position = 'float'` shows nothing or errors

**Diagnosis:**
```vim
:messages                              " Check for errors
:lua vim.print(require('claude-code').config.window)
```

**Common Causes:**
1. Invalid float configuration
2. Dimensions too large
3. Border style error

**Solutions:**

```lua
-- Verify float config
window = {
  position = 'float',
  float = {
    width = '80%',         -- Use percentage
    height = '80%',
    row = 'center',        -- Use 'center' or number
    col = 'center',
    border = 'rounded',    -- Valid: none, single, double, rounded
    relative = 'editor',   -- Valid: editor, cursor
  }
}
```

### Multi-Instance Not Working

**Symptom:** All repos share same instance

**Diagnosis:**
```vim
:lua vim.print(require('claude-code').config.git)
" Check multi_instance setting
```

**Solutions:**

```lua
-- Ensure multi-instance enabled
git = {
  use_git_root = true,
  multi_instance = true,    -- Must be true!
}
```

```vim
" Reload with correct config
:Lazy reload claude-code.nvim

" Verify it worked
:cd /repo1
:ClaudeCode
:ClaudeCodeInstanceCurrent
" Should show repo1

:cd /repo2
:ClaudeCode
:ClaudeCodeInstanceCurrent
" Should show repo2 (different instance!)
```

---

## Terminal/Window Issues

### Terminal Not Opening

**Symptom:** `:ClaudeCode` command exists but nothing happens

**Diagnosis:**
```vim
:messages                              " Check errors
:lua print(vim.fn.executable('claude'))  " Check if CLI installed
```

**Solutions:**

```bash
# Verify Claude Code CLI installed
which claude
claude --version

# Install if missing
# (See Claude Code installation docs)
```

```vim
" Check command configuration
:lua print(require('claude-code').config.command)
" Should print: "claude"

" Test terminal creation manually
:terminal claude
" Should open Claude CLI
```

### Terminal Closes Immediately

**Symptom:** Terminal opens then instantly closes

**Cause:** Shell command error or misconfiguration

**Solutions:**

```vim
" Check terminal job status
:lua print(vim.b.terminal_job_id)

" Try manual terminal
:terminal
" Type: claude
" Check for errors
```

### Can't Exit Terminal Mode

**Symptom:** Stuck in terminal insert mode

**Solutions:**

```vim
" Default exit keymaps
<C-\><C-n>                             " Exit terminal mode (Neovim default)
<C-,>                                  " Toggle (if configured)

" If stuck, force normal mode
<C-c>                                  " Terminal interrupt
:stopinsert<CR>                        " Force normal mode
```

### Window Positioning Wrong

**Symptom:** Terminal appears in wrong position

**Diagnosis:**
```vim
:lua print(require('claude-code').config.window.position)
```

**Solutions:**

```lua
-- Try different positions
window = {
  position = 'right',      -- Options: top, bottom, left, right, float
  split_ratio = 0.3,       -- 30% of screen
}
```

---

## File Refresh Issues

### Files Not Auto-Reloading

**Symptom:** Claude modifies files but Neovim doesn't reload

**Diagnosis:**
```vim
:set autoread?                         " Should be on
:lua print(require('claude-code').config.refresh.enable)  " Should be true
```

**Solutions:**

```vim
" Ensure autoread enabled
:set autoread

" Check refresh config
:lua vim.print(require('claude-code').config.refresh)

" Manual reload
:checktime                             " Force check for changes
:e                                     " Reload current buffer
```

```lua
-- Adjust refresh settings
refresh = {
  enable = true,
  updatetime = 100,        " Faster detection
  timer_interval = 1000,   " Check every 1s
  show_notifications = true,
}
```

### Too Many Refresh Notifications

**Symptom:** Constant "File reloaded" notifications

**Solutions:**

```lua
-- Disable notifications
refresh = {
  enable = true,
  show_notifications = false,  -- Turn off notifications
}
```

### File Refresh Causing Lag

**Symptom:** Neovim slow when Claude Code active

**Solutions:**

```lua
-- Increase intervals
refresh = {
  updatetime = 200,        -- Increase from 100ms
  timer_interval = 2000,   " Check less often
}
```

---

## Installation Issues

### Plugin Not Found

**Symptom:** `:checkhealth` shows plugin not installed

**Solutions:**

**Lazy.nvim:**
```lua
-- Verify plugin spec
return {
  'anthropics/claude-code.nvim',  -- Correct repo path
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup()
  end,
}
```

```vim
:Lazy sync                             " Install/update plugins
:Lazy reload claude-code.nvim
```

**Packer:**
```vim
:PackerSync                            " Install/update
:PackerCompile
```

### Dependency Missing (plenary.nvim)

**Symptom:** Error about `plenary` not found

**Solutions:**

```lua
-- Ensure dependency listed
dependencies = { 'nvim-lua/plenary.nvim' }
```

```vim
:Lazy install                          " Install dependencies
```

### Commands Not Available

**Symptom:** `:ClaudeCode` command not found

**Diagnosis:**
```vim
:command ClaudeCode                    " Check if registered
:lua print(package.loaded['claude-code'])  " Check if loaded
```

**Solutions:**

```vim
" Force load plugin
:lua require('claude-code').setup()

" Check for errors
:messages

" Restart Neovim
:qa!
nvim
```

---

## Performance Troubleshooting

### Neovim Slow with Plugin

**Diagnosis:**
```vim
:ClaudeCodeInstanceStats               " Check instance count

" Profile startup
nvim --startuptime startup.log
" Check claude-code loading time
```

**Solutions:**

1. **Reduce instance count:**
```vim
:ClaudeCodeInstanceCleanup
:ClaudeCodeInstanceStats               " Verify reduction
```

2. **Adjust refresh intervals:**
```lua
refresh = {
  updatetime = 200,
  timer_interval = 2000,
}
```

3. **Lazy load plugin:**
```lua
-- Lazy.nvim
{
  'anthropics/claude-code.nvim',
  lazy = true,                         " Don't load at startup
  cmd = { 'ClaudeCode', 'ClaudeCodeToggle' },  " Load on command
}
```

### High Memory Usage

**Diagnosis:**
```vim
" Check instance count
:ClaudeCodeInstanceStats

" Check buffer count
:buffers
```

**Solutions:**
```vim
" Close unused buffers
:bd! <buffer-number>

" Clean orphaned instances
:ClaudeCodeInstanceCleanup

" Restart Neovim periodically
```

---

## Getting Additional Help

### Health Check

```vim
:checkhealth claude-code
```

**What it checks:**
- Plugin installation
- Dependencies
- Configuration validity
- Command availability

### Debug Information

```vim
" Collect debug info
:messages                              " Recent errors
:lua vim.print(require('claude-code').config)  " Config
:lua vim.print(require('claude-code.terminal').terminal)  " Instances
:ClaudeCodeInstanceStats               " Instance stats
```

### Report Issues

**Include in bug reports:**
1. Neovim version: `:version`
2. Plugin version: `:lua print(require('claude-code').version.string())`
3. Configuration: `:lua vim.print(require('claude-code').config)`
4. Error messages: `:messages`
5. Steps to reproduce

### Community Resources

- **Documentation:** `:h claude-code`
- **GitHub Issues:** Report bugs
- **Discussions:** Feature requests
- **Wiki:** Community configurations

---

## Common Error Messages

### "Instance not found or invalid"

```vim
:ClaudeCodeInstanceCleanup
:cd /correct/repo
:ClaudeCode
```

### "Failed to change directory"

```bash
# Verify directory exists
ls -la /path/to/repo

# Check permissions
stat /path/to/repo
```

### "No active Claude Code instance"

```vim
:cd /any/repo
:ClaudeCode                            " Create instance
```

### "window.split_ratio must be between 0 and 1"

```lua
-- Fix config
window = {
  split_ratio = 0.3,     -- Use decimal, not percentage
}
```

---

## Reset to Defaults

**Nuclear option when all else fails:**

```vim
" Close all Claude instances
:buffers
:bd! <each-claude-buffer>

" Clear instances
:lua require('claude-code.terminal').terminal.instances = {}

" Reload with defaults
:lua require('claude-code').setup()

" Restart Neovim
:qa!
```

**Start fresh:**
```bash
# Remove configuration
rm ~/.config/nvim/lua/plugins/claude-code.lua

# Reinstall plugin
nvim
:Lazy clean
:Lazy install claude-code.nvim
```

---

## Still Having Issues?

1. ✅ Run `:checkhealth claude-code`
2. ✅ Check `:messages` for errors
3. ✅ Review configuration with `:lua vim.print(require('claude-code').config)`
4. ✅ Try with default config: `:lua require('claude-code').setup()`
5. ✅ Report issue with debug info on GitHub

**Most issues resolved by:**
- Verifying configuration syntax
- Ensuring dependencies installed
- Running `:ClaudeCodeInstanceCleanup`
- Reloading plugin with `:Lazy reload`
