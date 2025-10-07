---@brief [[
--- DevOps/SRE Profile
--- Optimized for infrastructure, deployment, and monitoring workflows
---
--- Features:
--- - Bottom split (50% height) for terminal-like experience
--- - Command variants for infrastructure and deployment
--- - Extended keymaps for ops workflows
---@brief ]]

return {
  window = {
    position = 'bottom',   -- Horizontal split at bottom
    split_ratio = 0.5,     -- 50% height (half screen)
    enter_insert = true,
    start_in_normal_mode = false,
    hide_numbers = true,
    hide_signcolumn = true,

    float = {
      width = '95%',       -- Wide for logs and YAML
      height = '85%',
      row = 'center',
      col = 'center',
      border = 'single',
      relative = 'editor',
    },
  },

  refresh = {
    enable = true,
    updatetime = 200,        -- Moderate refresh for config files
    timer_interval = 1500,   -- 1.5s checks for manifests/configs
    show_notifications = true,
  },

  git = {
    use_git_root = true,
    multi_instance = true,   -- Separate instances per infrastructure repo
  },

  command_variants = {
    -- Conversation management
    continue = '--continue',
    resume = '--resume',
    verbose = '--verbose',

    -- DevOps-specific workflows
    Infra = '--context infrastructure --terraform',
    K8s = '--context kubernetes --manifest',
    CI = '--context ci-cd --pipeline',
    Deploy = '--deploy --dry-run --verbose',
    Monitor = '--monitoring --alerts',
    Security = '--security --compliance --scan',
    Rollback = '--rollback --safe',
    Debug = '--debug --logs --trace',
  },

  keymaps = {
    toggle = {
      normal = '<leader>op',         -- "OPs"
      terminal = '<C-,>',
      variants = {
        continue = '<leader>oc',      -- "Ops Continue"
        verbose = '<leader>ov',       -- "Ops Verbose"
        Infra = '<leader>oi',         -- "Ops Infrastructure"
        K8s = '<leader>ok',           -- "Ops Kubernetes"
        Deploy = '<leader>od',        -- "Ops Deploy"
        Security = '<leader>os',      -- "Ops Security"
        Debug = '<leader>ox',         -- "Ops Debug"
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
