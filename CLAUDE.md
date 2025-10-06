# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code Neovim Plugin provides seamless integration between the Claude Code AI assistant and Neovim. It enables direct communication with the Claude Code CLI from within the editor, supporting multi-instance operation, floating windows, file refresh detection, and comprehensive configuration management.

## Essential Development Commands

### Testing
- **Primary Test Command**: `make test` (uses Plenary test framework with custom test runner)
- **Debug Tests**: `make test-debug` (verbose output with environment info)
- **Legacy Tests**: `make test-legacy` (VimL-based tests for backward compatibility)
- **Individual Legacy Tests**: `make test-basic`, `make test-config`
- **Direct Test Runner**: `lua tests/run_tests.lua` from project root (bypasses Make)

### Code Quality & Formatting
- **Lint Code**: `make lint` (luacheck with custom `.luacheckrc` configuration)
- **Format Code**: `make format` (StyLua with 100-char width, 2-space indent)
- **Check Format Only**: `stylua lua/ -c` (validate without changes)
- **Standards**: 100 char line limit, single quotes preferred, Unix line endings

### Development Workflow
- **Complete Workflow**: `make all` (lint → format → test → docs)
- **Documentation**: `make docs` (LDoc generation to doc/luadoc/)
- **Clean Generated Files**: `make clean` (removes doc/luadoc/)
- **Setup Pre-commit Hooks**: `./scripts/setup-hooks.sh`
- **Help**: `make help` (show all available commands)

## Core Architecture

### Module Structure
The plugin follows a modular architecture with clear separation of concerns:

**Core Modules:**
- **`init.lua`**: Main entry point, orchestrates all modules and provides public API
- **`terminal.lua`**: Terminal buffer/window management (split/float), multi-instance support
- **`config.lua`**: Configuration parsing, validation, and defaults with extensive type annotations
- **`commands.lua`**: Vim command registration and variant command generation
- **`keymaps.lua`**: Keymap registration and terminal navigation setup
- **`file_refresh.lua`**: File change detection and auto-reload functionality
- **`git.lua`**: Git integration for repository root detection
- **`version.lua`**: Version management and display

**AI Enhancement Modules:**
- **`ai_integration.lua`**: NexaMind API integration for code analysis and optimization
- **`ai_commands.lua`**: AI-powered development commands and utilities
- **`intelligent_features.lua`**: Smart code assistance and contextual suggestions

### Multi-Instance Architecture
The plugin supports multiple Claude Code instances based on git repository roots:

```lua
-- Instance management in terminal.lua
M.terminal = {
  instances = {},        -- git_root -> buffer_number mapping
  current_instance = nil, -- active git root path
  saved_updatetime = nil  -- for file refresh optimization
}
```

### Configuration System
Extensive configuration validation with type safety:
- **Window Management**: Split ratios, positioning, floating window parameters
- **Multi-Instance Control**: Per-repository vs global instances
- **Shell Integration**: Configurable shell commands for directory changes
- **Keymap Variants**: Support for command variants with corresponding keymaps

### Terminal Management
Smart terminal buffer lifecycle:
- **Buffer Validation**: Checks for valid terminal job IDs and buffer types
- **Window Toggle Logic**: Creates new instances vs showing/hiding existing ones
- **Floating Window Support**: Percentage-based sizing with center positioning
- **Directory Context**: Automatic git root detection and directory changes

## Key Technical Patterns

### Configuration Validation Pattern
All configuration uses strict validation with helpful error messages:
```lua
-- Example from config.lua lines 388-450
local function validate_config(config)
  local valid, err = validate_window_config(config.window)
  if not valid then return false, err end
  -- ... additional validations
end
```

### Instance Management Pattern
Multi-instance support uses git root as the key identifier:
```lua
-- From terminal.lua lines 252-263
local function get_instance_id(config, git)
  if config.git.multi_instance then
    return config.git.use_git_root and get_instance_identifier(git) or vim.fn.getcwd()
  else
    return 'global'  -- Single instance mode
  end
end
```

### Command Variant System
Dynamic command and keymap generation for variants:
```lua
-- From commands.lua - generates ClaudeCodeContinue, ClaudeCodeVerbose, etc.
for variant_name, variant_args in pairs(config.command_variants) do
  if variant_args ~= false then
    -- Register both command and corresponding keymap
  end
end
```

## Testing Architecture

### Test Framework
Uses **custom Plenary-based test runner** (`tests/run_tests.lua`) with 44+ comprehensive tests:

**Test Categories:**
- **Configuration validation** (12 tests): Extensive config parsing and validation
- **Terminal management** (8 tests): Buffer lifecycle, window positioning, multi-instance
- **Command registration** (6 tests): Vim command creation and variant handling
- **Core integration** (5 tests): Plugin setup, initialization, API contracts
- **Git operations**: Repository detection, root finding, multi-instance management
- **File refresh**: Change detection, auto-reload, notification system
- **AI integration**: NexaMind API connectivity, code analysis, optimization features

### Test Structure & Patterns
**Test Organization:**
```
tests/
├── run_tests.lua          # Custom test runner with JSON counting and error handling
├── spec/                  # All test specifications
│   ├── config_validation_spec.lua  # Config parsing edge cases
│   ├── terminal_spec.lua           # Terminal buffer lifecycle
│   ├── ai_integration_spec.lua     # AI API integration tests
│   └── [other modules]_spec.lua    # Module-specific test suites
└── minimal.vim            # Minimal Neovim config for legacy tests
```

**Key Testing Patterns:**
- **Silent mode testing**: `config.parse_config(invalid_config, true)` prevents notification spam
- **Deep copy isolation**: `vim.deepcopy(config.default_config)` for test data isolation
- **Validation failure testing**: Verify fallback to defaults on invalid input
- **BDD structure**: `describe()` and `it()` blocks with descriptive names

## Development Requirements

- **Neovim**: 0.7.0+ (plugin requirement) / 0.10.0+ (development tools)
- **Dependencies**: plenary.nvim for git operations
- **Development Tools**: stylua, luacheck, make
- **Testing**: Custom test framework (tests/run_tests.lua)

## Important Implementation Details

### Buffer Name Generation
Buffers use git root paths for multi-instance identification:
```lua
-- From terminal.lua:171-177
local function generate_buffer_name(instance_id, config)
  if config.git.multi_instance then
    return 'claude-code-' .. instance_id:gsub('[^%w%-_]', '-')
  else
    return 'claude-code'
  end
end
```

### Floating Window Calculations
Sophisticated floating window positioning with percentage support:
```lua
-- terminal.lua:38-66 handles "80%", "center", numeric values
-- with proper clamping and editor dimension calculations
```

### File Refresh Integration
Automatic file change detection when Claude Code modifies files:
- Configurable updatetime and timer intervals
- Optional notifications for file reloads
- Integration with Neovim's autoread functionality

## AI Integration Features

### NexaMind API Integration
**Architecture**: The plugin integrates with a local NexaMind API server (`http://localhost:8004`) for enhanced development capabilities:

**Available AI Engines:**
- **DISE**: Dynamic Intent Scoring Engine for lead scoring analysis
- **CCAS**: Contextual Channel Automation System for multi-channel optimization
- **ANA**: Adaptive Negotiation Algorithm for strategy optimization
- **LGM**: Lead Genome Mapping for behavioral analysis
- **RLGF**: ROI-Locked Guarantee Framework for performance guarantees

**Core AI Functions:**
- **Code Quality Analysis**: `M.analyze_code_quality(code_content, file_type)`
- **Development Suggestions**: `M.get_development_suggestions(context)`
- **Code Optimization**: `M.optimize_code(code_content, optimization_type)`
- **Test Generation**: `M.generate_tests(code_content, test_framework)`
- **API Health Monitoring**: Automatic health checks every 30 seconds

## Development Standards & Quality Assurance

### Code Style Standards
**Enforced via `.luacheckrc` and `stylua.toml`:**
- **Line Length**: 100 characters maximum
- **Indentation**: 2 spaces, no tabs
- **Quotes**: Single quotes preferred (`AutoPreferSingle`)
- **Line Endings**: Unix format
- **Max Cyclomatic Complexity**: 20 (30 for config.lua validation functions)

### Type Safety & Documentation
- **LuaCATS Annotations**: All modules have comprehensive type annotations
- **@mod, @brief, @param, @return**: Consistent documentation patterns
- **Configuration Classes**: Typed config structures (ClaudeCodeConfig, ClaudeCodeWindow, etc.)

### Quality Gates
- **Pre-commit Hooks**: Automatic linting and formatting on commit
- **CI/CD Pipeline**: GitHub Actions with comprehensive testing
- **Dependency Management**: Minimal dependencies (only plenary.nvim)
- **Security**: No telemetry, local execution only
