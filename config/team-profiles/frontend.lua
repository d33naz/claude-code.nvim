---@brief [[
--- Frontend Developer Profile
--- Optimized for component development, styling, and UI/UX work
---
--- Features:
--- - Floating window (90% screen) for maximum code visibility
--- - Command variants for component and style workflows
--- - Streamlined keymaps for rapid iteration
---@brief ]]

return {
  window = {
    position = 'float',    -- Floating window for flexible positioning
    split_ratio = 0.3,     -- Fallback if float fails
    enter_insert = true,
    start_in_normal_mode = false,
    hide_numbers = true,
    hide_signcolumn = true,

    float = {
      width = '90%',       -- Maximum code visibility
      height = '90%',
      row = 'center',
      col = 'center',
      border = 'double',   -- Visual distinction from code
      relative = 'editor',
    },
  },

  refresh = {
    enable = true,
    updatetime = 50,         -- Ultra-fast for hot-reload workflows
    timer_interval = 500,    -- Check every 0.5s for CSS/component changes
    show_notifications = false, -- Reduce noise during rapid iteration
  },

  git = {
    use_git_root = true,
    multi_instance = true,   -- Separate instances for monorepo packages
  },

  command_variants = {
    -- Conversation management
    continue = '--continue',
    resume = '--resume',
    verbose = '--verbose',

    -- Frontend-specific workflows
    Component = '--context component --typescript',
    Style = '--context css --design-system',
    Test = '--test --unit',
    Build = '--build --optimize',
    A11y = '--accessibility --wcag',
    Perf = '--performance --lighthouse',
    Refactor = '--refactor --react',
  },

  keymaps = {
    toggle = {
      normal = '<leader>cc',         -- "Claude Code"
      terminal = '<C-,>',
      variants = {
        continue = '<leader>cn',      -- "Claude Next"
        Component = '<leader>cp',     -- "Claude Component"
        Style = '<leader>cs',         -- "Claude Style"
        Test = '<leader>ct',          -- "Claude Test"
        Perf = '<leader>cf',          -- "Claude Fast/Performance"
      },
    },
    window_navigation = true,
    scrolling = true,
  },

  shell = {
    separator = '&&',
    pushd_cmd = 'pushd',
    popd_cmd = 'popd',
  },

  command = 'claude',
}
