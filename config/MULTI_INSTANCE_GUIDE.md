# Multi-Instance Mode Guide

## Overview

**Multi-instance mode** enables isolated Claude Code sessions per git repository, preventing context pollution in polyrepo environments. Each repository gets its own independent terminal buffer, conversation history, and state.

---

## Architecture

### Instance Isolation Model

```
Workspace
├── frontend-app/          → Instance 1: "frontend-app"
│   └── .git/
├── backend-api/           → Instance 2: "backend-api"
│   └── .git/
├── infra-terraform/       → Instance 3: "infra-terraform"
│   └── .git/
└── docs/                  → Instance 4: "docs" (CWD fallback)
```

**Key Concepts:**
- **Instance ID**: Git root path or current working directory
- **Buffer Isolation**: Each instance has its own terminal buffer
- **State Persistence**: Instances remain active when switching repos
- **Automatic Detection**: Git root auto-detected on `:ClaudeCode`

---

## Configuration

### Enable Multi-Instance Mode

**Already enabled in all team profiles:**

```lua
git = {
  use_git_root = true,      -- Auto-detect git repository root
  multi_instance = true,    -- Enable per-repo instances
}
```

### Configuration Options

```lua
git = {
  -- Use git root as instance identifier (recommended for polyrepo)
  use_git_root = true,

  -- Enable multiple instances (one per repo)
  multi_instance = true,

  -- Alternative: Use CWD as instance identifier
  -- use_git_root = false,  -- Use current working directory instead
}
```

### Single vs Multi-Instance Comparison

| Mode | Instance ID | Use Case | Behavior |
|------|-------------|----------|----------|
| **Multi-Instance** (default) | Git root or CWD | Polyrepo teams | Separate instance per repo |
| **Single Instance** | `'global'` | Monorepo teams | One shared instance |

**To disable multi-instance:**
```lua
git = {
  multi_instance = false,  -- Use single global instance
}
```

---

## Basic Workflows

### Switching Between Repositories

**Scenario:** Working on frontend and backend simultaneously

```vim
" Start in frontend repository
:cd ~/repos/frontend-app
:ClaudeCode
" Instance created: "frontend-app"

" Switch to backend repository
:cd ~/repos/backend-api
:ClaudeCode
" Instance created: "backend-api" (frontend-app still active!)

" Switch back to frontend
:cd ~/repos/frontend-app
:ClaudeCode
" Returns to existing "frontend-app" instance
```

**Key Behavior:** Instances persist when switching directories

### Interactive Instance Switching

**Use the instance picker:**

```vim
:ClaudeCodeInstanceSwitch
" Interactive menu:
" ● frontend-app
"   backend-api
"   infra-terraform
" Select with j/k, Enter to switch
```

**Features:**
- Current instance marked with `●`
- Automatic directory change
- Orphaned instances filtered out

---

## Instance Management Commands

### List All Instances

```vim
:ClaudeCodeInstances
```

**Output:**
```
Claude Code Instances (3 total, 3 valid)
────────────────────────────────────────
● [1] frontend-app (valid)
○ [2] backend-api (valid)
○ [3] infra-terraform (valid)

Current: frontend-app
```

### Show Instance Statistics

```vim
:ClaudeCodeInstanceStats
```

**Output:**
```
Instance Statistics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total:    3
Valid:    3
Loaded:   2
Orphaned: 0
Current:  frontend-app
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Show Current Instance

```vim
:ClaudeCodeInstanceCurrent
```

**Output:**
```
Current instance: frontend-app
Path: /home/user/repos/frontend-app
```

### Clean Up Orphaned Instances

```vim
:ClaudeCodeInstanceCleanup
```

**What it does:**
- Removes invalid buffer references
- Frees memory from dead instances
- Safe to run anytime

**When to use:**
- After deleting a repository
- If instance list shows orphaned entries
- Memory cleanup

---

## Advanced Workflows

### Polyrepo Microservices Team

**Scenario:** 10+ microservice repositories

```vim
" Profile: Backend (multi-instance enabled)

" Service 1: Auth API
:cd ~/microservices/auth-service
:ClaudeCode
:ClaudeCodeAPI  " Variant for API work

" Service 2: Payment API
:cd ~/microservices/payment-service
:ClaudeCode
:ClaudeCodeDatabase  " Variant for DB work

" Service 3: Notification Service
:cd ~/microservices/notification-service
:ClaudeCode

" Quick switch between services
:ClaudeCodeInstanceSwitch  " Pick from menu
```

**Benefits:**
- Each service has isolated context
- No conversation cross-contamination
- Fast switching without losing state

### Monorepo with Multiple Packages

**Scenario:** Frontend monorepo with 5 packages

```lua
-- Configuration for monorepo
git = {
  use_git_root = true,       -- All packages share one instance
  multi_instance = false,    -- Single instance at monorepo root
}
```

**Alternative:** Enable multi-instance with CWD

```lua
git = {
  use_git_root = false,      -- Use current directory
  multi_instance = true,     -- Separate instance per package
}
```

```vim
" Package-level instances
:cd ~/monorepo/packages/ui-components
:ClaudeCode  " Instance: "ui-components"

:cd ~/monorepo/packages/design-system
:ClaudeCode  " Instance: "design-system"
```

### Cross-Repository Context

**Scenario:** Need context from multiple repos

**Option 1: Use shared notes/context files**
```vim
" In frontend repo
:ClaudeCode
" Paste API contract from backend repo
```

**Option 2: Manual instance switching**
```vim
" Check backend API
:cd ~/repos/backend-api
:ClaudeCode
" Review API endpoint

" Return to frontend
:cd ~/repos/frontend-app
:ClaudeCode
" Implement frontend integration
```

**Option 3: Use workspace-specific configuration**
```lua
-- .nvim.lua in frontend repo
local config = require('claude-code.config.team-profiles.frontend')

-- Add custom variant with cross-repo context
config.command_variants.APIIntegration = '--context ../backend-api/docs/api.md'

require('claude-code').setup(config)
```

---

## Performance Considerations

### Memory Usage

**Per Instance:**
- Terminal buffer: ~50KB
- Conversation history: Varies (stored by Claude CLI)
- Total per instance: <100KB typically

**Recommended Limits:**
- Light usage: Up to 10 instances
- Heavy usage: Monitor with `:ClaudeCodeInstanceStats`
- Clean up periodically: `:ClaudeCodeInstanceCleanup`

### Optimization Tips

**For large polyrepo setups (20+ repos):**

```lua
-- Adjust refresh intervals to reduce overhead
refresh = {
  updatetime = 200,       -- Increase from 100ms
  timer_interval = 2000,  -- Increase from 1000ms
}
```

**Regular cleanup:**
```vim
" Add to your workflow (weekly)
:ClaudeCodeInstanceCleanup
:ClaudeCodeInstanceStats  " Verify cleanup
```

---

## Best Practices

### Team Standards

**1. Standardize on multi-instance mode for polyrepos**
```lua
-- Team default in all profiles
git = {
  use_git_root = true,
  multi_instance = true,
}
```

**2. Document instance naming conventions**
- Use git repository names as-is
- Avoid renaming repos (breaks instance persistence)
- Keep repo names short and descriptive

**3. Clean up regularly**
- Weekly: `:ClaudeCodeInstanceCleanup`
- After deleting repos: Manual cleanup
- Monitor stats: `:ClaudeCodeInstanceStats`

### Workflow Integration

**Git hooks for instance cleanup:**
```bash
# .git/hooks/post-checkout
#!/bin/bash
# Cleanup after branch switches
nvim --headless -c 'ClaudeCodeInstanceCleanup' -c 'qa'
```

**Tmux/Terminal multiplexer integration:**
```bash
# Each tmux window has its own repo
tmux new-window -c ~/repos/frontend-app -n "frontend"
tmux new-window -c ~/repos/backend-api -n "backend"
# Neovim in each window gets correct instance
```

**VS Code Live Share / Pair Programming:**
- Each developer maintains their own instances
- Share screen to show Claude interactions
- No instance conflicts

---

## Troubleshooting

### Issue: Wrong Instance Activated

**Symptom:** `:ClaudeCode` opens wrong repository's instance

**Diagnosis:**
```vim
:pwd                           " Check current directory
:ClaudeCodeInstanceCurrent     " Check active instance
:lua print(require('claude-code.git').get_git_root())  " Check git root
```

**Solution:**
```vim
:cd /correct/repo/path         " Change to correct directory
:ClaudeCode                    " Now opens correct instance
```

### Issue: Instance Not Found

**Symptom:** "Instance not found" when switching

**Diagnosis:**
```vim
:ClaudeCodeInstances          " List all instances
:ClaudeCodeInstanceStats      " Check orphaned count
```

**Solution:**
```vim
:ClaudeCodeInstanceCleanup    " Remove invalid instances
:cd /target/repo
:ClaudeCodeInstanceCreate     " Create new instance
```

### Issue: Too Many Instances

**Symptom:** Slow performance, high memory usage

**Diagnosis:**
```vim
:ClaudeCodeInstanceStats      " Check total count
:ClaudeCodeInstances          " Review instance list
```

**Solution:**
```vim
" Close unused instances (close terminal buffers)
:bd! <buffer-number>

" Or clean up orphaned
:ClaudeCodeInstanceCleanup

" Verify cleanup
:ClaudeCodeInstanceStats
```

### Issue: Instance State Lost

**Symptom:** Conversation history missing after restart

**Cause:** Claude CLI conversation state (not plugin issue)

**Solution:**
- Use `:ClaudeCodeResume` to restore conversations
- Check Claude CLI configuration
- Conversation history stored in `~/.claude/` (by CLI)

### Issue: Git Root Detection Failing

**Symptom:** Using CWD instead of git root

**Diagnosis:**
```vim
:lua print(require('claude-code.git').get_git_root())
" Should print: /path/to/repo
" If nil: Not in a git repo
```

**Solution:**
```bash
# Ensure you're in a git repository
cd /path/to/repo
git rev-parse --show-toplevel  # Should show repo root

# If not a git repo, initialize
git init
```

**Fallback:** Use CWD-based instances
```lua
git = {
  use_git_root = false,   -- Use CWD instead
  multi_instance = true,
}
```

---

## Programmatic Access (Lua API)

### List Instances

```lua
local instance_manager = require('claude-code.instance_manager')
local instances = instance_manager.list_instances()

for _, instance in ipairs(instances) do
  print(instance.name, instance.is_current, instance.is_valid)
end
```

### Get Current Instance

```lua
local current = instance_manager.get_current_instance()
if current then
  print('Current:', current.id)
else
  print('No active instance')
end
```

### Switch Instance

```lua
local success = instance_manager.switch_to_instance('/path/to/repo')
if success then
  print('Switched successfully')
end
```

### Get Statistics

```lua
local stats = instance_manager.get_stats()
print('Total:', stats.total)
print('Valid:', stats.valid)
print('Orphaned:', stats.orphaned)
```

### Cleanup

```lua
local cleaned = instance_manager.cleanup_orphaned()
print('Cleaned', cleaned, 'instances')
```

---

## Migration from Single Instance

### Step 1: Backup Current State

```vim
" Save current conversations
:ClaudeCodeResume  " Review active conversations
```

### Step 2: Enable Multi-Instance

```lua
-- Update configuration
git = {
  use_git_root = true,
  multi_instance = true,  -- Change from false
}
```

### Step 3: Reload Plugin

```vim
:Lazy reload claude-code.nvim
```

### Step 4: Verify

```vim
:cd /first/repo
:ClaudeCode
:ClaudeCodeInstanceStats  " Should show 1 instance

:cd /second/repo
:ClaudeCode
:ClaudeCodeInstanceStats  " Should show 2 instances
```

---

## Quick Reference

### Commands

| Command | Description |
|---------|-------------|
| `:ClaudeCodeInstances` | List all instances |
| `:ClaudeCodeInstanceSwitch` | Interactive switcher |
| `:ClaudeCodeInstanceCurrent` | Show current instance |
| `:ClaudeCodeInstanceStats` | Show statistics |
| `:ClaudeCodeInstanceCleanup` | Clean orphaned instances |
| `:ClaudeCodeInstanceCreate` | Create instance for CWD |

### Configuration

```lua
git = {
  use_git_root = true,    -- Use git root (recommended)
  multi_instance = true,  -- Enable multi-instance
}
```

### Key Behaviors

- **Instance created on:** First `:ClaudeCode` in a directory
- **Instance persists when:** Switching directories
- **Instance removed when:** Buffer deleted or cleanup
- **Git root detection:** Automatic via `git rev-parse`
- **CWD fallback:** Used when not in git repo

---

## Support

**Instance not behaving as expected?**

1. Check configuration: `:lua vim.print(require('claude-code').config.git)`
2. Check current instance: `:ClaudeCodeInstanceCurrent`
3. Check git root: `:lua print(require('claude-code.git').get_git_root())`
4. Review instances: `:ClaudeCodeInstances`
5. Clean up: `:ClaudeCodeInstanceCleanup`

**Performance issues with many instances?**

1. Check stats: `:ClaudeCodeInstanceStats`
2. Clean orphaned: `:ClaudeCodeInstanceCleanup`
3. Increase refresh intervals in config
4. Close unused instances: `:bd! <bufnr>`

---

**Estimated Reading Time:** 15 minutes
**Implementation Time:** Already enabled in team profiles!
