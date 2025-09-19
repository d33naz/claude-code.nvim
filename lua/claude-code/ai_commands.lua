---@mod claude-code.ai_commands AI-Enhanced Commands for Claude Code
---@brief [[
--- This module provides AI-powered commands that integrate with the NexaMind
--- agent system to provide intelligent development assistance directly within Neovim.
---@brief ]]

local ai_integration = require('claude-code.ai_integration')
local M = {}

--- @type table<string, function> List of AI-enhanced commands
M.commands = {}

--- Register AI-enhanced commands for Claude Code
--- @param claude_code table The main plugin module
function M.register_ai_commands(claude_code)
  -- AI Code Analysis Command
  vim.api.nvim_create_user_command('ClaudeCodeAnalyze', function()
    M.analyze_current_buffer()
  end, { desc = 'Analyze current buffer with AI' })

  -- AI Code Optimization Command
  vim.api.nvim_create_user_command('ClaudeCodeOptimize', function(args)
    local optimization_type = args.args ~= '' and args.args or 'performance'
    M.optimize_current_buffer(optimization_type)
  end, {
    desc = 'Optimize current buffer with AI',
    nargs = '?',
    complete = function()
      return { 'performance', 'readability', 'security', 'maintainability' }
    end,
  })

  -- AI Test Generation Command
  vim.api.nvim_create_user_command('ClaudeCodeGenerateTests', function(args)
    local framework = args.args ~= '' and args.args or 'auto'
    M.generate_tests_for_buffer(framework)
  end, {
    desc = 'Generate tests for current buffer with AI',
    nargs = '?',
    complete = function()
      return { 'auto', 'jest', 'pytest', 'junit', 'rspec', 'plenary' }
    end,
  })

  -- AI Development Suggestions Command
  vim.api.nvim_create_user_command('ClaudeCodeSuggest', function()
    M.get_development_suggestions()
  end, { desc = 'Get AI development suggestions for current project' })

  -- AI Agent Health Check Command
  vim.api.nvim_create_user_command('ClaudeCodeAgentHealth', function()
    M.check_agent_health()
  end, { desc = 'Check NexaMind agent system health' })

  -- AI Metrics Command
  vim.api.nvim_create_user_command('ClaudeCodeMetrics', function()
    M.show_ai_metrics()
  end, { desc = 'Show NexaMind AI system metrics' })

  -- AI Interactive Chat Command
  vim.api.nvim_create_user_command('ClaudeCodeChat', function(args)
    local message = args.args
    if message == '' then
      vim.ui.input({ prompt = 'Ask AI: ' }, function(input)
        if input then
          M.interactive_chat(input)
        end
      end)
    else
      M.interactive_chat(message)
    end
  end, {
    desc = 'Interactive chat with AI assistant',
    nargs = '*',
  })

  -- AI Code Review Command
  vim.api.nvim_create_user_command('ClaudeCodeReview', function()
    M.ai_code_review()
  end, { desc = 'Perform AI-powered code review on current buffer' })
end

--- Analyze current buffer with AI
function M.analyze_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')
  local file_type = vim.bo[bufnr].filetype

  if content == '' then
    vim.notify('Buffer is empty', vim.log.levels.WARN)
    return
  end

  vim.notify('Analyzing code with AI...', vim.log.levels.INFO)

  ai_integration.analyze_code_quality(content, file_type):next(function(result, error)
    vim.schedule(function()
      if error then
        vim.notify('AI Analysis failed: ' .. error, vim.log.levels.ERROR)
      elseif result and result.text then
        -- Create a new buffer with the analysis
        local analysis_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(analysis_buf, 'filetype', 'markdown')
        vim.api.nvim_buf_set_name(analysis_buf, 'AI Code Analysis')

        local analysis_lines = vim.split(result.text, '\n')
        vim.api.nvim_buf_set_lines(analysis_buf, 0, -1, false, analysis_lines)

        -- Open in a split window
        vim.cmd('vsplit')
        vim.api.nvim_win_set_buf(0, analysis_buf)
        vim.notify('AI analysis complete', vim.log.levels.INFO)
      else
        vim.notify('No analysis results received', vim.log.levels.WARN)
      end
    end)
  end)
end

--- Optimize current buffer with AI
--- @param optimization_type string Type of optimization
function M.optimize_current_buffer(optimization_type)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')

  if content == '' then
    vim.notify('Buffer is empty', vim.log.levels.WARN)
    return
  end

  vim.notify(
    string.format('Optimizing code for %s with AI...', optimization_type),
    vim.log.levels.INFO
  )

  ai_integration.optimize_code(content, optimization_type):next(function(result, error)
    vim.schedule(function()
      if error then
        vim.notify('AI Optimization failed: ' .. error, vim.log.levels.ERROR)
      elseif result and result.text then
        -- Show optimization suggestions in a new buffer
        local opt_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(opt_buf, 'filetype', 'markdown')
        vim.api.nvim_buf_set_name(opt_buf, 'AI Code Optimization')

        local opt_lines = vim.split(result.text, '\n')
        vim.api.nvim_buf_set_lines(opt_buf, 0, -1, false, opt_lines)

        vim.cmd('split')
        vim.api.nvim_win_set_buf(0, opt_buf)
        vim.notify('AI optimization complete', vim.log.levels.INFO)
      else
        vim.notify('No optimization results received', vim.log.levels.WARN)
      end
    end)
  end)
end

--- Generate tests for current buffer
--- @param framework string Testing framework
function M.generate_tests_for_buffer(framework)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')
  local file_type = vim.bo[bufnr].filetype

  if content == '' then
    vim.notify('Buffer is empty', vim.log.levels.WARN)
    return
  end

  -- Auto-detect framework based on file type if needed
  if framework == 'auto' then
    if file_type == 'javascript' or file_type == 'typescript' then
      framework = 'jest'
    elseif file_type == 'python' then
      framework = 'pytest'
    elseif file_type == 'lua' then
      framework = 'plenary'
    else
      framework = 'generic'
    end
  end

  vim.notify(string.format('Generating %s tests with AI...', framework), vim.log.levels.INFO)

  ai_integration.generate_tests(content, framework):next(function(result, error)
    vim.schedule(function()
      if error then
        vim.notify('AI Test generation failed: ' .. error, vim.log.levels.ERROR)
      elseif result and result.text then
        local test_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(test_buf, 'filetype', file_type)
        vim.api.nvim_buf_set_name(test_buf, 'AI Generated Tests')

        local test_lines = vim.split(result.text, '\n')
        vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, test_lines)

        vim.cmd('tabnew')
        vim.api.nvim_win_set_buf(0, test_buf)
        vim.notify('AI test generation complete', vim.log.levels.INFO)
      else
        vim.notify('No test generation results received', vim.log.levels.WARN)
      end
    end)
  end)
end

--- Get development suggestions
function M.get_development_suggestions()
  local cwd = vim.fn.getcwd()
  local file_type = vim.bo.filetype
  local context = {
    file_type = file_type,
    project_path = cwd,
    current_file = vim.api.nvim_buf_get_name(0),
  }

  vim.notify('Getting AI development suggestions...', vim.log.levels.INFO)

  ai_integration.get_development_suggestions(context):next(function(result, error)
    vim.schedule(function()
      if error then
        vim.notify('AI suggestions failed: ' .. error, vim.log.levels.ERROR)
      elseif result and result.text then
        local suggestions_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(suggestions_buf, 'filetype', 'markdown')
        vim.api.nvim_buf_set_name(suggestions_buf, 'AI Development Suggestions')

        local suggestion_lines = vim.split(result.text, '\n')
        vim.api.nvim_buf_set_lines(suggestions_buf, 0, -1, false, suggestion_lines)

        vim.cmd('split')
        vim.api.nvim_win_set_buf(0, suggestions_buf)
        vim.notify('AI suggestions ready', vim.log.levels.INFO)
      else
        vim.notify('No suggestions received', vim.log.levels.WARN)
      end
    end)
  end)
end

--- Check agent health
function M.check_agent_health()
  local available, error = ai_integration.check_health()

  if available then
    vim.notify('✅ NexaMind Agent System: Healthy', vim.log.levels.INFO)

    -- Get additional metrics
    ai_integration.get_api_metrics():next(function(metrics, err)
      vim.schedule(function()
        if metrics then
          local status_msg =
            string.format('✅ Agents: Active | Endpoints: Available | Status: Operational')
          vim.notify(status_msg, vim.log.levels.INFO)
        end
      end)
    end)
  else
    vim.notify('❌ NexaMind Agent System: ' .. (error or 'Unreachable'), vim.log.levels.ERROR)
  end
end

--- Show AI metrics
function M.show_ai_metrics()
  vim.notify('Fetching AI system metrics...', vim.log.levels.INFO)

  ai_integration.get_api_metrics():next(function(result, error)
    vim.schedule(function()
      if error then
        vim.notify('Failed to fetch metrics: ' .. error, vim.log.levels.ERROR)
      elseif result then
        local metrics_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(metrics_buf, 'filetype', 'json')
        vim.api.nvim_buf_set_name(metrics_buf, 'NexaMind AI Metrics')

        local json_str = vim.json.encode(result)
        local metrics_lines = vim.split(json_str, '\n')
        vim.api.nvim_buf_set_lines(metrics_buf, 0, -1, false, metrics_lines)

        vim.cmd('vsplit')
        vim.api.nvim_win_set_buf(0, metrics_buf)
        vim.notify('AI metrics loaded', vim.log.levels.INFO)
      else
        vim.notify('No metrics data received', vim.log.levels.WARN)
      end
    end)
  end)
end

--- Interactive chat with AI
--- @param message string Message to send to AI
function M.interactive_chat(message)
  vim.notify('Sending message to AI...', vim.log.levels.INFO)

  local request_data = {
    messages = {
      {
        role = 'system',
        content = 'You are a helpful AI assistant integrated into Neovim via Claude Code. Provide concise, actionable responses.',
      },
      {
        role = 'user',
        content = message,
      },
    },
  }

  ai_integration.api_request('/ai/chat', request_data):next(function(result, error)
    vim.schedule(function()
      if error then
        vim.notify('AI Chat failed: ' .. error, vim.log.levels.ERROR)
      elseif result and result.text then
        local chat_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(chat_buf, 'filetype', 'markdown')
        vim.api.nvim_buf_set_name(chat_buf, 'AI Chat Response')

        local response_lines = {
          '# AI Chat Response',
          '',
          '**Your question:** ' .. message,
          '',
          '**AI Response:**',
          '',
        }

        local ai_lines = vim.split(result.text, '\n')
        vim.list_extend(response_lines, ai_lines)

        vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, response_lines)

        vim.cmd('split')
        vim.api.nvim_win_set_buf(0, chat_buf)
        vim.notify('AI response ready', vim.log.levels.INFO)
      else
        vim.notify('No response received from AI', vim.log.levels.WARN)
      end
    end)
  end)
end

--- Perform AI code review
function M.ai_code_review()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')
  local file_type = vim.bo[bufnr].filetype
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if content == '' then
    vim.notify('Buffer is empty', vim.log.levels.WARN)
    return
  end

  vim.notify('Performing AI code review...', vim.log.levels.INFO)

  local request_data = {
    messages = {
      {
        role = 'system',
        content = 'You are an expert code reviewer. Perform a thorough code review focusing on: code quality, potential bugs, security issues, performance problems, maintainability, and best practices. Provide specific line-by-line feedback where applicable.',
      },
      {
        role = 'user',
        content = string.format(
          'Please review this %s code from %s:\n\n```%s\n%s\n```',
          file_type,
          filename,
          file_type,
          content
        ),
      },
    },
  }

  ai_integration.api_request('/ai/chat', request_data):next(function(result, error)
    vim.schedule(function()
      if error then
        vim.notify('AI Code review failed: ' .. error, vim.log.levels.ERROR)
      elseif result and result.text then
        local review_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(review_buf, 'filetype', 'markdown')
        vim.api.nvim_buf_set_name(review_buf, 'AI Code Review')

        local review_lines = {
          '# AI Code Review Report',
          '',
          '**File:** ' .. filename,
          '**Language:** ' .. file_type,
          '**Generated:** ' .. os.date('%Y-%m-%d %H:%M:%S'),
          '',
          '---',
          '',
        }

        local ai_lines = vim.split(result.text, '\n')
        vim.list_extend(review_lines, ai_lines)

        vim.api.nvim_buf_set_lines(review_buf, 0, -1, false, review_lines)

        vim.cmd('tabnew')
        vim.api.nvim_win_set_buf(0, review_buf)
        vim.notify('AI code review complete', vim.log.levels.INFO)
      else
        vim.notify('No review results received', vim.log.levels.WARN)
      end
    end)
  end)
end

return M
