---@mod claude-code.ai_integration AI Integration for Claude Code
---@brief [[
--- This module provides AI-powered development assistance by integrating
--- with the NexaMind agent system for intelligent code analysis, optimization,
--- and automated development workflows.
---
--- CHANGELOG v2.0:
--- - Fixed Promise pattern bug (async callbacks)
--- - Replaced io.popen with vim.system (security fix)
--- - Enhanced secret redaction (JWT, SSH keys, connection strings)
--- - Added request caching (5min TTL)
--- - Added request queuing with exponential backoff
--- - Added error boundaries for all AI calls
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
  cache = {
    enabled = true,
    ttl = 300, -- 5 minutes
    max_entries = 100,
  },
  queue = {
    enabled = true,
    max_size = 50,
    backoff_base = 1000, -- 1 second base delay
    backoff_max = 30000, -- 30 seconds max delay
  },
  privacy = {
    send_file_paths = false,
    redact_secrets = true,
    max_code_size = 100000, -- 100KB limit
  },
}

--- @type table Rate limiting state with queue
M._rate_limit_state = {
  requests = {},
  last_cleanup = os.time(),
  queue = {},
  processing = false,
}

--- @type table Request cache
M._cache = {
  entries = {},
  access_count = 0,
}

--- @type boolean Health check status cache
M._health_status = nil

--- @type number Last health check time
M._last_health_check = 0

--- @type table Statistics tracking
M.stats = {
  total_calls = 0,
  cache_hits = 0,
  cache_misses = 0,
  queue_enqueued = 0,
  errors = 0,
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

--- Enhanced secret redaction patterns including JWT, SSH keys, connection strings
--- @param code string Code content
--- @return string redacted_code
local function redact_secrets(code)
  if not M.config.privacy.redact_secrets then
    return code
  end

  -- Comprehensive secret patterns
  local patterns = {
    -- Generic long base64 strings
    { pattern = '(["\'])([A-Za-z0-9+/=]{32,})%1', replacement = '%1[REDACTED_SECRET]%1' },
    -- Passwords
    { pattern = 'password%s*=%s*["\']([^"\']+)["\']', replacement = 'password="[REDACTED]"' },
    { pattern = 'PASSWORD%s*=%s*["\']([^"\']+)["\']', replacement = 'PASSWORD="[REDACTED]"' },
    { pattern = 'pwd%s*=%s*["\']([^"\']+)["\']', replacement = 'pwd="[REDACTED]"' },
    -- API keys
    { pattern = 'api[_-]?key%s*=%s*["\']([^"\']+)["\']', replacement = 'api_key="[REDACTED]"' },
    { pattern = 'API[_-]?KEY%s*=%s*["\']([^"\']+)["\']', replacement = 'API_KEY="[REDACTED]"' },
    -- Tokens
    { pattern = 'token%s*=%s*["\']([^"\']+)["\']', replacement = 'token="[REDACTED]"' },
    { pattern = 'TOKEN%s*=%s*["\']([^"\']+)["\']', replacement = 'TOKEN="[REDACTED]"' },
    { pattern = 'access[_-]?token%s*=%s*["\']([^"\']+)["\']', replacement = 'access_token="[REDACTED]"' },
    -- Secrets
    { pattern = 'secret%s*=%s*["\']([^"\']+)["\']', replacement = 'secret="[REDACTED]"' },
    { pattern = 'SECRET%s*=%s*["\']([^"\']+)["\']', replacement = 'SECRET="[REDACTED]"' },
    -- JWT tokens
    { pattern = 'Bearer%s+[A-Za-z0-9._-]+', replacement = 'Bearer [REDACTED_JWT]' },
    { pattern = 'bearer%s+[A-Za-z0-9._-]+', replacement = 'bearer [REDACTED_JWT]' },
    { pattern = 'eyJ[A-Za-z0-9._-]+', replacement = '[REDACTED_JWT]' },
    -- SSH keys
    { pattern = 'ssh%-rsa%s+[A-Za-z0-9+/=]+', replacement = 'ssh-rsa [REDACTED_SSH_KEY]' },
    { pattern = 'ssh%-ed25519%s+[A-Za-z0-9+/=]+', replacement = 'ssh-ed25519 [REDACTED_SSH_KEY]' },
    { pattern = 'ssh%-dss%s+[A-Za-z0-9+/=]+', replacement = 'ssh-dss [REDACTED_SSH_KEY]' },
    -- Private keys
    { pattern = '%-%-%-%-%-BEGIN%s+[A-Z%s]+PRIVATE%s+KEY%-%-%-%-%-', replacement = '[REDACTED_PRIVATE_KEY]' },
    -- Connection strings
    { pattern = 'mongodb://[^"\'%s]+', replacement = 'mongodb://[REDACTED]' },
    { pattern = 'postgresql://[^"\'%s]+', replacement = 'postgresql://[REDACTED]' },
    { pattern = 'mysql://[^"\'%s]+', replacement = 'mysql://[REDACTED]' },
    { pattern = 'redis://[^"\'%s]+', replacement = 'redis://[REDACTED]' },
    -- AWS keys
    { pattern = 'AKIA[0-9A-Z]{16}', replacement = '[REDACTED_AWS_KEY]' },
    -- Environment variables with sensitive names
    { pattern = 'DATABASE_URL%s*=%s*["\']([^"\']+)["\']', replacement = 'DATABASE_URL="[REDACTED]"' },
    { pattern = 'REDIS_URL%s*=%s*["\']([^"\']+)["\']', replacement = 'REDIS_URL="[REDACTED]"' },
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

  -- Redact secrets BEFORE size check to prevent secrets in error messages
  local redacted = redact_secrets(code)

  -- Check size limit on redacted content
  if #redacted > M.config.privacy.max_code_size then
    return nil, string.format(
      'Code size exceeds limit: %d bytes (max: %d)',
      #redacted,
      M.config.privacy.max_code_size
    )
  end

  return redacted, nil
end

--- Generate cache key from endpoint and data
--- @param endpoint string API endpoint
--- @param data table Request data
--- @return string cache_key
local function generate_cache_key(endpoint, data)
  local json_data = vim.json.encode(data or {})
  return vim.fn.sha256(endpoint .. json_data)
end

--- Get cached response if available
--- @param cache_key string Cache key
--- @return table? cached_response
local function get_cached_response(cache_key)
  if not M.config.cache.enabled then
    return nil
  end

  local entry = M._cache.entries[cache_key]
  if not entry then
    M.stats.cache_misses = M.stats.cache_misses + 1
    return nil
  end

  -- Check TTL
  if os.time() - entry.timestamp > M.config.cache.ttl then
    M._cache.entries[cache_key] = nil
    M.stats.cache_misses = M.stats.cache_misses + 1
    return nil
  end

  M.stats.cache_hits = M.stats.cache_hits + 1
  return entry.response
end

--- Cache response
--- @param cache_key string Cache key
--- @param response table Response data
local function cache_response(cache_key, response)
  if not M.config.cache.enabled then
    return
  end

  -- Enforce max cache size (LRU-style)
  if vim.tbl_count(M._cache.entries) >= M.config.cache.max_entries then
    -- Remove oldest entry
    local oldest_key = nil
    local oldest_time = os.time()
    for key, entry in pairs(M._cache.entries) do
      if entry.timestamp < oldest_time then
        oldest_time = entry.timestamp
        oldest_key = key
      end
    end
    if oldest_key then
      M._cache.entries[oldest_key] = nil
    end
  end

  M._cache.entries[cache_key] = {
    response = response,
    timestamp = os.time(),
  }
end

--- Check rate limit compliance with queue support
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

--- Process queued requests with exponential backoff
local function process_queue()
  local state = M._rate_limit_state

  if state.processing or #state.queue == 0 then
    return
  end

  state.processing = true

  local function process_next(retry_count)
    retry_count = retry_count or 0

    if #state.queue == 0 then
      state.processing = false
      return
    end

    local allowed, _ = check_rate_limit()
    if not allowed then
      -- Exponential backoff
      local delay = math.min(
        M.config.queue.backoff_base * (2 ^ retry_count),
        M.config.queue.backoff_max
      )

      vim.defer_fn(function()
        process_next(retry_count + 1)
      end, delay)
      return
    end

    -- Process next item in queue
    local item = table.remove(state.queue, 1)
    if item and item.callback then
      item.callback()
    end

    -- Process next with no delay if rate limit allows
    vim.defer_fn(function()
      process_next(0)
    end, 100) -- Small delay to prevent tight loop
  end

  process_next(0)
end

--- Check if NexaMind API is available using vim.system (secure)
--- @param callback function Callback(available: boolean, error: string?)
function M.check_health_async(callback)
  -- Cache health check results for 30 seconds
  if M._health_status ~= nil and (os.time() - M._last_health_check) < 30 then
    callback(M._health_status, nil)
    return
  end

  local url = M.base_url .. '/health'

  vim.system(
    { 'curl', '-s', '-m', '2', url },
    { text = true },
    vim.schedule_wrap(function(obj)
      local available = false
      local error_message = nil

      if obj.code == 0 and obj.stdout and obj.stdout:match('"status":%s*"healthy"') then
        available = true
      else
        error_message = 'API not healthy or unreachable'
      end

      -- Cache result
      M._health_status = available
      M._last_health_check = os.time()

      callback(available, error_message)
    end)
  )
end

--- Synchronous health check (for backward compatibility)
--- @return boolean available
--- @return string? error_message
function M.check_health()
  local url = M.base_url .. '/health'

  -- Use vim.system synchronously on newer Neovim versions
  if vim.system then
    local obj = vim.system({ 'curl', '-s', '-m', '2', url }, { text = true }):wait()

    if obj.code == 0 and obj.stdout and obj.stdout:match('"status":%s*"healthy"') then
      M._health_status = true
      M._last_health_check = os.time()
      return true, nil
    end
  end

  M._health_status = false
  M._last_health_check = os.time()
  return false, 'API not healthy or unreachable'
end

--- Send request to NexaMind API (async with callback)
--- @param endpoint string API endpoint
--- @param data table Request data
--- @param callback function Callback(response: table?, error: string?)
function M.api_request_async(endpoint, data, callback)
  M.stats.total_calls = M.stats.total_calls + 1

  -- Check cache first
  local cache_key = generate_cache_key(endpoint, data)
  local cached = get_cached_response(cache_key)
  if cached then
    vim.schedule(function()
      callback(cached, nil)
    end)
    return
  end

  -- Check rate limit
  local allowed, rate_err = check_rate_limit()
  if not allowed then
    if M.config.queue.enabled and #M._rate_limit_state.queue < M.config.queue.max_size then
      -- Queue the request
      table.insert(M._rate_limit_state.queue, {
        callback = function()
          M.api_request_async(endpoint, data, callback)
        end,
      })
      M.stats.queue_enqueued = M.stats.queue_enqueued + 1

      -- Start queue processor
      process_queue()
      return
    else
      M.stats.errors = M.stats.errors + 1
      callback(nil, rate_err)
      return
    end
  end

  -- Try to encode data with error handling
  local ok, json_data = pcall(vim.json.encode, data or {})
  if not ok then
    M.stats.errors = M.stats.errors + 1
    callback(nil, 'Failed to encode request data: ' .. tostring(json_data))
    return
  end

  local url = M.base_url .. endpoint

  -- Use vim.system for secure execution (no shell injection)
  vim.system(
    {
      'curl',
      '-s',
      '-X',
      'POST',
      '-H',
      'Content-Type: application/json',
      '-d',
      json_data,
      url,
    },
    { text = true, timeout = M.config.request_timeout },
    vim.schedule_wrap(function(obj)
      if obj.code ~= 0 then
        M.stats.errors = M.stats.errors + 1
        callback(nil, 'API request failed with code: ' .. obj.code)
        return
      end

      -- Try to parse JSON response
      local parse_ok, parsed = pcall(vim.json.decode, obj.stdout or '{}')
      if parse_ok then
        -- Cache successful response
        cache_response(cache_key, parsed)
        callback(parsed, nil)
      else
        M.stats.errors = M.stats.errors + 1
        callback(nil, 'Invalid JSON response: ' .. tostring(parsed))
      end
    end)
  )
end

--- Synchronous API request (for backward compatibility)
--- @param endpoint string API endpoint
--- @param data table Request data
--- @return table? response
--- @return string? error
function M.api_request(endpoint, data)
  -- For synchronous calls, use vim.system:wait()
  if not vim.system then
    return nil, 'vim.system not available (requires Neovim 0.10+)'
  end

  M.stats.total_calls = M.stats.total_calls + 1

  -- Check cache first
  local cache_key = generate_cache_key(endpoint, data)
  local cached = get_cached_response(cache_key)
  if cached then
    return cached, nil
  end

  -- Check rate limit
  local allowed, rate_err = check_rate_limit()
  if not allowed then
    M.stats.errors = M.stats.errors + 1
    return nil, rate_err
  end

  -- Try to encode data with error handling
  local ok, json_data = pcall(vim.json.encode, data or {})
  if not ok then
    M.stats.errors = M.stats.errors + 1
    return nil, 'Failed to encode request data: ' .. tostring(json_data)
  end

  local url = M.base_url .. endpoint

  local obj = vim.system(
    {
      'curl',
      '-s',
      '-X',
      'POST',
      '-H',
      'Content-Type: application/json',
      '-d',
      json_data,
      url,
    },
    { text = true, timeout = M.config.request_timeout }
  ):wait()

  if obj.code ~= 0 then
    M.stats.errors = M.stats.errors + 1
    return nil, 'API request failed with code: ' .. obj.code
  end

  -- Try to parse JSON response
  local parse_ok, parsed = pcall(vim.json.decode, obj.stdout or '{}')
  if parse_ok then
    -- Cache successful response
    cache_response(cache_key, parsed)
    return parsed, nil
  else
    M.stats.errors = M.stats.errors + 1
    return nil, 'Invalid JSON response: ' .. tostring(parsed)
  end
end

--- Safe AI call wrapper with error boundaries
--- @param fn function Function to execute
--- @param fallback any Fallback value on error
--- @param error_context string Context for error message
--- @return any result
local function safe_ai_call(fn, fallback, error_context)
  local success, result, err = pcall(fn)

  if not success then
    vim.notify(
      string.format('AI feature error (%s): %s', error_context, tostring(result)),
      vim.log.levels.WARN
    )
    M.stats.errors = M.stats.errors + 1
    return fallback
  end

  if err then
    vim.notify(
      string.format('AI feature unavailable (%s): %s', error_context, err),
      vim.log.levels.WARN
    )
    return fallback
  end

  return result
end

--- Analyze code quality using AI (async)
--- @param code_content string Code to analyze
--- @param file_type string Programming language
--- @param callback function Callback(analysis: table?, error: string?)
function M.analyze_code_quality_async(code_content, file_type, callback)
  if not M.config.enabled then
    callback(nil, 'AI integration is disabled')
    return
  end

  M.check_health_async(function(available, err)
    if not available then
      callback(nil, 'NexaMind API unavailable: ' .. (err or 'unknown error'))
      return
    end

    -- Sanitize code
    local sanitized, sanitize_err = sanitize_code(code_content)
    if not sanitized then
      callback(nil, sanitize_err)
      return
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

    M.api_request_async('/ai/chat', request_data, callback)
  end)
end

--- Analyze code quality using AI (sync - backward compatible)
--- @param code_content string Code to analyze
--- @param file_type string Programming language
--- @return table? analysis
--- @return string? error
function M.analyze_code_quality(code_content, file_type)
  return safe_ai_call(function()
    if not M.config.enabled then
      return nil, 'AI integration is disabled'
    end

    local available, err = M.check_health()
    if not available then
      return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
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
  end, nil, 'code analysis')
end

--- Get AI-powered development suggestions (async)
--- @param context table Development context
--- @param callback function Callback(suggestions: table?, error: string?)
function M.get_development_suggestions_async(context, callback)
  M.check_health_async(function(available, err)
    if not available then
      callback(nil, 'NexaMind API unavailable: ' .. (err or 'unknown error'))
      return
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

    M.api_request_async('/ai/chat', request_data, callback)
  end)
end

--- Get AI-powered development suggestions (sync)
--- @param context table Development context
--- @return table? suggestions
--- @return string? error
function M.get_development_suggestions(context)
  return safe_ai_call(function()
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
  end, nil, 'development suggestions')
end

--- Optimize code using AI engines (async)
--- @param code_content string Code to optimize
--- @param optimization_type string Type of optimization
--- @param callback function Callback(optimized_code: table?, error: string?)
function M.optimize_code_async(code_content, optimization_type, callback)
  if not M.config.enabled then
    callback(nil, 'AI integration is disabled')
    return
  end

  M.check_health_async(function(available, err)
    if not available then
      callback(nil, 'NexaMind API unavailable: ' .. (err or 'unknown error'))
      return
    end

    -- Sanitize code
    local sanitized, sanitize_err = sanitize_code(code_content)
    if not sanitized then
      callback(nil, sanitize_err)
      return
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

    M.api_request_async('/ai/chat', request_data, callback)
  end)
end

--- Optimize code using AI engines (sync)
--- @param code_content string Code to optimize
--- @param optimization_type string Type of optimization
--- @return table? optimized_code
--- @return string? error
function M.optimize_code(code_content, optimization_type)
  return safe_ai_call(function()
    if not M.config.enabled then
      return nil, 'AI integration is disabled'
    end

    local available, err = M.check_health()
    if not available then
      return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
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
  end, nil, 'code optimization')
end

--- Generate tests using AI (async)
--- @param code_content string Code to generate tests for
--- @param test_framework string Testing framework to use
--- @param callback function Callback(test_code: table?, error: string?)
function M.generate_tests_async(code_content, test_framework, callback)
  M.check_health_async(function(available, err)
    if not available then
      callback(nil, 'NexaMind API unavailable: ' .. (err or 'unknown error'))
      return
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

    M.api_request_async('/ai/chat', request_data, callback)
  end)
end

--- Generate tests using AI (sync)
--- @param code_content string Code to generate tests for
--- @param test_framework string Testing framework to use
--- @return table? test_code
--- @return string? error
function M.generate_tests(code_content, test_framework)
  return safe_ai_call(function()
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
  end, nil, 'test generation')
end

--- Get API metrics and status (async)
--- @param callback function Callback(metrics: table?, error: string?)
function M.get_api_metrics_async(callback)
  M.check_health_async(function(available, err)
    if not available then
      callback(nil, 'NexaMind API unavailable: ' .. (err or 'unknown error'))
      return
    end

    M.api_request_async('/api/v1/metrics/metrics/latest', {}, callback)
  end)
end

--- Get API metrics and status (sync)
--- @return table? metrics
--- @return string? error
function M.get_api_metrics()
  return safe_ai_call(function()
    local available, err = M.check_health()
    if not available then
      return nil, 'NexaMind API unavailable: ' .. (err or 'unknown error')
    end

    return M.api_request('/api/v1/metrics/metrics/latest', {})
  end, nil, 'API metrics')
end

--- Clear request cache
function M.clear_cache()
  M._cache.entries = {}
  M.stats.cache_hits = 0
  M.stats.cache_misses = 0
  vim.notify('AI request cache cleared', vim.log.levels.INFO)
end

--- Get current statistics
--- @return table stats
function M.get_stats()
  local cache_hit_rate = 0
  local total_cache_requests = M.stats.cache_hits + M.stats.cache_misses
  if total_cache_requests > 0 then
    cache_hit_rate = (M.stats.cache_hits / total_cache_requests) * 100
  end

  return {
    total_calls = M.stats.total_calls,
    cache_hits = M.stats.cache_hits,
    cache_misses = M.stats.cache_misses,
    cache_hit_rate = cache_hit_rate,
    queue_enqueued = M.stats.queue_enqueued,
    queue_pending = #M._rate_limit_state.queue,
    errors = M.stats.errors,
    cached_entries = vim.tbl_count(M._cache.entries),
  }
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
    M.check_health_async(function(available, err)
      if available then
        vim.notify('NexaMind AI integration: Ready', vim.log.levels.INFO)
      else
        vim.notify(
          string.format('NexaMind AI integration: Unavailable (%s)', err or 'unknown error'),
          vim.log.levels.WARN
        )
      end
    end)
  end)

  -- Setup periodic health checks if enabled
  if M.config.auto_health_check then
    local timer = vim.loop.new_timer()
    timer:start(M.config.health_check_interval, M.config.health_check_interval, function()
      vim.schedule(function()
        M.check_health_async(function(available)
          if not available then
            vim.notify('NexaMind AI integration: Connection lost', vim.log.levels.WARN)
          end
        end)
      end)
    end)
  end
end

return M
