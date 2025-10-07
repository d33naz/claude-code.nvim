-- DevOps/SRE Configuration for Lazy.nvim
-- Place in: ~/.config/nvim/lua/plugins/claude-code.lua

return {
  'anthropics/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- Load devops profile
    local config = {
      window = {
        position = 'bottom',
        split_ratio = 0.5,
        enter_insert = true,
        hide_numbers = true,
        hide_signcolumn = true,
      },
      refresh = {
        enable = true,
        updatetime = 200,
        timer_interval = 1500,
        show_notifications = true,
      },
      git = {
        use_git_root = true,
        multi_instance = true,
      },
      command_variants = {
        continue = '--continue',
        Infra = '--context infrastructure --terraform',
        K8s = '--context kubernetes --manifest',
        CI = '--context ci-cd --pipeline',
        Deploy = '--deploy --dry-run --verbose',
        Security = '--security --compliance --scan',
        Debug = '--debug --logs --trace',
      },
      keymaps = {
        toggle = {
          normal = '<leader>op',
          terminal = '<C-,>',
          variants = {
            continue = '<leader>oc',
            Infra = '<leader>oi',
            K8s = '<leader>ok',
            Deploy = '<leader>od',
            Security = '<leader>os',
            Debug = '<leader>ox',
          },
        },
        window_navigation = true,
        scrolling = true,
      },
    }

    require('claude-code').setup(config)
  end,
}
