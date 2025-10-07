# Team Onboarding Guide - Claude Code Neovim Plugin

## Quick Start (5 Minutes)

### Step 1: Install Plugin

**Lazy.nvim (Recommended):**
```lua
-- ~/.config/nvim/lua/plugins/claude-code.lua
return {
  'anthropics/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup()  -- Start with defaults
  end,
}
```

### Step 2: Verify Installation

```vim
:checkhealth claude-code
:lua print(require('claude-code').version.string())
```

### Step 3: Test Basic Commands

```vim
:ClaudeCode          " Open Claude Code terminal
<C-,>                " Toggle (default keymap)
:ClaudeCodeContinue  " Resume conversation
```

**✅ If the terminal opens, you're ready!**

---

## Role-Based Profiles

Choose your configuration based on your primary role:

### 🔧 Backend Developer

**Installation:**
```bash
# Copy backend profile to your Neovim config
cp config/workspace-templates/lazy-nvim-backend.lua ~/.config/nvim/lua/plugins/claude-code.lua
```

**Key Features:**
- **Window:** Vertical split (35% width) on right side
- **Keymaps:**
  - `<leader>ai` - Toggle Claude Code
  - `<leader>aa` - API context mode
  - `<leader>ad` - Database context mode
  - `<leader>at` - Test generation mode
  - `<leader>ar` - Security review mode

**Command Variants:**
- `:ClaudeCodeAPI` - API development context
- `:ClaudeCodeDatabase` - Database schema assistance
- `:ClaudeCodeTest` - Test generation with coverage
- `:ClaudeCodeReview` - Security-focused code review

**Recommended for:** Microservices, API development, database work

---

### 🎨 Frontend Developer

**Installation:**
```bash
cp config/workspace-templates/lazy-nvim-frontend.lua ~/.config/nvim/lua/plugins/claude-code.lua
```

**Key Features:**
- **Window:** Floating (90% screen) for maximum visibility
- **Keymaps:**
  - `<leader>cc` - Toggle Claude Code
  - `<leader>cp` - Component development mode
  - `<leader>cs` - Style/CSS mode
  - `<leader>ct` - Unit testing mode
  - `<leader>cf` - Performance optimization

**Command Variants:**
- `:ClaudeCodeComponent` - Component development with TypeScript
- `:ClaudeCodeStyle` - CSS/design system assistance
- `:ClaudeCodePerf` - Performance optimization
- `:ClaudeCodeA11y` - Accessibility review

**Recommended for:** React/Vue/Angular, component libraries, UI development

---

### ⚙️ DevOps/SRE

**Installation:**
```bash
cp config/workspace-templates/lazy-nvim-devops.lua ~/.config/nvim/lua/plugins/claude-code.lua
```

**Key Features:**
- **Window:** Bottom split (50% height) terminal-style
- **Keymaps:**
  - `<leader>op` - Toggle Claude Code
  - `<leader>oi` - Infrastructure mode
  - `<leader>ok` - Kubernetes mode
  - `<leader>od` - Deployment mode
  - `<leader>os` - Security scan mode
  - `<leader>ox` - Debug/logs mode

**Command Variants:**
- `:ClaudeCodeInfra` - Terraform/infrastructure context
- `:ClaudeCodeK8s` - Kubernetes manifest assistance
- `:ClaudeCodeDeploy` - Deployment planning (dry-run)
- `:ClaudeCodeSecurity` - Compliance and security scanning

**Recommended for:** Infrastructure, CI/CD, monitoring, deployments

---

## Validation & Testing

### Validate Your Configuration

```bash
# From plugin root directory
lua config/validate-config.lua config/team-profiles/backend.lua
```

**Expected Output:**
```
✅ VALIDATION PASSED - 0 errors, 0 warnings
```

### Test in Neovim

```vim
" 1. Check configuration loaded
:lua vim.print(require('claude-code').config)

" 2. Test keymaps
<leader>ai  " Should toggle terminal (backend)
<leader>cc  " Should toggle terminal (frontend)
<leader>op  " Should toggle terminal (devops)

" 3. Test command variants
:ClaudeCodeAPI      " Backend variant
:ClaudeCodeComponent " Frontend variant
:ClaudeCodeK8s      " DevOps variant
```

---

## Common Issues & Solutions

### Issue: Keymap Conflicts

**Problem:** Keymap doesn't work or triggers another plugin

**Solution:** Check for conflicts
```bash
lua config/validate-config.lua <your-config-file>
```

**Fix:** Customize keymaps in your config:
```lua
keymaps = {
  toggle = {
    normal = '<leader>cc',  -- Change to unused keymap
  }
}
```

### Issue: Multi-Instance Not Working

**Problem:** All repositories share same Claude instance

**Solution:** Verify git configuration:
```lua
git = {
  use_git_root = true,
  multi_instance = true,  -- Must be true
}
```

### Issue: File Refresh Too Slow/Fast

**Problem:** Files reload too slowly or cause lag

**Solution:** Adjust refresh intervals:
```lua
refresh = {
  updatetime = 100,       -- Increase if laggy (e.g., 200)
  timer_interval = 1000,  -- Decrease for faster checks (e.g., 500)
}
```

---

## Team Standards & Best Practices

### Keymap Conventions

**Reserved Prefixes:**
- `<leader>a*` - Backend (API, AI)
- `<leader>c*` - Frontend (Component, Claude)
- `<leader>o*` - DevOps (Ops)

**Common Across Roles:**
- `<C-,>` - Terminal mode toggle (universal)
- `<leader>*c` - Continue conversation
- `<leader>*v` - Verbose mode

### Project-Specific Configuration

**Per-Project Overrides:**
```lua
-- .nvim.lua in project root
local config = require('claude-code.config.team-profiles.backend')

-- Override for this project
config.command_variants.API = '--context api --openapi-spec docs/openapi.yaml'

require('claude-code').setup(config)
```

### Git Workflow Integration

**Multi-Repo Teams:**
- Enable `multi_instance = true`
- Each repository gets isolated Claude instance
- No context pollution between projects

**Monorepo Teams:**
- Use `use_git_root = true`
- Single instance at monorepo root
- Consistent context across packages

---

## Performance Tuning

### For Large Codebases (>100K LOC)

```lua
refresh = {
  updatetime = 200,       -- Reduce frequency
  timer_interval = 2000,  -- Check every 2 seconds
  show_notifications = false,  -- Reduce noise
}
```

### For Fast Iteration (Hot Reload)

```lua
refresh = {
  updatetime = 50,        -- Ultra-fast detection
  timer_interval = 300,   -- Check every 300ms
  show_notifications = false,  -- Too many updates
}
```

### For Remote Development (SSH)

```lua
refresh = {
  updatetime = 500,       -- Reduce network load
  timer_interval = 3000,  -- Less frequent checks
}
```

---

## Migration from Default Config

### Step 1: Export Current Settings

```vim
" In Neovim, check current config
:lua vim.print(require('claude-code').config)
```

### Step 2: Choose Profile

Select role-based profile closest to your workflow:
- Backend → `backend.lua`
- Frontend → `frontend.lua`
- DevOps → `devops.lua`

### Step 3: Copy & Customize

```bash
# Copy template
cp config/workspace-templates/lazy-nvim-backend.lua ~/.config/nvim/lua/plugins/claude-code.lua

# Edit to match your preferences
nvim ~/.config/nvim/lua/plugins/claude-code.lua
```

### Step 4: Validate & Reload

```bash
# Validate
lua config/validate-config.lua config/team-profiles/backend.lua

# Reload Neovim config
:Lazy reload claude-code.nvim
```

---

## Next Steps

### Phase 3: Multi-Instance Mode (Advanced Teams)
- Polyrepo environment setup
- Per-repository context isolation
- Instance switching workflows

### Phase 4: AI Integration (Optional)
- Local NexaMind API setup
- Code quality analysis
- Intelligent suggestions

---

## Getting Help

**Documentation:**
- `:h claude-code` - Plugin help
- `README.md` - Full feature list
- `CLAUDE.md` - Development guide

**Validation:**
- `lua config/validate-config.lua <file>` - Check config
- `:checkhealth claude-code` - System health

**Community:**
- GitHub Issues: Report bugs
- Discussions: Feature requests
- Wiki: Community configs

---

## Quick Reference

| Role | Keymap Prefix | Window Position | Primary Use Case |
|------|---------------|-----------------|------------------|
| Backend | `<leader>a*` | Right (35%) | APIs, databases, microservices |
| Frontend | `<leader>c*` | Float (90%) | Components, styling, UI |
| DevOps | `<leader>o*` | Bottom (50%) | Infrastructure, deployments |

**Universal Keymaps:**
- `<C-,>` - Toggle terminal (all modes)
- `<leader>*c` - Continue conversation
- `:ClaudeCode` - Open terminal (command)

**Estimated Onboarding Time:** <5 minutes per developer
