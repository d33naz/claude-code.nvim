-- Demo: AI-Enhanced Workflow Assistance
-- This file demonstrates the automated workflow capabilities

local ai_integration = require('claude-code.ai_integration')

-- Sample code for AI analysis
local function example_function(data)
  local result = {}

  -- TODO: Optimize this loop
  for i = 1, #data do
    if data[i] then
      table.insert(result, data[i] * 2)
    end
  end

  return result
end

-- Demo workflow function
local function demo_workflow()
  print("Starting AI-Enhanced Workflow Demonstration...")

  -- 1. Health Check
  local available, error = ai_integration.check_health()
  if available then
    print("✅ AI Agent System: Connected")
  else
    print("❌ AI Agent System: " .. (error or "Unavailable"))
    return
  end

  -- 2. Code Analysis Example
  local code_sample = [[
    local function process_data(items)
      local results = {}
      for i = 1, #items do
        if items[i] ~= nil then
          results[#results + 1] = items[i] * 2
        end
      end
      return results
    end
  ]]

  print("🔍 Analyzing code with AI...")
  local analysis_result, analysis_error = ai_integration.analyze_code_quality(code_sample, 'lua')

  if analysis_result then
    print("✅ Code analysis completed")
    print("📊 Analysis available in buffer")
  else
    print("❌ Analysis failed: " .. (analysis_error or "Unknown error"))
  end

  -- 3. Optimization Suggestion
  print("⚡ Requesting performance optimization...")
  local opt_result, opt_error = ai_integration.optimize_code(code_sample, 'performance')

  if opt_result then
    print("✅ Optimization suggestions generated")
  else
    print("❌ Optimization failed: " .. (opt_error or "Unknown error"))
  end

  -- 4. Test Generation
  print("🧪 Generating test cases...")
  local test_result, test_error = ai_integration.generate_tests(code_sample, 'plenary')

  if test_result then
    print("✅ Test cases generated")
  else
    print("❌ Test generation failed: " .. (test_error or "Unknown error"))
  end

  print("🎉 AI-Enhanced Workflow Demonstration Complete!")
end

return {
  demo_workflow = demo_workflow,
  example_function = example_function
}