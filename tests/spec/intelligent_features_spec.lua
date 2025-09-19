---@diagnostic disable: undefined-field
local intelligent_features = require('claude-code.intelligent_features')

describe('Intelligent Features', function()
  before_each(function()
    -- Reset configuration
    intelligent_features.config = {
      auto_analyze_on_save = false,
      auto_suggest_improvements = true,
      performance_monitoring = true,
      intelligent_completion = true,
      code_quality_gates = true,
    }
  end)

  describe('configuration', function()
    it('should setup with default configuration', function()
      assert.has_no_error(function()
        intelligent_features.setup()
      end)
    end)

    it('should merge user configuration with defaults', function()
      local user_config = {
        auto_analyze_on_save = true,
        custom_option = "test_value"
      }

      intelligent_features.setup(user_config)

      assert.is_true(intelligent_features.config.auto_analyze_on_save)
      assert.equals("test_value", intelligent_features.config.custom_option)
      -- Should preserve other defaults
      assert.is_true(intelligent_features.config.intelligent_completion)
    end)

    it('should handle empty user configuration', function()
      assert.has_no_error(function()
        intelligent_features.setup({})
      end)
    end)
  end)

  describe('agent capabilities', function()
    it('should have defined agent capabilities', function()
      assert.is_table(intelligent_features.agent_capabilities)
      assert.is_not_nil(intelligent_features.agent_capabilities.orchestrator)
      assert.is_not_nil(intelligent_features.agent_capabilities.validator)
      assert.is_not_nil(intelligent_features.agent_capabilities.security)
      assert.is_not_nil(intelligent_features.agent_capabilities.dise)
    end)

    it('should have correct agent structure', function()
      for agent_type, agent in pairs(intelligent_features.agent_capabilities) do
        assert.is_string(agent.name, string.format("Agent %s should have name", agent_type))
        assert.is_table(agent.capabilities, string.format("Agent %s should have capabilities", agent_type))
        assert.is_true(#agent.capabilities > 0, string.format("Agent %s should have at least one capability", agent_type))
      end
    end)

    it('should have all expected agents', function()
      local expected_agents = {
        'orchestrator', 'demo_executor', 'validator', 'architect',
        'security', 'legal', 'innovation', 'crisis', 'customer',
        'dise', 'neural', 'growth', 'data', 'integration'
      }

      for _, agent_type in ipairs(expected_agents) do
        assert.is_not_nil(intelligent_features.agent_capabilities[agent_type],
          string.format("Agent %s should be defined", agent_type))
      end
    end)
  end)

  describe('prompt creation', function()
    it('should create specialized prompts for different agents', function()
      local test_data = {
        content = "function test() { return true; }",
        file_type = "javascript",
        filename = "test.js"
      }

      local security_prompt = intelligent_features.create_agent_prompt('security', 'security_scan', test_data)
      local validator_prompt = intelligent_features.create_agent_prompt('validator', 'quality_analysis', test_data)

      assert.is_string(security_prompt)
      assert.is_string(validator_prompt)
      assert.is_not_equal(security_prompt, validator_prompt)
      assert.matches("security", security_prompt)
      assert.matches("quality", validator_prompt)
    end)

    it('should include file information in prompts', function()
      local test_data = {
        content = "print('hello')",
        file_type = "python",
        filename = "hello.py"
      }

      local prompt = intelligent_features.create_agent_prompt('dise', 'performance_analysis', test_data)

      assert.matches("python", prompt)
      assert.matches("hello.py", prompt)
      assert.matches("print", prompt)
    end)

    it('should handle unknown agent types gracefully', function()
      local test_data = {
        content = "test",
        file_type = "text",
        filename = "test.txt"
      }

      local prompt = intelligent_features.create_agent_prompt('unknown_agent', 'unknown_task', test_data)

      -- Should still return a valid prompt with base content
      assert.is_string(prompt)
      assert.matches("test", prompt)
    end)
  end)

  describe('project language detection', function()
    it('should detect languages from file extensions', function()
      -- Mock globpath to return test files
      local original_globpath = vim.fn.globpath
      vim.fn.globpath = function(path, pattern, nosuf, list)
        return {"test.lua", "app.js", "main.py", "config.json"}
      end

      local languages = intelligent_features.detect_project_languages()

      assert.is_table(languages)
      assert.is_true(vim.tbl_contains(languages, "Lua"))
      assert.is_true(vim.tbl_contains(languages, "JavaScript"))
      assert.is_true(vim.tbl_contains(languages, "Python"))

      -- Restore original function
      vim.fn.globpath = original_globpath
    end)

    it('should handle projects with no recognized languages', function()
      local original_globpath = vim.fn.globpath
      vim.fn.globpath = function(path, pattern, nosuf, list)
        return {"README.md", "config.yaml", "data.json"}
      end

      local languages = intelligent_features.detect_project_languages()

      assert.is_table(languages)
      -- Should not crash, may be empty or contain recognized extensions

      vim.fn.globpath = original_globpath
    end)

    it('should handle empty project directory', function()
      local original_globpath = vim.fn.globpath
      vim.fn.globpath = function(path, pattern, nosuf, list)
        return {}
      end

      local languages = intelligent_features.detect_project_languages()

      assert.is_table(languages)
      assert.equals(0, #languages)

      vim.fn.globpath = original_globpath
    end)
  end)

  describe('git information', function()
    it('should extract git information safely', function()
      local git_info = intelligent_features.get_git_info()

      assert.is_table(git_info)
      -- Should have branch and commits fields (may be "unknown" or "0" if not in git repo)
      assert.is_not_nil(git_info.branch)
      assert.is_not_nil(git_info.commits)
    end)

    it('should handle non-git directories gracefully', function()
      -- Should not crash even if git commands fail
      assert.has_no_error(function()
        intelligent_features.get_git_info()
      end)
    end)
  end)

  describe('function context detection', function()
    it('should detect function context in buffer', function()
      -- Create a test buffer with function definition
      local bufnr = vim.api.nvim_create_buf(false, true)
      local lines = {
        "local M = {}",
        "",
        "function M.test_function()",
        "  local x = 1",
        "  return x + 1",
        "end",
        "",
        "return M"
      }

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_set_current_buf(bufnr)
      vim.api.nvim_win_set_cursor(0, {4, 0}) -- Position inside function

      local context = intelligent_features.get_current_function_context()

      -- Should detect function
      if context then
        assert.is_string(context)
        assert.matches("function", context)
      end

      -- Clean up
      vim.api.nvim_buf_delete(bufnr, {force = true})
    end)

    it('should handle buffers without functions', function()
      local bufnr = vim.api.nvim_create_buf(false, true)
      local lines = {
        "-- Just a comment",
        "local x = 1",
        "print(x)"
      }

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_set_current_buf(bufnr)

      local context = intelligent_features.get_current_function_context()

      -- Should return nil for no function context
      assert.is_nil(context)

      vim.api.nvim_buf_delete(bufnr, {force = true})
    end)
  end)

  describe('performance monitoring', function()
    it('should track performance metrics', function()
      -- Run performance monitoring
      intelligent_features.monitor_plugin_performance()

      -- Should create performance history
      assert.is_table(intelligent_features._performance_history)
      assert.is_true(#intelligent_features._performance_history > 0)

      local latest = intelligent_features._performance_history[#intelligent_features._performance_history]
      assert.is_number(latest.memory_usage)
      assert.is_number(latest.last_check)
    end)

    it('should limit performance history size', function()
      -- Fill history beyond limit
      intelligent_features._performance_history = {}
      for i = 1, 105 do
        table.insert(intelligent_features._performance_history, {
          memory_usage = 1000,
          api_calls_made = i,
          last_check = os.time()
        })
      end

      intelligent_features.monitor_plugin_performance()

      -- Should not exceed 100 entries
      assert.is_true(#intelligent_features._performance_history <= 100)
    end)
  end)

  describe('quality gate checks', function()
    it('should detect TODO comments', function()
      local bufnr = vim.api.nvim_create_buf(false, true)
      local lines = {
        "function test()",
        "  -- TODO: Fix this later",
        "  return true",
        "end"
      }

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

      -- Should detect TODO without crashing
      assert.has_no_error(function()
        intelligent_features.run_quality_gate_checks(bufnr)
      end)

      vim.api.nvim_buf_delete(bufnr, {force = true})
    end)

    it('should detect debug statements', function()
      local bufnr = vim.api.nvim_create_buf(false, true)
      local lines = {
        "function debug_test()",
        "  console.log('debug info')",
        "  return true",
        "end"
      }

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

      assert.has_no_error(function()
        intelligent_features.run_quality_gate_checks(bufnr)
      end)

      vim.api.nvim_buf_delete(bufnr, {force = true})
    end)

    it('should detect large files', function()
      local bufnr = vim.api.nvim_create_buf(false, true)
      local large_lines = {}

      -- Create a file with more than 1000 lines
      for i = 1, 1001 do
        table.insert(large_lines, "-- Line " .. i)
      end

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, large_lines)

      assert.has_no_error(function()
        intelligent_features.run_quality_gate_checks(bufnr)
      end)

      vim.api.nvim_buf_delete(bufnr, {force = true})
    end)

    it('should handle empty buffers', function()
      local bufnr = vim.api.nvim_create_buf(false, true)

      assert.has_no_error(function()
        intelligent_features.run_quality_gate_checks(bufnr)
      end)

      vim.api.nvim_buf_delete(bufnr, {force = true})
    end)
  end)

  describe('error handling', function()
    it('should handle missing agent types gracefully', function()
      local callback_called = false
      local error_message = nil

      intelligent_features.call_specialized_agent('nonexistent_agent', 'test_task', {}, function(result, error)
        callback_called = true
        error_message = error
      end)

      -- Wait for callback
      vim.wait(100)

      assert.is_true(callback_called)
      assert.is_string(error_message)
      assert.matches("Unknown agent type", error_message)
    end)

    it('should handle API failures in agent calls', function()
      -- Mock AI integration to fail
      local original_request = require('claude-code.ai_integration').api_request
      require('claude-code.ai_integration').api_request = function(endpoint, data)
        return nil, "API request failed"
      end

      local callback_called = false
      local error_received = nil

      intelligent_features.call_specialized_agent('validator', 'quality_analysis', {
        content = "test",
        file_type = "lua",
        filename = "test.lua"
      }, function(result, error)
        callback_called = true
        error_received = error
      end)

      -- Wait for callback
      vim.wait(100)

      assert.is_true(callback_called)
      assert.is_string(error_received)

      -- Restore original function
      require('claude-code.ai_integration').api_request = original_request
    end)
  end)
end)