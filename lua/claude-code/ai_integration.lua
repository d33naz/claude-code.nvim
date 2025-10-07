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
  enabled = true,
  auto_health_check = true,
  health_check_interval = 30000, -- 30 seconds
  max_retries = 3,
  timeout = 5000, -- 5 seconds
  request_timeout = 30000, -- 30 seconds for AI requests
  rate_limit = {
    max_requests_per_minute = 30,
    burst_size = 10,
  },
  privacy = {
    send_file_paths = false,
    redact_secrets = true,
    max_code_size = 100000, -- 100KB limit
  },
}

--- @type table Rate limiting state
M._rate_limit_state = {
  requests = {},
  last_cleanup = os.time(),
}

--- @type boolean Health check status cache
M._health_status = nil

--- @type number Last health check time
M._last_health_check = 0

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

--- Check rate limit compliance
--- @return boolean allowed
--- @return string? reason
local function check_rate_limit()
  local now = os.time()
  local state = M._rate_limit_state

  -- Cleanup old requests (older than 1 minute)
  if now - state.last_cleanup > 60 then
    local cutoff = now - 60
    local new_requests = {}
    for _, timestamp in ipairs(state.requests) do
      if timestamp > cutoff then
        table.insert(new_requests, timestamp)
      end
    end
    state.requests = new_requests
    state.last_cleanup = now
  end

  -- Check if within rate limit
  local count = #state.requests
  if count >= M.config.rate_limit.max_requests_per_minute then
    return false, 'Rate limit exceeded'
  end

  -- Add current request
  table.insert(state.requests, now)
  return true, nil
end

--- Redact sensitive information from code
--- @param code string Code content
--- @return string redacted_code
local function redact_secrets(code)
  if not M.config.privacy.redact_secrets then
    return code
  end

  -- Patterns for common secrets
  local patterns = {
    { pattern = '(["\'])([A-Za-z0-9+/=]{32,})%1', replacement = '%1[REDACTED_SECRET]%1' },
    { pattern = 'password%s*=%s*["\']([^"\']+)["\']', replacement = 'password="[REDACTED]"' },
    { pattern = 'api[_-]?key%s*=%s*["\']([^"\']+)["\']', replacement = 'api_key="[REDACTED]"' },
    { pattern = 'token%s*=%s*["\']([^"\']+)["\']', replacement = 'token="[REDACTED]"' },
    { pattern = 'secret%s*=%s*["\']([^"\']+)["\']', replacement = 'secret="[REDACTED]"' },
  }

  local redacted = code
  for _, rule in ipairs(patterns) do
    redacted = redacted:gsub(rule.pattern, rule.replacement)
  end

  return redacted
end

--- Validate and sanitize code before sending
--- @param code string Code content
--- @return string? sanitized_code
--- @return string? error
local function sanitize_code(code)
  if not code or code == '' then
    return nil, 'Empty code content'
  end

  -- Check size limit
  if #code > M.config.privacy.max_code_size then
    return nil, string.format(
      'Code size exceeds limit: %d bytes (max: %d)',
      #code,
      M.config.privacy.max_code_size
    )
  end

  -- Redact secrets
  return redact_secrets(code), nil
end

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
  -- Try to encode data with error handling
  local ok, json_data = pcall(vim.json.encode, data or {})
  if not ok then
    return nil, 'Failed to encode request data: ' .. tostring(json_data)
  end

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
  local parse_ok, parsed = pcall(vim.json.decode, result)
  if parse_ok then
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
  if not M.config.enabled then
    return nil, 'AI integration is disabled'
  end

  local available, err = M.check_health()
  if not available then
    return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
  end

  -- Check rate limit
  local allowed, rate_err = check_rate_limit()
  if not allowed then
    return nil, rate_err
  end

  -- Sanitize code
  local sanitized, sanitize_err = sanitize_code(code_content)
  if not sanitized then
    return nil, sanitize_err
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
          sanitized
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
  if not M.config.enabled then
    return nil, 'AI integration is disabled'
  end

  local available, err = M.check_health()
  if not available then
    return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
  end

  -- Check rate limit
  local allowed, rate_err = check_rate_limit()
  if not allowed then
    return nil, rate_err
  end

  -- Sanitize code
  local sanitized, sanitize_err = sanitize_code(code_content)
  if not sanitized then
    return nil, sanitize_err
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
          sanitized
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
