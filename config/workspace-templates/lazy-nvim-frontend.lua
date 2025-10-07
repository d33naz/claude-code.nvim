-- Frontend Developer Configuration for Lazy.nvim
-- Place in: ~/.config/nvim/lua/plugins/claude-code.lua

return {
  'anthropics/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- Load frontend profile
    local config = {
      window = {
        position = 'float',
        float = {
          width = '90%',
          height = '90%',
          row = 'center',
          col = 'center',
          border = 'double',
          relative = 'editor',
        },
      },
      refresh = {
        enable = true,
        updatetime = 50,
        timer_interval = 500,
        show_notifications = false,
      },
      git = {
        use_git_root = true,
        multi_instance = true,
      },
      command_variants = {
        continue = '--continue',
        Component = '--context component --typescript',
        Style = '--context css --design-system',
        Test = '--test --unit',
        Build = '--build --optimize',
        Perf = '--performance --lighthouse',
      },
      keymaps = {
        toggle = {
          normal = '<leader>cc',
          terminal = '<C-,>',
          variants = {
            continue = '<leader>cn',
            Component = '<leader>cp',
            Style = '<leader>cs',
            Test = '<leader>ct',
            Perf = '<leader>cf',
          },
        },
        window_navigation = true,
        scrolling = true,
      },
    }

    require('claude-code').setup(config)
  end,
}
