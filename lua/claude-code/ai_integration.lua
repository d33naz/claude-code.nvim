---@mod claude-code.ai_integration AI Integration for Claude Code
---@brief [[
--- This module provides AI-powered development assistance by integrating
--- with the NexaMind agent system for intelligent code analysis, optimization,
--- and automated development workflows.
---@brief ]]

local M = {}

--- @type string Base URL for NexaMind API
M.base_url = 'http://localhost:8004'

--- @type table Configuration for AI integration
M.config = {
  auto_health_check = true,
  health_check_interval = 30000, -- 30 seconds
  max_retries = 3,
  timeout = 5000, -- 5 seconds
}

--- @type table Available AI engines and their capabilities
M.engines = {
  dise = {
    name = 'Dynamic Intent Scoring Engine',
    endpoint = '/api/v1/scoring/score',
    description = 'Lead scoring and intent analysis',
  },
  ccas = {
    name = 'Contextual Channel Automation System',
    endpoint = '/api/v1/enhanced/ccas/optimize',
    description = 'Multi-channel optimization',
  },
  ana = {
    name = 'Adaptive Negotiation Algorithm',
    endpoint = '/api/v1/enhanced/ana/negotiate',
    description = 'Strategy optimization',
  },
  lgm = {
    name = 'Lead Genome Mapping',
    endpoint = '/api/v1/enhanced/lgm/analyze',
    description = 'Behavioral analysis',
  },
  rlgf = {
    name = 'ROI-Locked Guarantee Framework',
    endpoint = '/api/v1/enhanced/rlgf/guarantee',
    description = 'Performance guarantees',
  },
}

--- Check if NexaMind API is available
--- @return boolean available
--- @return string? error_message
function M.check_health()
  local curl_cmd = string.format('curl -s -m 2 %s/health', M.base_url)
  local handle = io.popen(curl_cmd)

  if not handle then
    return false, 'Failed to execute health check'
  end

  local result = handle:read('*a')
  local success = handle:close()

  if not success then
    return false, 'Health check command failed'
  end

  -- Check if we got a valid JSON response
  if result and result:match('"status":%s*"healthy"') then
    return true, nil
  end

  return false, 'API not healthy or unreachable'
end

--- Send request to NexaMind API
--- @param endpoint string API endpoint
--- @param data table Request data
--- @return table? response
--- @return string? error
function M.api_request(endpoint, data)
  local json_data = vim.json.encode(data or {})
  local curl_cmd = string.format(
    'curl -s -X POST -H "Content-Type: application/json" -d \'%s\' %s%s',
    json_data,
    M.base_url,
    endpoint
  )

  local handle = io.popen(curl_cmd)
  if not handle then
    return nil, 'Failed to execute API request'
  end

  local result = handle:read('*a')
  local success = handle:close()

  if not success then
    return nil, 'API request failed'
  end

  -- Try to parse JSON response
  local ok, parsed = pcall(vim.json.decode, result)
  if ok then
    return parsed, nil
  else
    return nil, 'Invalid JSON response: ' .. tostring(parsed)
  end
end

--- Analyze code quality using AI
--- @param code_content string Code to analyze
--- @param file_type string Programming language
--- @return table? analysis
--- @return string? error
function M.analyze_code_quality(code_content, file_type)
  local available, err = M.check_health()
  if not available then
    return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
  end

  -- Use the chat endpoint for code analysis
  local request_data = {
    messages = {
      {
        role = 'system',
        content = 'You are an expert code reviewer. Analyze the provided code for quality, potential issues, and optimization opportunities. Provide specific, actionable feedback.',
      },
      {
        role = 'user',
        content = string.format(
          'Please analyze this %s code:\n\n```%s\n%s\n```',
          file_type,
          file_type,
          code_content
        ),
      },
    },
  }

  return M.api_request('/ai/chat', request_data)
end

--- Get AI-powered development suggestions
--- @param context table Development context (file type, project info, etc.)
--- @return table? suggestions
--- @return string? error
function M.get_development_suggestions(context)
  local available, err = M.check_health()
  if not available then
    return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
  end

  local request_data = {
    messages = {
      {
        role = 'system',
        content = 'You are an AI development assistant. Provide helpful suggestions for improving development workflow, code organization, and best practices.',
      },
      {
        role = 'user',
        content = string.format(
          "I'm working on a %s project. Current context: %s. What development improvements do you suggest?",
          context.file_type or 'unknown',
          vim.json.encode(context)
        ),
      },
    },
  }

  return M.api_request('/ai/chat', request_data)
end

--- Optimize code using AI engines
--- @param code_content string Code to optimize
--- @param optimization_type string Type of optimization (performance, readability, etc.)
--- @return table? optimized_code
--- @return string? error
function M.optimize_code(code_content, optimization_type)
  local available, err = M.check_health()
  if not available then
    return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
  end

  local request_data = {
    messages = {
      {
        role = 'system',
        content = string.format(
          'You are an expert code optimizer. Focus on %s optimization. Provide improved code with explanations.',
          optimization_type
        ),
      },
      {
        role = 'user',
        content = string.format(
          'Please optimize this code for %s:\n\n%s',
          optimization_type,
          code_content
        ),
      },
    },
  }

  return M.api_request('/ai/chat', request_data)
end

--- Generate tests using AI
--- @param code_content string Code to generate tests for
--- @param test_framework string Testing framework to use
--- @return table? test_code
--- @return string? error
function M.generate_tests(code_content, test_framework)
  local available, err = M.check_health()
  if not available then
    return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
  end

  local request_data = {
    messages = {
      {
        role = 'system',
        content = string.format(
          'You are an expert test writer. Generate comprehensive tests using %s framework. Include edge cases and error handling.',
          test_framework
        ),
      },
      {
        role = 'user',
        content = string.format('Generate tests for this code:\n\n%s', code_content),
      },
    },
  }

  return M.api_request('/ai/chat', request_data)
end

--- Get API metrics and status
--- @return table? metrics
--- @return string? error
function M.get_api_metrics()
  local available, err = M.check_health()
  if not available then
    return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
  end

  -- Get latest metrics
  return M.api_request('/api/v1/metrics/metrics/latest', {})
end

--- Initialize AI integration
--- @param user_config table? User configuration overrides
function M.setup(user_config)
  -- Merge user config with defaults
  if user_config then
    M.config = vim.tbl_deep_extend('force', M.config, user_config)
  end

  -- Initial health check
  vim.schedule(function()
    local available, err = M.check_health()
    if available then
      vim.notify('NexaMind AI integration: Ready', vim.log.levels.INFO)
    else
      vim.notify(
        string.format('NexaMind AI integration: Unavailable (%s)', err or 'unknown error'),
        vim.log.levels.WARN
      )
    end
  end)

  -- Setup periodic health checks if enabled
  if M.config.auto_health_check then
    local timer = vim.loop.new_timer()
    timer:start(M.config.health_check_interval, M.config.health_check_interval, function()
      vim.schedule(function()
        local available = M.check_health()
        if not available then
          vim.notify('NexaMind AI integration: Connection lost', vim.log.levels.WARN)
        end
      end)
    end)
  end
end

return M
