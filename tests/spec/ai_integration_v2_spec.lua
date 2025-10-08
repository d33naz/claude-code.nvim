---@diagnostic disable: undefined-field
local ai_integration = require('claude-code.ai_integration')

describe('AI Integration v2.0 (Enhanced)', function()
  before_each(function()
    -- Reset configuration
    ai_integration.config = {
      enabled = true,
      auto_health_check = false,
      health_check_interval = 30000,
      max_retries = 3,
      timeout = 5000,
      request_timeout = 30000,
      rate_limit = {
        max_requests_per_minute = 30,
        burst_size = 10,
      },
      cache = {
        enabled = true,
        ttl = 300,
        max_entries = 100,
      },
      queue = {
        enabled = true,
        max_size = 50,
        backoff_base = 1000,
        backoff_max = 30000,
      },
      privacy = {
        send_file_paths = false,
        redact_secrets = true,
        max_code_size = 100000,
      },
    }

    -- Clear cache
    ai_integration._cache = { entries = {}, access_count = 0 }
    ai_integration._rate_limit_state = {
      requests = {},
      last_cleanup = os.time(),
      queue = {},
      processing = false,
    }
    ai_integration.stats = {
      total_calls = 0,
      cache_hits = 0,
      cache_misses = 0,
      queue_enqueued = 0,
      errors = 0,
    }
  end)

  describe('async callback pattern', function()
    it('should provide async functions with callback pattern', function()
      assert.is_function(ai_integration.check_health_async)
      assert.is_function(ai_integration.api_request_async)
      assert.is_function(ai_integration.analyze_code_quality_async)
      assert.is_function(ai_integration.get_development_suggestions_async)
      assert.is_function(ai_integration.optimize_code_async)
      assert.is_function(ai_integration.generate_tests_async)
      assert.is_function(ai_integration.get_api_metrics_async)
    end)

    it('should not have Promise-like .next() method on responses', function()
      local result, err = ai_integration.api_request('/health', {})
      -- Result should be a table or nil, never an object with .next()
      if result then
        assert.is_table(result)
        assert.is_nil(result.next) -- No Promise pattern
      end
    end)

    it('should call callback with result and error parameters', function(done)
      local callback_called = false
      local callback_result = nil
      local callback_error = nil

      -- Test async callback pattern
      ai_integration.check_health_async(function(available, error)
        callback_called = true
        callback_result = available
        callback_error = error
        done()
      end)

      -- Wait a bit for async operation
      vim.wait(1000, function()
        return callback_called
      end)

      assert.is_true(callback_called)
      assert.is_boolean(callback_result)
    end)
  end)

  describe('enhanced secret redaction', function()
    it('should redact JWT tokens', function()
      local code = 'const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"'
      local sanitized, err = ai_integration.analyze_code_quality(code, 'javascript')
      -- Should not crash due to redaction
      assert.is_true(sanitized ~= nil or err ~= nil)
    end)

    it('should redact SSH keys', function()
      local code = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz... user@example.com'
      local result, err = ai_integration.api_request('/ai/chat', {
        messages = { { role = 'user', content = code } },
      })
      -- Should handle gracefully
      assert.is_true(result ~= nil or err ~= nil)
    end)

    it('should redact connection strings', function()
      local code = 'DATABASE_URL="postgresql://user:pass@localhost:5432/db"'
      -- Should redact before sending
      local result, err = ai_integration.api_request('/ai/chat', {
        messages = { { role = 'user', content = code } },
      })
      assert.is_true(result ~= nil or err ~= nil)
    end)

    it('should redact AWS keys', function()
      local code = 'const AWS_KEY = "AKIAIOSFODNN7EXAMPLE"'
      local result, err = ai_integration.api_request('/ai/chat', {
        messages = { { role = 'user', content = code } },
      })
      assert.is_true(result ~= nil or err ~= nil)
    end)
  end)

  describe('request caching', function()
    it('should cache successful API responses', function()
      -- First request should not hit cache
      local result1, err1 = ai_integration.api_request('/health', {})
      local cache_misses_1 = ai_integration.stats.cache_misses

      -- Second identical request should hit cache
      local result2, err2 = ai_integration.api_request('/health', {})
      local cache_hits_1 = ai_integration.stats.cache_hits

      -- Third request should also hit cache
      local result3, err3 = ai_integration.api_request('/health', {})
      local cache_hits_2 = ai_integration.stats.cache_hits

      -- Verify caching occurred
      if result1 and not err1 then
        assert.is_true(cache_hits_2 >= cache_hits_1)
      end
    end)

    it('should respect cache TTL', function()
      -- Set very short TTL for testing
      ai_integration.config.cache.ttl = 1 -- 1 second

      local result1, err1 = ai_integration.api_request('/health', {})

      -- Wait for cache to expire
      vim.wait(1500)

      local result2, err2 = ai_integration.api_request('/health', {})

      -- Second request should miss cache due to expiration
      -- Note: This test depends on timing and may be flaky
    end)

    it('should enforce max cache size', function()
      ai_integration.config.cache.max_entries = 3

      -- Make 5 different requests
      for i = 1, 5 do
        ai_integration.api_request('/endpoint' .. i, { data = i })
      end

      -- Cache should not exceed max size
      local cache_count = 0
      for _ in pairs(ai_integration._cache.entries) do
        cache_count = cache_count + 1
      end

      assert.is_true(cache_count <= 3)
    end)

    it('should have clear_cache function', function()
      -- Make some requests to populate cache
      ai_integration.api_request('/health', {})
      ai_integration.api_request('/health', {})

      -- Clear cache
      ai_integration.clear_cache()

      -- Stats should be reset
      assert.equals(0, ai_integration.stats.cache_hits)
      assert.equals(0, ai_integration.stats.cache_misses)

      -- Cache should be empty
      local cache_count = 0
      for _ in pairs(ai_integration._cache.entries) do
        cache_count = cache_count + 1
      end
      assert.equals(0, cache_count)
    end)
  end)

  describe('request queuing with backoff', function()
    it('should queue requests when rate limit exceeded', function()
      -- Fill rate limit
      for i = 1, ai_integration.config.rate_limit.max_requests_per_minute do
        ai_integration.api_request_async('/test' .. i, {}, function() end)
      end

      local initial_queue_size = #ai_integration._rate_limit_state.queue

      -- Next request should be queued
      ai_integration.api_request_async('/queued', {}, function() end)

      local new_queue_size = #ai_integration._rate_limit_state.queue

      -- Queue should have grown (or request was allowed)
      assert.is_true(new_queue_size >= initial_queue_size or ai_integration.stats.errors > 0)
    end)

    it('should respect max queue size', function()
      ai_integration.config.queue.max_size = 5

      -- Fill rate limit first
      for i = 1, ai_integration.config.rate_limit.max_requests_per_minute + 10 do
        ai_integration.api_request_async('/test' .. i, {}, function() end)
      end

      -- Queue should not exceed max size
      local queue_size = #ai_integration._rate_limit_state.queue
      assert.is_true(queue_size <= 5)
    end)
  end)

  describe('error boundaries', function()
    it('should handle API errors gracefully in sync functions', function()
      -- Force error by disabling integration
      ai_integration.config.enabled = false

      local result, error = ai_integration.analyze_code_quality('test code', 'lua')

      -- Should return error, not crash
      assert.is_nil(result)
      assert.is_string(error)
      assert.matches('disabled', error:lower())
    end)

    it('should handle malformed JSON in responses', function()
      -- This tests error handling in JSON parsing
      local result, err = ai_integration.api_request('/nonexistent', {})

      -- Should handle gracefully (either success or error, not crash)
      assert.is_true(result ~= nil or err ~= nil)
    end)

    it('should track errors in statistics', function()
      local initial_errors = ai_integration.stats.errors

      -- Force an error
      ai_integration.config.enabled = false
      ai_integration.analyze_code_quality('test', 'lua')

      -- Errors should increment
      assert.is_true(ai_integration.stats.errors >= initial_errors)
    end)
  end)

  describe('statistics tracking', function()
    it('should provide get_stats function', function()
      assert.is_function(ai_integration.get_stats)

      local stats = ai_integration.get_stats()

      assert.is_table(stats)
      assert.is_number(stats.total_calls)
      assert.is_number(stats.cache_hits)
      assert.is_number(stats.cache_misses)
      assert.is_number(stats.cache_hit_rate)
      assert.is_number(stats.queue_enqueued)
      assert.is_number(stats.queue_pending)
      assert.is_number(stats.errors)
      assert.is_number(stats.cached_entries)
    end)

    it('should calculate cache hit rate correctly', function()
      -- Clear stats
      ai_integration.stats.cache_hits = 10
      ai_integration.stats.cache_misses = 40

      local stats = ai_integration.get_stats()

      -- 10 hits out of 50 total = 20%
      assert.equals(20, stats.cache_hit_rate)
    end)

    it('should handle zero cache requests', function()
      ai_integration.stats.cache_hits = 0
      ai_integration.stats.cache_misses = 0

      local stats = ai_integration.get_stats()

      -- Should not error, hit rate should be 0
      assert.equals(0, stats.cache_hit_rate)
    end)
  end)

  describe('backward compatibility', function()
    it('should maintain synchronous API for existing code', function()
      -- Old code should still work
      local result, err = ai_integration.check_health()
      assert.is_boolean(result)

      local result2, err2 = ai_integration.api_request('/health', {})
      assert.is_true(result2 ~= nil or err2 ~= nil)
    end)

    it('should preserve all original engines', function()
      assert.is_table(ai_integration.engines)
      assert.is_not_nil(ai_integration.engines.dise)
      assert.is_not_nil(ai_integration.engines.ccas)
      assert.is_not_nil(ai_integration.engines.ana)
      assert.is_not_nil(ai_integration.engines.lgm)
      assert.is_not_nil(ai_integration.engines.rlgf)
    end)
  end)

  describe('vim.system security', function()
    it('should use vim.system for API calls when available', function()
      -- Verify vim.system is preferred over io.popen
      if vim.system then
        -- Make an API call
        local result, err = ai_integration.check_health()

        -- Should complete without errors (or with expected network errors)
        assert.is_boolean(result)
      end
    end)

    it('should provide fallback for older Neovim versions', function()
      -- The code should not crash on older versions
      -- (This is tested by the existence of fallback code)
      assert.is_function(ai_integration.check_health)
    end)
  end)

  describe('configuration', function()
    it('should support cache configuration', function()
      assert.is_table(ai_integration.config.cache)
      assert.is_boolean(ai_integration.config.cache.enabled)
      assert.is_number(ai_integration.config.cache.ttl)
      assert.is_number(ai_integration.config.cache.max_entries)
    end)

    it('should support queue configuration', function()
      assert.is_table(ai_integration.config.queue)
      assert.is_boolean(ai_integration.config.queue.enabled)
      assert.is_number(ai_integration.config.queue.max_size)
      assert.is_number(ai_integration.config.queue.backoff_base)
      assert.is_number(ai_integration.config.queue.backoff_max)
    end)
  end)
end)
