# claude-code.nvim

> Seamless Claude Code AI assistant integration for Neovim with multi-instance management, team configuration profiles, and AI-powered development features.

[![Tests](https://img.shields.io/badge/tests-114%2F115%20passing-brightgreen)](https://github.com/anthropics/claude-code.nvim)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Neovim](https://img.shields.io/badge/neovim-0.7%2B-green.svg)](https://neovim.io/)

---

## ✨ Features

### 🚀 Core Capabilities

- **In-Editor Terminal** - Claude Code runs directly in Neovim (split or floating window)
- **Multi-Instance Management** - Isolated sessions per git repository (polyrepo support)
- **Smart File Refresh** - Automatic reload detection when Claude modifies files
- **Team Profiles** - Pre-configured setups for backend, frontend, and DevOps workflows
- **Command Variants** - Custom shortcuts for common operations (continue, verbose, etc.)
- **Git Integration** - Automatic repository root detection and directory management

### 🤖 AI-Powered Development (Optional)

- **Code Quality Analysis** - Automated review for complexity, bugs, and best practices
- **Performance Optimization** - AI-suggested improvements for speed and efficiency
- **Test Generation** - Automated test scaffolding for multiple frameworks
- **Security Hardening** - Vulnerability detection and remediation suggestions
- **Code Refactoring** - Readability and maintainability improvements
- **Development Assistance** - Context-aware suggestions and documentation generation

### 🔒 Enterprise-Grade Security

- **Automatic Secret Redaction** - API keys and passwords auto-redacted before transmission
- **Rate Limiting** - Configurable request limits (30/min default, burst control)
- **Code Size Validation** - 100KB limit prevents accidental data exposure
- **Local-First** - All processing on localhost by default
- **Zero Telemetry** - No data collection, fully private

### 👥 Team Collaboration

- **Role-Based Profiles** - Optimized configurations for different developer roles
- **Configuration Validation** - Automatic conflict detection and error prevention
- **Migration Tools** - Automated setup from defaults to team standards
- **Shared Templates** - Workspace-specific configurations per project

---

## 📋 Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Commands](#commands)
- [Usage Examples](#usage-examples)
- [AI Features](#ai-features)
- [Multi-Instance Mode](#multi-instance-mode)
- [Team Profiles](#team-profiles)
- [Documentation](#documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## 📦 Requirements

### Minimal Setup

- **Neovim** 0.7.0+ (0.10.0+ recommended)
- **Claude Code CLI** - [Installation guide](https://claude.ai/code)
- **plenary.nvim** - Git operations dependency

### Optional (AI Features)

- **Docker** 20.10+ - For NexaMind API deployment
- **4GB RAM** - Minimum for AI features (8GB recommended)
- **curl** - API health checks

---

## 🚀 Installation

### Lazy.nvim (Recommended)

```lua
{
  'anthropics/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup({
      -- Optional: Use defaults or customize below
    })
  end,
}
```

### Packer

```lua
use {
  'anthropics/claude-code.nvim',
  requires = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup()
  end
}
```

### vim-plug

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'anthropics/claude-code.nvim'

" In your init.lua or init.vim
lua << EOF
require('claude-code').setup()
EOF
```

### Manual

```bash
git clone https://github.com/anthropics/claude-code.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/claude-code.nvim

git clone https://github.com/nvim-lua/plenary.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/plenary.nvim
```

---

## ⚡ Quick Start

### 1. Basic Usage (Zero Configuration)

```vim
" Toggle Claude Code terminal
:ClaudeCode

" Or use default keymap
<C-,>

" Start with continue flag
:ClaudeCodeContinue

" Use verbose mode
:ClaudeCodeVerbose
```

### 2. First-Time Setup

```lua
-- ~/.config/nvim/lua/plugins/claude-code.lua
require('claude-code').setup({
  window = {
    position = 'right',      -- 'top', 'bottom', 'left', 'right', 'float'
    split_ratio = 0.3,       -- 30% of screen
  },
  git = {
    multi_instance = true,   -- Per-repo isolation
    use_git_root = true,     -- Auto-detect git root
  },
})
```

### 3. Verify Installation

```vim
:checkhealth claude-code
```

Expected output:
```
## claude-code.nvim
  - OK: Plugin loaded
  - OK: Claude Code CLI available
  - OK: plenary.nvim installed
```

---

## ⚙️ Configuration

### Default Configuration

```lua
require('claude-code').setup({
  -- Terminal window settings
  window = {
    position = 'botright',       -- Window position
    split_ratio = 0.3,           -- 30% of screen (0.0-1.0)
    enter_insert = true,         -- Auto-enter insert mode
    start_in_normal_mode = false, -- Start in normal mode
    hide_numbers = true,         -- Hide line numbers
    hide_signcolumn = true,      -- Hide sign column

    -- Floating window configuration
    float = {
      width = '80%',             -- Percentage or number
      height = '80%',
      row = 'center',            -- 'center' or number
      col = 'center',
      border = 'rounded',        -- 'none', 'single', 'double', 'rounded'
      relative = 'editor',       -- 'editor' or 'cursor'
    },
  },

  -- File refresh settings
  refresh = {
    enable = true,               -- Auto-reload changed files
    updatetime = 100,            -- Detection speed (ms)
    timer_interval = 1000,       -- Check interval (ms)
    show_notifications = true,   -- Show reload notifications
  },

  -- Git integration
  git = {
    use_git_root = true,         -- CD to git root
    multi_instance = true,       -- Per-repo instances
  },

  -- Shell configuration (for git root)
  shell = {
    separator = '&&',            -- Command separator
    pushd_cmd = 'pushd',         -- Directory stack push
    popd_cmd = 'popd',           -- Directory stack pop
  },

  -- Command variants (custom shortcuts)
  command_variants = {
    continue = '--continue',     -- Resume conversation
    resume = '--resume',         -- Interactive picker
    verbose = '--verbose',       -- Detailed output
  },

  -- Keymaps
  keymaps = {
    toggle = {
      normal = '<C-,>',          -- Toggle in normal mode
      terminal = '<C-,>',        -- Toggle in terminal mode
      variants = {               -- Variant keymaps
        continue = '<leader>cC',
        verbose = '<leader>cV',
      },
    },
    window_navigation = true,    -- Enable <C-h/j/k/l>
    scrolling = true,            -- Enable <C-f/b>
  },
})
```

### Advanced Configuration

#### Floating Window Mode

```lua
window = {
  position = 'float',
  float = {
    width = '90%',               -- 90% of editor width
    height = '85%',              -- 85% of editor height
    row = 'center',              -- Centered vertically
    col = 'center',              -- Centered horizontally
    border = 'double',           -- Double border
  },
}
```

#### Custom Command Variants

```lua
command_variants = {
  continue = '--continue',
  verbose = '--verbose',

  -- Custom variants for your workflow
  Quick = '--quick',
  Review = '--review',
  Test = '--test --coverage',
  Deploy = '--deploy --dry-run',
}
```

#### Multi-Instance Configuration

```lua
git = {
  multi_instance = true,         -- Enable per-repo instances
  use_git_root = true,           -- Use git root as instance ID
}
```

**Single Instance Mode (Monorepo):**
```lua
git = {
  multi_instance = false,        -- Single global instance
}
```

---

## 🎮 Commands

### Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `:ClaudeCode` | Toggle Claude Code terminal | Opens/closes main terminal |
| `:ClaudeCodeToggle` | Alias for `:ClaudeCode` | Same as above |
| `:ClaudeCodeRestart` | Restart Claude session | Kills and reopens terminal |
| `:ClaudeCodeSuspend` | Suspend current session | Minimizes terminal |
| `:ClaudeCodeResume` | Resume suspended session | Restores terminal |
| `:ClaudeCodeQuit` | Quit Claude session | Closes terminal permanently |
| `:ClaudeCodeRefreshFiles` | Force file refresh check | Manual reload trigger |

### Command Variants

These are generated based on your `command_variants` configuration:

| Command | Args | Description |
|---------|------|-------------|
| `:ClaudeCodeContinue` | `--continue` | Resume most recent conversation |
| `:ClaudeCodeResume` | `--resume` | Interactive conversation picker |
| `:ClaudeCodeVerbose` | `--verbose` | Enable verbose logging |

**Custom variants** create corresponding commands (e.g., `Review = '--review'` creates `:ClaudeCodeReview`)

### Multi-Instance Commands

| Command | Description |
|---------|-------------|
| `:ClaudeCodeInstances` | List all active instances |
| `:ClaudeCodeInstanceSwitch` | Interactive instance switcher |
| `:ClaudeCodeInstanceStats` | Show instance statistics |
| `:ClaudeCodeInstanceCurrent` | Show current active instance |
| `:ClaudeCodeInstanceCleanup` | Clean up orphaned instances |
| `:ClaudeCodeInstanceCreate` | Create instance for current directory |

### AI Commands (Optional)

| Command | Description |
|---------|-------------|
| `:ClaudeCodeAnalyze` | Analyze current buffer for quality issues |
| `:ClaudeCodeOptimize <type>` | Optimize code (performance, security, readability) |
| `:ClaudeCodeGenTests <framework>` | Generate tests (jest, pytest, go-test) |
| `:ClaudeCodeSuggest` | Get AI development suggestions |

---

## 🎯 Usage Examples

### Basic Workflow

```vim
" 1. Open your project
cd ~/projects/my-app

" 2. Start editing
nvim src/components/App.tsx

" 3. Open Claude Code
:ClaudeCode

" 4. Ask Claude to help (in terminal)
"    > Can you review this component for performance issues?

" 5. Claude makes changes, files auto-reload
"    (notification: "File reloaded: App.tsx")

" 6. Continue conversation
:ClaudeCodeContinue

" 7. Close when done
<C-,>
```

### Multi-Repository Workflow

```vim
" Work on frontend repository
:cd ~/projects/frontend-app
:ClaudeCode
" Instance created: "frontend-app"

" Switch to backend repository
:cd ~/projects/backend-api
:ClaudeCode
" Instance created: "backend-api" (separate!)

" List all instances
:ClaudeCodeInstances
" Output:
"   ● [1] frontend-app (valid)
"   ○ [2] backend-api (valid)

" Switch between instances
:ClaudeCodeInstanceSwitch
" Interactive picker appears

" Back to frontend
:cd ~/projects/frontend-app
:ClaudeCode
" Returns to existing "frontend-app" instance
```

### AI-Powered Development

**Code Quality Analysis:**
```vim
" Open problematic code
:e src/utils/validator.js

" Analyze for issues
:ClaudeCodeAnalyze

" AI provides:
" - Complexity score
" - Bug detection
" - Performance issues
" - Best practice violations
```

**Performance Optimization:**
```vim
" Open slow component
:e src/components/DataTable.tsx

" Request optimization
:ClaudeCodeOptimize performance

" AI suggests:
" - useMemo opportunities
" - Virtual scrolling
" - Memoized callbacks
```

**Test Generation:**
```vim
" Open implementation
:e src/api/users.ts

" Generate tests
:ClaudeCodeGenTests jest

" Creates: src/api/users.test.ts
" With comprehensive test suite
```

### Custom Keymaps

```lua
-- Map your own shortcuts
keymaps = {
  toggle = {
    normal = '<leader>ai',       -- <leader>ai to toggle
    variants = {
      continue = '<leader>ac',   -- <leader>ac for continue
      verbose = '<leader>av',    -- <leader>av for verbose
    },
  },
}
```

---

## 🤖 AI Features

### Setup (Optional)

**1. Deploy NexaMind API:**

```bash
# Using Docker Compose (recommended)
docker-compose up -d

# Or Docker directly
docker run -d --name nexamind-api -p 8004:8004 nexamind/api:latest
```

**2. Enable in Configuration:**

```lua
require('claude-code').setup({
  ai_integration = {
    enabled = true,
    api_url = 'http://localhost:8004',

    privacy = {
      send_file_paths = false,   -- Don't send file paths
      redact_secrets = true,     -- Auto-redact API keys/passwords
      max_code_size = 100000,   -- 100KB limit
    },

    rate_limit = {
      max_requests_per_minute = 30,
      burst_size = 10,
    },
  },
})
```

**3. Verify:**

```vim
:checkhealth claude-code
" Should show: AI Integration: Available
```

### AI Workflows

#### Code Quality Analysis

```vim
" Analyze entire buffer
:ClaudeCodeAnalyze

" Or analyze selection (visual mode)
V}:ClaudeCodeAnalyze
```

**Detects:**
- High complexity functions
- Missing error handling
- Security vulnerabilities
- Performance bottlenecks
- Code smells

#### Optimization Types

```vim
:ClaudeCodeOptimize performance  " Speed and efficiency
:ClaudeCodeOptimize security     " Vulnerabilities and hardening
:ClaudeCodeOptimize readability  " Code clarity and maintainability
:ClaudeCodeOptimize typescript   " Type safety improvements
```

#### Test Generation

```vim
:ClaudeCodeGenTests jest      " JavaScript/TypeScript (Jest)
:ClaudeCodeGenTests vitest    " Vite-based projects
:ClaudeCodeGenTests pytest    " Python
:ClaudeCodeGenTests go-test   " Go
```

#### Programmatic API

```lua
local ai = require('claude-code.ai_integration')

-- Code analysis
local result, err = ai.analyze_code_quality(code_content, 'typescript')
if result then
  print(vim.inspect(result))
end

-- Optimization
local optimized, err = ai.optimize_code(code_content, 'performance')

-- Test generation
local tests, err = ai.generate_tests(code_content, 'jest')

-- Development suggestions
local suggestions, err = ai.get_development_suggestions({
  file_type = 'typescript',
  context = 'React component with form validation',
})
```

### Security & Privacy

**Automatic Protections:**
- ✅ API keys automatically redacted (`api_key="xxx"` → `api_key="[REDACTED]"`)
- ✅ Passwords removed (`password="xxx"` → `password="[REDACTED]"`)
- ✅ Tokens sanitized
- ✅ Code size limits enforced
- ✅ Rate limiting prevents abuse
- ✅ Local processing by default

**Manual Review:**
```vim
" Preview what will be sent to AI
:lua << EOF
local ai = require('claude-code.ai_integration')
local code = vim.fn.join(vim.fn.getline(1, '$'), '\n')
local sanitized = ai._sanitize_code(code)
print(sanitized)  -- Review before sending
EOF
```

---

## 🔄 Multi-Instance Mode

### Overview

Multi-instance mode provides **isolated Claude Code sessions per git repository**, preventing context pollution in polyrepo environments.

### How It Works

```
Workspace/
├── frontend-app/    → Instance 1 (isolated)
│   └── .git/
├── backend-api/     → Instance 2 (isolated)
│   └── .git/
└── infra/           → Instance 3 (isolated)
    └── .git/
```

Each repository maintains:
- ✅ Separate terminal buffer
- ✅ Independent conversation history
- ✅ Isolated state and context

### Configuration

**Enable (Default):**
```lua
git = {
  multi_instance = true,
  use_git_root = true,
}
```

**Disable (Single Instance):**
```lua
git = {
  multi_instance = false,  -- One global instance
}
```

### Commands

```vim
" List all instances
:ClaudeCodeInstances
" Output:
"   ● [1] frontend-app (valid)
"   ○ [2] backend-api (valid)
"   ○ [3] infra-terraform (valid)

" Interactive switcher
:ClaudeCodeInstanceSwitch

" Show current instance
:ClaudeCodeInstanceCurrent
" Output: Current instance: frontend-app
"         Path: /home/user/projects/frontend-app

" Statistics
:ClaudeCodeInstanceStats
" Output: Total: 3, Valid: 3, Orphaned: 0

" Clean up orphaned instances
:ClaudeCodeInstanceCleanup
```

### Use Cases

**✅ Ideal For:**
- Polyrepo microservices teams
- Multiple independent projects
- Different language ecosystems per repo
- Client/contractor work with isolation needs

**❌ Not Recommended For:**
- Monorepos (use single instance instead)
- Solo developers with one project
- Learning/experimentation (adds complexity)

---

## 👥 Team Profiles

### Pre-Built Profiles

**Backend Developer:**
```lua
require('claude-code').setup(require('claude-code.config.team-profiles.backend'))
```
- Vertical split (35% width)
- Keymaps: `<leader>ai`, `<leader>aa` (API), `<leader>ad` (Database)
- Variants: API, Database, Test, Review
- Fast refresh for test-driven development

**Frontend Developer:**
```lua
require('claude-code').setup(require('claude-code.config.team-profiles.frontend'))
```
- Floating window (90% screen)
- Keymaps: `<leader>cc`, `<leader>cp` (Component), `<leader>cs` (Style)
- Variants: Component, Style, Test, Perf, A11y
- Ultra-fast refresh for hot reload

**DevOps/SRE:**
```lua
require('claude-code').setup(require('claude-code.config.team-profiles.devops'))
```
- Bottom split (50% height)
- Keymaps: `<leader>op`, `<leader>oi` (Infra), `<leader>ok` (K8s)
- Variants: Infra, K8s, Deploy, Security, Debug
- Optimized for logs and manifests

### Quick Setup

**Automated Migration:**
```bash
# From plugin root
./config/migrate-config.sh backend   # Backend profile
./config/migrate-config.sh frontend  # Frontend profile
./config/migrate-config.sh devops    # DevOps profile
```

**Manual Installation:**
```bash
# Copy template
cp config/workspace-templates/lazy-nvim-backend.lua \
   ~/.config/nvim/lua/plugins/claude-code.lua

# Restart Neovim
nvim
:Lazy reload claude-code.nvim
```

### Validation

```bash
# Validate configuration
lua config/validate-config.lua config/team-profiles/backend.lua

# Expected output:
# ✅ VALIDATION PASSED - 0 errors, 0 warnings
```

### Customization

```lua
-- Load profile and customize
local config = require('claude-code.config.team-profiles.backend')

-- Override specific settings
config.window.split_ratio = 0.4  -- 40% instead of 35%
config.keymaps.toggle.normal = '<leader>cc'  -- Different keymap

-- Add custom variants
config.command_variants.GraphQL = '--context graphql'

require('claude-code').setup(config)
```

---

## 📚 Documentation

### Comprehensive Guides

- **[Team Onboarding Guide](config/TEAM_ONBOARDING.md)** - 5-minute setup for teams
- **[Multi-Instance Guide](config/MULTI_INSTANCE_GUIDE.md)** - Polyrepo workflows
- **[AI Deployment Guide](config/AI_DEPLOYMENT_GUIDE.md)** - NexaMind API setup
- **[AI Workflows Guide](config/AI_WORKFLOWS.md)** - 10 practical workflows
- **[AI Security Guide](config/AI_SECURITY.md)** - Security best practices
- **[Troubleshooting Guide](config/TROUBLESHOOTING.md)** - Common issues & solutions
- **[Configuration Reference](config/README.md)** - Complete config docs

### Demo Scenarios

```bash
# Multi-instance polyrepo demo
./config/demo-scenarios/polyrepo-microservices.sh

# Monorepo with packages demo
./config/demo-scenarios/monorepo-packages.sh

# AI features demo
./config/demo-scenarios/ai-features-demo.sh
```

### Help

```vim
" Built-in help
:help claude-code

" Health check
:checkhealth claude-code

" Version info
:lua print(require('claude-code').version.string())
```

---

## 🐛 Troubleshooting

### Common Issues

**Terminal Not Opening:**
```vim
" Check if Claude CLI is installed
:!which claude

" Check for errors
:messages

" Try manual terminal
:terminal claude
```

**Files Not Auto-Reloading:**
```vim
" Enable autoread
:set autoread

" Check config
:lua print(require('claude-code').config.refresh.enable)

" Manual reload
:checktime
```

**Multi-Instance Not Working:**
```vim
" Verify configuration
:lua print(require('claude-code').config.git.multi_instance)

" Check git root detection
:lua print(require('claude-code.git').get_git_root())

" Clean and recreate
:ClaudeCodeInstanceCleanup
:ClaudeCode
```

**Keymap Conflicts:**
```bash
# Validate config for conflicts
lua config/validate-config.lua ~/.config/nvim/lua/plugins/claude-code.lua

# Or change keymap
# keymaps = { toggle = { normal = '<leader>ai' } }
```

**AI Features Not Working:**
```bash
# Check API health
curl http://localhost:8004/health

# Check Docker
docker ps | grep nexamind

# Restart API
docker restart nexamind-api
```

### Getting Help

1. **Check documentation:** See [Troubleshooting Guide](config/TROUBLESHOOTING.md)
2. **Run health check:** `:checkhealth claude-code`
3. **Check messages:** `:messages`
4. **Report issues:** [GitHub Issues](https://github.com/anthropics/claude-code.nvim/issues)

---

## 🧪 Testing

```bash
# Run test suite
make test

# Run with verbose output
make test-debug

# Lint code
make lint

# Format code
make format

# Complete workflow (lint + format + test + docs)
make all
```

**Test Coverage:** 114/115 tests passing (99.1%)

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Clone repository
git clone https://github.com/anthropics/claude-code.nvim.git
cd claude-code.nvim

# Install pre-commit hooks
./scripts/setup-hooks.sh

# Run tests
make test

# Format code
make format

# Generate docs
make docs
```

### Code Style

- **Line length:** 100 characters max
- **Indentation:** 2 spaces
- **Quotes:** Single quotes preferred
- **Documentation:** LuaCATS annotations required

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

---

## 🙏 Acknowledgments

- **Claude Code CLI** - Anthropic's AI assistant
- **plenary.nvim** - Lua functions library
- **Neovim Community** - Amazing ecosystem

---

## 📊 Project Stats

- **Lines of Code:** 7100+
- **Test Coverage:** 99.1%
- **Documentation:** 8 comprehensive guides
- **Team Profiles:** 3 role-based configurations
- **Demo Scenarios:** 3 interactive demos
- **Commands:** 30+ built-in commands

---

## 🚀 Quick Links

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Team Profiles](#team-profiles)
- [AI Features](#ai-features)
- [Multi-Instance Mode](#multi-instance-mode)
- [Documentation](#documentation)
- [Troubleshooting](#troubleshooting)

---

<div align="center">

**Made with ❤️ for the Neovim community**

[Report Bug](https://github.com/anthropics/claude-code.nvim/issues) · [Request Feature](https://github.com/anthropics/claude-code.nvim/issues) · [Documentation](config/README.md)

</div>
