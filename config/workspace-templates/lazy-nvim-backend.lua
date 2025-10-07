-- Backend Developer Configuration for Lazy.nvim
-- Place in: ~/.config/nvim/lua/plugins/claude-code.lua

return {
  'anthropics/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- Load backend profile
    local config = {
      window = {
        position = 'right',
        split_ratio = 0.35,
        enter_insert = true,
        hide_numbers = true,
        hide_signcolumn = true,
      },
      refresh = {
        enable = true,
        updatetime = 100,
        timer_interval = 800,
        show_notifications = true,
      },
      git = {
        use_git_root = true,
        multi_instance = true,
      },
      command_variants = {
        continue = '--continue',
        resume = '--resume',
        verbose = '--verbose',
        API = '--context api --verbose',
        Database = '--context database --schema',
        Test = '--test --coverage',
        Review = '--review --security',
      },
      keymaps = {
        toggle = {
          normal = '<leader>ai',
          terminal = '<C-,>',
          variants = {
            continue = '<leader>ac',
            API = '<leader>aa',
            Database = '<leader>ad',
            Test = '<leader>at',
            Review = '<leader>ar',
          },
        },
        window_navigation = true,
        scrolling = true,
      },
    }

    require('claude-code').setup(config)
  end,
}
