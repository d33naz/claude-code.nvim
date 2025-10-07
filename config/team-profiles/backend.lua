---@brief [[
--- Backend Developer Profile
--- Optimized for API development, database work, and microservices
---
--- Features:
--- - Vertical split (35% width) for ultrawide monitors
--- - Command variants for API and database context
--- - Extended keymaps for backend workflows
---@brief ]]

return {
  window = {
    position = 'right',    -- Vertical split on right side
    split_ratio = 0.35,    -- 35% width for code + AI side-by-side
    enter_insert = true,
    start_in_normal_mode = false,
    hide_numbers = true,
    hide_signcolumn = true,

    -- Floating window fallback (for single-monitor setups)
    float = {
      width = '85%',
      height = '90%',
      row = 'center',
      col = 'center',
      border = 'rounded',
      relative = 'editor',
    },
  },

  refresh = {
    enable = true,
    updatetime = 100,        -- Fast refresh for test-driven development
    timer_interval = 800,    -- Check more frequently (0.8s)
    show_notifications = true,
  },

  git = {
    use_git_root = true,
    multi_instance = true,   -- Essential for microservices polyrepo
  },

  command_variants = {
    -- Conversation management
    continue = '--continue',
    resume = '--resume',
    verbose = '--verbose',

    -- Backend-specific workflows
    API = '--context api --verbose',
    Database = '--context database --schema',
    Test = '--test --coverage',
    Deploy = '--deploy --check',
    Migrate = '--database --migration',
    Review = '--review --security',
  },

  keymaps = {
    toggle = {
      normal = '<leader>ai',         -- Mnemonic: "AI"
      terminal = '<C-,>',             -- Quick toggle in terminal
      variants = {
        continue = '<leader>ac',      -- "AI Continue"
        verbose = '<leader>av',       -- "AI Verbose"
        API = '<leader>aa',           -- "AI API"
        Database = '<leader>ad',      -- "AI Database"
        Test = '<leader>at',          -- "AI Test"
        Review = '<leader>ar',        -- "AI Review"
      },
    },
    window_navigation = true,  -- <C-h/j/k/l> for split navigation
    scrolling = true,          -- <C-f/b> for terminal scrolling
  },

  shell = {
    separator = '&&',
    pushd_cmd = 'pushd',
    popd_cmd = 'popd',
  },

  command = 'claude',
}
