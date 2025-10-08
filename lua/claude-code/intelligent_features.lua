---@mod claude-code.intelligent_features Intelligent Plugin Capabilities
---@brief [[
--- This module provides intelligent capabilities that leverage the 14 specialized
--- AI agents from the NexaMind system for advanced development assistance.
---@brief ]]

local ai_integration = require('claude-code.ai_integration')
local M = {}

--- @type table Configuration for intelligent features
M.config = {
  auto_analyze_on_save = false,
  auto_suggest_improvements = true,
  performance_monitoring = true,
  intelligent_completion = true,
  code_quality_gates = true,
}

--- @type table Agent-specific capabilities mapping
M.agent_capabilities = {
  orchestrator = {
    name = 'nexamind-orchestrator-enhanced',
    capabilities = { 'workflow_optimization', 'task_coordination', 'system_monitoring' },
  },
  demo_executor = {
    name = 'demo-executor-enhanced',
    capabilities = { 'environment_provisioning', 'test_automation', 'deployment_optimization' },
  },
  validator = {
    name = 'output-validator-enhanced',
    capabilities = { 'quality_assurance', 'compliance_checking', 'performance_validation' },
  },
  architect = {
    name = 'automation-architect-enhanced',
    capabilities = { 'workflow_design', 'process_optimization', 'architecture_guidance' },
  },
  security = {
    name = 'patent-security-guardian-enhanced',
    capabilities = { 'security_analysis', 'vulnerability_detection', 'compliance_validation' },
  },
  legal = {
    name = 'legal-intelligence-enhanced',
    capabilities = { 'license_compliance', 'legal_risk_assessment', 'regulatory_guidance' },
  },
  innovation = {
    name = 'innovation-scout-enhanced',
    capabilities = { 'trend_analysis', 'technology_research', 'innovation_opportunities' },
  },
  crisis = {
    name = 'crisis-commander-enhanced',
    capabilities = { 'incident_response', 'error_recovery', 'system_healing' },
  },
  customer = {
    name = 'customer-experience-optimizer-enhanced',
    capabilities = { 'user_experience', 'interface_optimization', 'usability_analysis' },
  },
  dise = {
    name = 'dise-technical-optimizer-enhanced',
    capabilities = { 'performance_optimization', 'algorithm_enhancement', 'efficiency_analysis' },
  },
  neural = {
    name = 'neural-evolution-enhanced',
    capabilities = { 'ai_enhancement', 'learning_optimization', 'model_evolution' },
  },
  growth = {
    name = 'growth-hacker-enhanced',
    capabilities = { 'metric_optimization', 'performance_tracking', 'growth_strategies' },
  },
  data = {
    name = 'data-intelligence-enhanced',
    capabilities = { 'data_analysis', 'pattern_recognition', 'insight_generation' },
  },
  integration = {
    name = 'integration-specialist-enhanced',
    capabilities = { 'api_integration', 'system_connectivity', 'data_synchronization' },
  },
}

--- Initialize intelligent features
--- @param user_config table? User configuration overrides
function M.setup(user_config)
  -- Merge user config with defaults
  if user_config then
    M.config = vim.tbl_deep_extend('force', M.config, user_config)
  end

  -- Setup intelligent features based on configuration
  if M.config.auto_analyze_on_save then
    M.setup_auto_analysis()
  end

  if M.config.intelligent_completion then
    M.setup_intelligent_completion()
  end

  if M.config.performance_monitoring then
    M.setup_performance_monitoring()
  end

  if M.config.code_quality_gates then
    M.setup_quality_gates()
  end
end

--- Setup automatic code analysis on save
function M.setup_auto_analysis()
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = { '*.lua', '*.js', '*.ts', '*.py', '*.go', '*.rs', '*.java', '*.cpp', '*.c' },
    callback = function(args)
      -- Debounce to avoid excessive API calls
      vim.defer_fn(function()
        M.intelligent_code_analysis(args.buf)
      end, 1000)
    end,
    desc = 'Intelligent code analysis on save',
  })
end

--- Setup intelligent completion
function M.setup_intelligent_completion()
  -- Custom completion source that uses AI suggestions
  local completion_source = {
    name = 'claude_code_ai',
    keyword_pattern = [[\k\+]],
    trigger_characters = { '.', ':', '(', ' ' },
  }

  function completion_source:complete(params, callback)
    local line = params.context.cursor_line
    local col = params.context.cursor.col

    -- Get context for AI completion
    local context = {
      line = line,
      column = col,
      file_type = vim.bo.filetype,
      current_function = M.get_current_function_context(),
    }

    M.get_ai_completion_suggestions(context, function(suggestions)
      if suggestions then
        callback(suggestions)
      else
        callback({})
      end
    end)
  end

  -- Register completion source if nvim-cmp is available
  local has_cmp, cmp = pcall(require, 'cmp')
  if has_cmp then
    cmp.register_source('claude_code_ai', completion_source)
  end
end

--- Setup performance monitoring
function M.setup_performance_monitoring()
  local performance_timer = vim.loop.new_timer()

  performance_timer:start(30000, 30000, function() -- Every 30 seconds
    vim.schedule(function()
      M.monitor_plugin_performance()
    end)
  end)
end

--- Setup code quality gates
function M.setup_quality_gates()
  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function(args)
      if M.config.code_quality_gates then
        M.run_quality_gate_checks(args.buf)
      end
    end,
    desc = 'Code quality gate checks',
  })
end

--- Intelligent code analysis using specialized agents
--- @param bufnr number Buffer number
function M.intelligent_code_analysis(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')
  local file_type = vim.bo[bufnr].filetype
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if content == '' then
    return
  end

  -- Use multiple agents for comprehensive analysis
  local analysis_tasks = {
    { agent = 'validator', task = 'quality_analysis' },
    { agent = 'security', task = 'security_scan' },
    { agent = 'dise', task = 'performance_analysis' },
    { agent = 'architect', task = 'architecture_review' },
  }

  local results = {}
  local completed = 0

  for _, task in ipairs(analysis_tasks) do
    M.call_specialized_agent(task.agent, task.task, {
      content = content,
      file_type = file_type,
      filename = filename,
    }, function(result, error)
      completed = completed + 1
      if result then
        results[task.task] = result
      end

      -- When all tasks complete, show consolidated results
      if completed == #analysis_tasks then
        M.show_intelligent_analysis_results(results, filename)
      end
    end)
  end
end

--- Call specialized agent for specific task
--- @param agent_type string Type of agent to call
--- @param task_type string Type of task to perform
--- @param data table Task data
--- @param callback function Callback function
function M.call_specialized_agent(agent_type, task_type, data, callback)
  local agent = M.agent_capabilities[agent_type]
  if not agent then
    callback(nil, 'Unknown agent type: ' .. agent_type)
    return
  end

  -- Create specialized prompt based on agent and task
  local prompt = M.create_agent_prompt(agent_type, task_type, data)

  local request_data = {
    messages = {
      {
        role = 'system',
        content = string.format(
          'You are the %s agent. Focus on %s. Provide specific, actionable insights.',
          agent.name,
          table.concat(agent.capabilities, ', ')
        ),
      },
      {
        role = 'user',
        content = prompt,
      },
    },
  }

  ai_integration.api_request_async('/ai/chat', request_data, function(result, error)
    callback(result, error)
  end)
end

--- Create specialized prompt for agent
--- @param agent_type string Agent type
--- @param task_type string Task type
--- @param data table Task data
--- @return string prompt
function M.create_agent_prompt(agent_type, task_type, data)
  local base_prompt = string.format(
    'Analyze this %s code from %s:\n\n```%s\n%s\n```\n\n',
    data.file_type,
    data.filename,
    data.file_type,
    data.content
  )

  local specialized_prompts = {
    validator = {
      quality_analysis = base_prompt
        .. 'Focus on: code quality, best practices, maintainability, and potential improvements.',
      compliance_checking = base_prompt
        .. 'Focus on: coding standards compliance, documentation requirements, and style guidelines.',
    },
    security = {
      security_scan = base_prompt
        .. 'Focus on: security vulnerabilities, potential exploits, data exposure risks, and security best practices.',
      vulnerability_detection = base_prompt
        .. 'Focus on: detailed vulnerability analysis with CVE mappings where applicable.',
    },
    dise = {
      performance_analysis = base_prompt
        .. 'Focus on: performance bottlenecks, optimization opportunities, algorithmic efficiency, and resource usage.',
      efficiency_analysis = base_prompt
        .. 'Focus on: computational complexity, memory usage, and execution time optimization.',
    },
    architect = {
      architecture_review = base_prompt
        .. 'Focus on: architectural patterns, design principles, modularity, and structural improvements.',
      workflow_design = base_prompt
        .. 'Focus on: development workflow optimization and process improvements.',
    },
  }

  return specialized_prompts[agent_type] and specialized_prompts[agent_type][task_type]
    or base_prompt
end

--- Show intelligent analysis results
--- @param results table Analysis results from multiple agents
--- @param filename string Source filename
function M.show_intelligent_analysis_results(results, filename)
  local analysis_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(analysis_buf, 'filetype', 'markdown')
  vim.api.nvim_buf_set_name(analysis_buf, 'Intelligent Code Analysis')

  local report_lines = {
    '# 🤖 Intelligent Code Analysis Report',
    '',
    '**File:** ' .. filename,
    '**Generated:** ' .. os.date('%Y-%m-%d %H:%M:%S'),
    '**Powered by:** 14 NexaMind AI Agents',
    '',
    '---',
    '',
  }

  -- Add results from each agent
  local agent_sections = {
    quality_analysis = '## 🔍 Quality Analysis (Validator Agent)',
    security_scan = '## 🛡️ Security Analysis (Security Guardian Agent)',
    performance_analysis = '## ⚡ Performance Analysis (DISE Optimizer Agent)',
    architecture_review = '## 🏗️ Architecture Review (Automation Architect Agent)',
  }

  for task, result in pairs(results) do
    if result and result.text then
      table.insert(report_lines, agent_sections[task] or ('## ' .. task))
      table.insert(report_lines, '')

      local result_lines = vim.split(result.text, '\n')
      vim.list_extend(report_lines, result_lines)
      table.insert(report_lines, '')
      table.insert(report_lines, '---')
      table.insert(report_lines, '')
    end
  end

  vim.api.nvim_buf_set_lines(analysis_buf, 0, -1, false, report_lines)

  -- Open in a new tab
  vim.cmd('tabnew')
  vim.api.nvim_win_set_buf(0, analysis_buf)

  vim.notify('🤖 Intelligent analysis complete - 4 agents consulted', vim.log.levels.INFO)
end

--- Get AI completion suggestions
--- @param context table Completion context
--- @param callback function Callback function
function M.get_ai_completion_suggestions(context, callback)
  local request_data = {
    messages = {
      {
        role = 'system',
        content = 'You are an intelligent code completion assistant. Provide relevant code completions based on context. Return only the completion text, no explanations.',
      },
      {
        role = 'user',
        content = string.format(
          "Context: %s language, line: '%s', position: %d. Suggest completion.",
          context.file_type,
          context.line,
          context.column
        ),
      },
    },
  }

  ai_integration.api_request_async('/ai/chat', request_data, function(result, error)
    if result and result.text then
      local suggestions = vim.split(result.text, '\n')
      local completion_items = {}

      for _, suggestion in ipairs(suggestions) do
        if suggestion ~= '' then
          table.insert(completion_items, {
            label = suggestion,
            kind = 1, -- Text completion
            detail = 'AI Suggestion',
            documentation = 'Generated by NexaMind AI',
          })
        end
      end

      callback(completion_items)
    else
      callback(nil)
    end
  end)
end

--- Get current function context
--- @return string? function_context
function M.get_current_function_context()
  -- Simple function detection - can be enhanced with treesitter
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lines = vim.api.nvim_buf_get_lines(0, math.max(0, cursor[1] - 10), cursor[1] + 5, false)

  for _, line in ipairs(lines) do
    if line:match('function') or line:match('def ') or line:match('fn ') then
      return line:gsub('^%s+', '') -- Remove leading whitespace
    end
  end

  return nil
end

--- Monitor plugin performance
function M.monitor_plugin_performance()
  -- Basic performance monitoring
  local stats = {
    memory_usage = collectgarbage('count'),
    api_calls_made = ai_integration.stats and ai_integration.stats.total_calls or 0,
    last_check = os.time(),
  }

  -- Store stats for trending
  if not M._performance_history then
    M._performance_history = {}
  end

  table.insert(M._performance_history, stats)

  -- Keep only last 100 entries
  if #M._performance_history > 100 then
    table.remove(M._performance_history, 1)
  end

  -- Alert if memory usage is high
  if stats.memory_usage > 50000 then -- 50MB
    vim.notify('Claude Code AI: High memory usage detected', vim.log.levels.WARN)
  end
end

--- Run quality gate checks
--- @param bufnr number Buffer number
function M.run_quality_gate_checks(bufnr)
  local file_type = vim.bo[bufnr].filetype
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')

  -- Quick quality checks
  local issues = {}

  -- Check for common issues
  if content:find('TODO') or content:find('FIXME') or content:find('XXX') then
    table.insert(issues, 'Code contains TODO/FIXME comments')
  end

  if content:find('console%.log') or content:find('print%(') then
    table.insert(issues, 'Debug statements detected')
  end

  if #lines > 1000 then
    table.insert(issues, 'File is very large (>1000 lines)')
  end

  -- Show issues if any
  if #issues > 0 then
    local message = 'Quality gate warnings:\n' .. table.concat(issues, '\n')
    vim.notify(message, vim.log.levels.WARN)
  end
end

--- Get intelligent insights for current project
function M.get_project_insights()
  local cwd = vim.fn.getcwd()
  local file_count = #vim.fn.globpath(cwd, '**/*', false, true)

  local context = {
    project_path = cwd,
    file_count = file_count,
    languages = M.detect_project_languages(),
    git_info = M.get_git_info(),
  }

  local request_data = {
    messages = {
      {
        role = 'system',
        content = 'You are a project intelligence agent. Analyze the project context and provide strategic insights about architecture, technology stack, and optimization opportunities.',
      },
      {
        role = 'user',
        content = string.format('Analyze this project: %s', vim.json.encode(context)),
      },
    },
  }

  ai_integration.api_request_async('/ai/chat', request_data, function(result, error)
    if result and result.text then
      local insights_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(insights_buf, 'filetype', 'markdown')
      vim.api.nvim_buf_set_name(insights_buf, 'Project Intelligence Insights')

      local insight_lines = {
        '# 🧠 Project Intelligence Report',
        '',
        '**Project:** ' .. cwd,
        '**Analysis Date:** ' .. os.date('%Y-%m-%d %H:%M:%S'),
        '',
        '## Context',
        '- **Files:** ' .. file_count,
        '- **Languages:** ' .. table.concat(context.languages, ', '),
        '',
        '## AI Insights',
        '',
      }

      local ai_lines = vim.split(result.text, '\n')
      vim.list_extend(insight_lines, ai_lines)

      vim.api.nvim_buf_set_lines(insights_buf, 0, -1, false, insight_lines)

      vim.cmd('tabnew')
      vim.api.nvim_win_set_buf(0, insights_buf)
      vim.notify('🧠 Project intelligence analysis complete', vim.log.levels.INFO)
    end
  end)
end

--- Detect project languages (optimized with depth limit)
--- @return table languages
function M.detect_project_languages()
  local extensions = {}
  -- Limit depth to avoid performance issues in large repos
  local files = vim.fn.globpath(vim.fn.getcwd(), '*', false, true)
  vim.list_extend(files, vim.fn.globpath(vim.fn.getcwd(), '*/*', false, true))
  vim.list_extend(files, vim.fn.globpath(vim.fn.getcwd(), '*/*/*', false, true))

  for _, file in ipairs(files) do
    local ext = file:match('%.([^%.]+)$')
    if ext then
      extensions[ext] = true
    end
  end

  local lang_map = {
    lua = 'Lua',
    js = 'JavaScript',
    ts = 'TypeScript',
    py = 'Python',
    go = 'Go',
    rs = 'Rust',
    java = 'Java',
    cpp = 'C++',
    c = 'C',
    rb = 'Ruby',
    php = 'PHP',
    cs = 'C#',
    kt = 'Kotlin',
    swift = 'Swift',
  }

  local languages = {}
  for ext, _ in pairs(extensions) do
    if lang_map[ext] then
      table.insert(languages, lang_map[ext])
    end
  end

  return languages
end

--- Get git information (secure with vim.system)
--- @return table git_info
function M.get_git_info()
  local git_info = {}

  -- Use vim.system if available (Neovim 0.10+), otherwise fallback
  if vim.system then
    -- Get current branch
    local branch_obj = vim.system({ 'git', 'branch', '--show-current' }, { text = true }):wait()
    if branch_obj.code == 0 and branch_obj.stdout then
      git_info.branch = branch_obj.stdout:gsub('[\n\r%s]*$', '') or 'unknown'
    else
      git_info.branch = 'unknown'
    end

    -- Get commit count
    local commit_obj = vim.system({ 'git', 'rev-list', '--count', 'HEAD' }, { text = true }):wait()
    if commit_obj.code == 0 and commit_obj.stdout then
      git_info.commits = commit_obj.stdout:gsub('[\n\r%s]*$', '') or '0'
    else
      git_info.commits = '0'
    end
  else
    -- Fallback for older Neovim versions
    local branch_handle = io.popen('git branch --show-current 2>/dev/null')
    if branch_handle then
      git_info.branch = branch_handle:read('*l') or 'unknown'
      branch_handle:close()
    end

    local commit_handle = io.popen('git rev-list --count HEAD 2>/dev/null')
    if commit_handle then
      git_info.commits = commit_handle:read('*l') or '0'
      commit_handle:close()
    end
  end

  return git_info
end

return M
