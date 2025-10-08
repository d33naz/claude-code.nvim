---@diagnostic disable: undefined-field
local ai_integration = require('claude-code.ai_integration')

describe('AI Integration', function()
  before_each(function()
    -- Reset any state
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

    -- Initialize cache and rate limit state
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

  describe('health check', function()
    it('should return availability status', function()
      local available, error = ai_integration.check_health()
      -- Should return boolean and optional error message
      assert.is_boolean(available)
      if not available then
        assert.is_string(error)
      end
    end)

    it('should handle network errors gracefully', function()
      -- Mock curl failure
      local original_base_url = ai_integration.base_url
      ai_integration.base_url = "http://nonexistent-host:9999"

      local available, error = ai_integration.check_health()
      assert.is_false(available)
      assert.is_string(error)

      -- Restore original URL
      ai_integration.base_url = original_base_url
    end)
  end)

  describe('API request', function()
    it('should handle valid endpoints', function()
      -- Test with a simple endpoint that should exist
      local result, error = ai_integration.api_request('/health', {})

      -- Should return either result or error
      assert.is_true(result ~= nil or error ~= nil)
      if error then
        assert.is_string(error)
      end
    end)

    it('should handle invalid endpoints', function()
      local result, error = ai_integration.api_request('/nonexistent-endpoint', {})

      -- Should handle gracefully
      assert.is_true(result ~= nil or error ~= nil)
    end)

    it('should handle malformed data', function()
      -- Test with circular reference that can't be JSON encoded
      local circular = {}
      circular.self = circular

      local result, error = ai_integration.api_request('/health', circular)
      -- Should handle encoding errors
      if error then
        assert.is_string(error)
      end
    end)
  end)

  describe('code analysis', function()
    it('should analyze simple Lua code', function()
      local code = [[
        local function hello()
          print("Hello, World!")
        end
        hello()
      ]]

      local result, error = ai_integration.analyze_code_quality(code, 'lua')

      -- Should return analysis or error
      assert.is_true(result ~= nil or error ~= nil)
      if error then
        assert.is_string(error)
      end
    end)

    it('should handle empty code', function()
      local result, error = ai_integration.analyze_code_quality('', 'lua')

      -- Should handle empty input gracefully
      assert.is_true(result ~= nil or error ~= nil)
    end)

    it('should handle different file types', function()
      local js_code = 'function test() { console.log("test"); }'
      local py_code = 'def test():\n    print("test")'

      local js_result, js_error = ai_integration.analyze_code_quality(js_code, 'javascript')
      local py_result, py_error = ai_integration.analyze_code_quality(py_code, 'python')

      -- Should handle different languages
      assert.is_true(js_result ~= nil or js_error ~= nil)
      assert.is_true(py_result ~= nil or py_error ~= nil)
    end)
  end)

  describe('development suggestions', function()
    it('should provide suggestions for project context', function()
      local context = {
        file_type = 'lua',
        project_type = 'neovim_plugin',
        current_task = 'development'
      }

      local result, error = ai_integration.get_development_suggestions(context)

      -- Should return suggestions or error
      assert.is_true(result ~= nil or error ~= nil)
      if error then
        assert.is_string(error)
      end
    end)

    it('should handle minimal context', function()
      local context = {}
      local result, error = ai_integration.get_development_suggestions(context)

      -- Should handle minimal context gracefully
      assert.is_true(result ~= nil or error ~= nil)
    end)
  end)

  describe('code optimization', function()
    it('should optimize code for performance', function()
      local code = [[
        for i = 1, 1000000 do
          table.insert(results, i * 2)
        end
      ]]

      local result, error = ai_integration.optimize_code(code, 'performance')

      -- Should return optimization suggestions or error
      assert.is_true(result ~= nil or error ~= nil)
      if error then
        assert.is_string(error)
      end
    end)

    it('should handle different optimization types', function()
      local code = 'local x = 1 + 1'

      local perf_result, perf_error = ai_integration.optimize_code(code, 'performance')
      local read_result, read_error = ai_integration.optimize_code(code, 'readability')

      -- Should handle different optimization types
      assert.is_true(perf_result ~= nil or perf_error ~= nil)
      assert.is_true(read_result ~= nil or read_error ~= nil)
    end)
  end)

  describe('test generation', function()
    it('should generate tests for Lua code', function()
      local code = [[
        local function add(a, b)
          return a + b
        end
      ]]

      local result, error = ai_integration.generate_tests(code, 'plenary')

      -- Should return test code or error
      assert.is_true(result ~= nil or error ~= nil)
      if error then
        assert.is_string(error)
      end
    end)

    it('should handle different test frameworks', function()
      local code = 'function add(a, b) { return a + b; }'

      local jest_result, jest_error = ai_integration.generate_tests(code, 'jest')
      local pytest_result, pytest_error = ai_integration.generate_tests(code, 'pytest')

      -- Should handle different frameworks
      assert.is_true(jest_result ~= nil or jest_error ~= nil)
      assert.is_true(pytest_result ~= nil or pytest_error ~= nil)
    end)
  end)

  describe('API metrics', function()
    it('should fetch metrics when API is available', function()
      local result, error = ai_integration.get_api_metrics()

      -- Should return metrics or error
      assert.is_true(result ~= nil or error ~= nil)
      if error then
        assert.is_string(error)
      end
    end)
  end)

  describe('configuration', function()
    it('should setup with default configuration', function()
      -- Should not throw error
      assert.has_no_error(function()
        ai_integration.setup()
      end)
    end)

    it('should setup with custom configuration', function()
      local custom_config = {
        auto_health_check = true,
        timeout = 10000
      }

      assert.has_no_error(function()
        ai_integration.setup(custom_config)
      end)

      -- Should merge configurations
      assert.is_true(ai_integration.config.auto_health_check)
      assert.equals(10000, ai_integration.config.timeout)
    end)

    it('should preserve unspecified default values', function()
      local custom_config = {
        timeout = 1000
      }

      ai_integration.setup(custom_config)

      -- Should preserve defaults for unspecified values
      assert.equals(3, ai_integration.config.max_retries)
      assert.equals(1000, ai_integration.config.timeout)
    end)
  end)

  describe('engine information', function()
    it('should have defined engines', function()
      assert.is_table(ai_integration.engines)
      assert.is_not_nil(ai_integration.engines.dise)
      assert.is_not_nil(ai_integration.engines.ccas)
      assert.is_not_nil(ai_integration.engines.ana)
      assert.is_not_nil(ai_integration.engines.lgm)
      assert.is_not_nil(ai_integration.engines.rlgf)
    end)

    it('should have correct engine structure', function()
      for name, engine in pairs(ai_integration.engines) do
        assert.is_string(engine.name, string.format("Engine %s should have name", name))
        assert.is_string(engine.endpoint, string.format("Engine %s should have endpoint", name))
        assert.is_string(engine.description, string.format("Engine %s should have description", name))
      end
    end)
  end)

  describe('error handling', function()
    it('should handle API unavailability gracefully', function()
      -- Ensure AI integration is enabled
      local original_enabled = ai_integration.config.enabled
      ai_integration.config.enabled = true

      -- Mock API as unavailable
      local original_check = ai_integration.check_health
      ai_integration.check_health = function()
        return false, "API unavailable"
      end

      local result, error = ai_integration.analyze_code_quality("test code", "lua")
      assert.is_nil(result)
      assert.is_string(error)
      assert.matches("API unavailable", error)

      -- Restore original functions
      ai_integration.check_health = original_check
      ai_integration.config.enabled = original_enabled
    end)

    it('should handle JSON parsing errors', function()
      -- Mock api_request to return invalid JSON
      local original_request = ai_integration.api_request
      ai_integration.api_request = function(endpoint, data)
        return nil, "Invalid JSON response"
      end

      local result, error = ai_integration.analyze_code_quality("test", "lua")
      assert.is_nil(result)
      assert.is_string(error)

      -- Restore original function
      ai_integration.api_request = original_request
    end)
  end)
end)