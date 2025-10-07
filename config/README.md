# Configuration Directory

This directory contains team-based configuration profiles, templates, and migration tools for the claude-code.nvim plugin.

## Directory Structure

```
config/
├── team-profiles/           # Role-based configuration profiles
│   ├── backend.lua          # Backend developer profile
│   ├── frontend.lua         # Frontend developer profile
│   └── devops.lua           # DevOps/SRE profile
│
├── workspace-templates/     # Ready-to-use configuration templates
│   ├── .nvim.lua.backend    # Backend project template
│   ├── .nvim.lua.frontend   # Frontend project template
│   ├── .nvim.lua.devops     # DevOps project template
│   ├── lazy-nvim-backend.lua  # Backend Lazy.nvim config
│   ├── lazy-nvim-frontend.lua # Frontend Lazy.nvim config
│   └── lazy-nvim-devops.lua   # DevOps Lazy.nvim config
│
├── validate-config.lua      # Configuration validation utility
├── migrate-config.sh        # Migration helper script
├── TEAM_ONBOARDING.md       # Team onboarding guide
└── README.md                # This file
```

## Quick Start

### 1. Choose Your Profile

Select the configuration profile that matches your role:

- **Backend Developer** - API development, databases, microservices
- **Frontend Developer** - Components, styling, UI/UX
- **DevOps/SRE** - Infrastructure, deployment, monitoring

### 2. Install Configuration

**Option A: Automated Migration (Recommended)**
```bash
# From plugin root directory
./config/migrate-config.sh backend
./config/migrate-config.sh frontend
./config/migrate-config.sh devops
```

**Option B: Manual Installation**
```bash
# Copy template to your Neovim config
cp config/workspace-templates/lazy-nvim-backend.lua ~/.config/nvim/lua/plugins/claude-code.lua
```

**Option C: Project-Specific (Per-Repository)**
```bash
# Copy to project root
cp config/workspace-templates/.nvim.lua.backend .nvim.lua
```

### 3. Validate Configuration

```bash
# Validate before installing
lua config/validate-config.lua config/team-profiles/backend.lua

# Or use migration script with validation
./config/migrate-config.sh backend --validate
```

### 4. Reload Neovim

```vim
:Lazy reload claude-code.nvim
:lua print(require('claude-code').version.string())
```

## Profile Comparison

| Feature | Backend | Frontend | DevOps |
|---------|---------|----------|--------|
| **Window Position** | Right (35%) | Float (90%) | Bottom (50%) |
| **Keymap Prefix** | `<leader>a*` | `<leader>c*` | `<leader>o*` |
| **Multi-Instance** | ✅ Yes | ✅ Yes | ✅ Yes |
| **File Refresh** | 800ms | 500ms | 1500ms |
| **Primary Use Case** | APIs, DBs | Components, UI | Infra, CI/CD |

### Backend Profile Features

```lua
-- Keymaps
<leader>ai  -- Toggle Claude Code
<leader>aa  -- API context mode
<leader>ad  -- Database mode
<leader>at  -- Test generation
<leader>ar  -- Security review

-- Command Variants
:ClaudeCodeAPI
:ClaudeCodeDatabase
:ClaudeCodeTest
:ClaudeCodeReview
```

### Frontend Profile Features

```lua
-- Keymaps
<leader>cc  -- Toggle Claude Code
<leader>cp  -- Component mode
<leader>cs  -- Style/CSS mode
<leader>ct  -- Unit test mode
<leader>cf  -- Performance optimization

-- Command Variants
:ClaudeCodeComponent
:ClaudeCodeStyle
:ClaudeCodePerf
:ClaudeCodeA11y
```

### DevOps Profile Features

```lua
-- Keymaps
<leader>op  -- Toggle Claude Code
<leader>oi  -- Infrastructure mode
<leader>ok  -- Kubernetes mode
<leader>od  -- Deployment mode
<leader>os  -- Security scan
<leader>ox  -- Debug/logs mode

-- Command Variants
:ClaudeCodeInfra
:ClaudeCodeK8s
:ClaudeCodeDeploy
:ClaudeCodeSecurity
```

## Tools Reference

### validate-config.lua

**Purpose:** Validate configuration syntax and detect conflicts

**Usage:**
```bash
lua config/validate-config.lua <config_file>
```

**Features:**
- Syntax validation
- Type checking
- Keymap conflict detection
- Deprecated option warnings
- Actionable error messages

**Example:**
```bash
$ lua config/validate-config.lua config/team-profiles/backend.lua

🔍 Validating configuration: config/team-profiles/backend.lua

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  VALIDATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INFO:
  ℹ️  INFO: Window configuration valid (right split, 35.0%)
  ℹ️  INFO: No keymap conflicts detected with common plugins
  ℹ️  INFO: Found 7 configured keymaps
  ℹ️  INFO: Configured 6 command variants

✅ VALIDATION PASSED - 0 errors, 0 warnings
```

### migrate-config.sh

**Purpose:** Automated migration from default to role-based config

**Usage:**
```bash
./config/migrate-config.sh <profile> [options]
```

**Options:**
- `--dry-run` - Preview changes without applying
- `--backup-only` - Create backup only
- `--validate` - Validate profile before migration

**Examples:**
```bash
# Dry run (preview)
./config/migrate-config.sh backend --dry-run

# Validate before migrating
./config/migrate-config.sh frontend --validate

# Full migration
./config/migrate-config.sh devops
```

## Customization Guide

### Per-Project Configuration

Create a `.nvim.lua` file in your project root:

```lua
-- Load team profile
local config = require('claude-code.config.team-profiles.backend')

-- Override for this project
config.command_variants.API = '--context api --openapi-spec docs/api.yaml'
config.refresh.timer_interval = 500  -- Faster refresh for this project

require('claude-code').setup(config)
```

### Custom Command Variants

```lua
command_variants = {
  -- Built-in
  continue = '--continue',
  verbose = '--verbose',

  -- Custom for your workflow
  GraphQL = '--context graphql --schema schema.graphql',
  Prisma = '--context prisma --schema prisma/schema.prisma',
  E2E = '--test --e2e --playwright',
}
```

### Keymap Customization

```lua
keymaps = {
  toggle = {
    normal = '<leader>ai',        -- Change base keymap
    terminal = '<C-,>',
    variants = {
      continue = '<leader>ac',
      API = '<leader>aa',         -- Add custom variants
      GraphQL = '<leader>ag',
    },
  },
}
```

## Troubleshooting

### Validation Errors

**Error: "window.split_ratio must be between 0 and 1"**
```lua
-- Fix: Use decimal (0.3 = 30%)
window = { split_ratio = 0.3 }  -- ✅
window = { split_ratio = 30 }   -- ❌
```

**Error: "Keymap conflict detected"**
```lua
-- Fix: Choose different keymap
keymaps = {
  toggle = {
    normal = '<leader>cc',  -- Change to unused key
  }
}
```

### Migration Issues

**Issue: Backup not created**
- Ensure `~/.config/nvim/lua/plugins/` directory exists
- Check file permissions

**Issue: Profile not found**
- Verify you're in plugin root directory
- Check profile name spelling (backend, frontend, devops)

### Configuration Loading

**Issue: Changes not applied**
```vim
" Reload plugin
:Lazy reload claude-code.nvim

" Check config
:lua vim.print(require('claude-code').config)
```

## Best Practices

### Team Standardization

1. **Choose one profile per team**
2. **Document keymap choices in team wiki**
3. **Validate all configs before committing**
4. **Use project-specific `.nvim.lua` for overrides**

### Performance Optimization

```lua
-- Large codebase
refresh = { updatetime = 200, timer_interval = 2000 }

-- Fast iteration (hot reload)
refresh = { updatetime = 50, timer_interval = 300 }

-- Remote development (SSH)
refresh = { updatetime = 500, timer_interval = 3000 }
```

### Git Workflow

```bash
# Commit team profile to repo
git add .nvim.lua
git commit -m "Add team claude-code configuration"

# Share with team
echo "Install: cp .nvim.lua ~/.config/nvim/init.lua"
```

## Additional Resources

- **Onboarding Guide:** `config/TEAM_ONBOARDING.md`
- **Plugin Documentation:** `README.md`
- **Development Guide:** `CLAUDE.md`
- **Help Command:** `:h claude-code`

## Support

**Validation Help:**
```bash
lua config/validate-config.lua --help
```

**Migration Help:**
```bash
./config/migrate-config.sh --help
```

**Neovim Health Check:**
```vim
:checkhealth claude-code
```

---

**Estimated Setup Time:** <5 minutes per developer
