#!/usr/bin/env bash
#
# AI Features Demo - Claude Code with NexaMind Integration
#
# This demo showcases AI-powered development features including
# code analysis, optimization, and test generation.
#
# Prerequisites:
#   - NexaMind API running on localhost:8004
#   - Claude Code plugin installed in Neovim
#   - Docker (for API deployment)
#
# Usage:
#   ./config/demo-scenarios/ai-features-demo.sh

set -euo pipefail

DEMO_DIR="${HOME}/claude-code-demo-ai"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

print_info() {
  echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
  print_step "Checking Prerequisites"

  # Check Docker
  if ! command -v docker &> /dev/null; then
    print_error "Docker not found. Please install Docker first."
    exit 1
  fi
  print_info "Docker: OK"

  # Check curl
  if ! command -v curl &> /dev/null; then
    print_error "curl not found. Please install curl."
    exit 1
  fi
  print_info "curl: OK"

  # Check Neovim
  if ! command -v nvim &> /dev/null; then
    print_error "Neovim not found. Please install Neovim."
    exit 1
  fi
  print_info "Neovim: OK"

  echo ""
}

# Deploy NexaMind API
deploy_api() {
  print_step "Deploying NexaMind API"

  # Check if already running
  if docker ps | grep -q nexamind-api; then
    print_info "NexaMind API already running"
    return 0
  fi

  # Check if container exists but stopped
  if docker ps -a | grep -q nexamind-api; then
    print_info "Starting existing container..."
    docker start nexamind-api
  else
    print_info "Creating new NexaMind API container..."

    # Create docker-compose.yml
    cat > /tmp/nexamind-compose.yml <<'EOF'
version: '3.8'

services:
  nexamind-api:
    image: nexamind/api:latest
    container_name: nexamind-api
    ports:
      - "8004:8004"
    environment:
      - LOG_LEVEL=info
      - API_PORT=8004
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8004/health"]
      interval: 10s
      timeout: 5s
      retries: 5
EOF

    docker-compose -f /tmp/nexamind-compose.yml up -d
  fi

  # Wait for API to be ready
  print_info "Waiting for API to be ready..."
  local retries=0
  local max_retries=30

  while [ $retries -lt $max_retries ]; do
    if curl -s http://localhost:8004/health > /dev/null 2>&1; then
      print_info "NexaMind API is ready!"
      return 0
    fi
    retries=$((retries + 1))
    echo -n "."
    sleep 1
  done

  print_error "API failed to start after ${max_retries} seconds"
  exit 1
}

# Create demo project
create_demo_project() {
  print_step "Creating Demo Project"

  mkdir -p "$DEMO_DIR"
  cd "$DEMO_DIR"

  # Initialize git
  git init 2>/dev/null || true
  git config user.email "demo@example.com" 2>/dev/null || true
  git config user.name "Demo User" 2>/dev/null || true

  # Create sample files for demonstration

  # 1. Poorly written code (for quality analysis)
  cat > bad-code.js <<'EOF'
function processData(d) {
  var r = [];
  for (var i = 0; i < d.length; i++) {
    if (d[i].s == 1) {
      var x = d[i].n.split(',');
      for (var j = 0; j < x.length; j++) {
        r.push(x[j].trim());
      }
    }
  }
  return r;
}

// No error handling, magic numbers, poor naming
function calc(a, b, t) {
  if (t === 1) return a + b * 0.1;
  if (t === 2) return a + b * 0.2;
  return a + b;
}
EOF

  # 2. Unoptimized React component (for performance optimization)
  cat > SlowComponent.tsx <<'EOF'
import React from 'react';

function UserList({ users }) {
  const filtered = users.filter(u => u.active);
  const sorted = filtered.sort((a, b) => a.name.localeCompare(b.name));

  return (
    <div>
      {sorted.map(user => (
        <UserCard
          key={user.id}
          user={user}
          onClick={() => handleClick(user)}
          onDelete={() => handleDelete(user.id)}
        />
      ))}
    </div>
  );
}

function handleClick(user) {
  console.log('Clicked:', user);
  // Expensive operation
  const data = JSON.parse(JSON.stringify(user));
  processUser(data);
}

function handleDelete(id) {
  // API call
  fetch(`/api/users/${id}`, { method: 'DELETE' });
}
EOF

  # 3. Function to generate tests for
  cat > validators.ts <<'EOF'
export function validateEmail(email: string): boolean {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

export function validatePassword(password: string): boolean {
  return password.length >= 8 &&
         /[A-Z]/.test(password) &&
         /[a-z]/.test(password) &&
         /[0-9]/.test(password);
}

export function validateUsername(username: string): boolean {
  return username.length >= 3 &&
         username.length <= 20 &&
         /^[a-zA-Z0-9_]+$/.test(username);
}
EOF

  # 4. Insecure code (for security analysis)
  cat > insecure.js <<'EOF'
const express = require('express');
const app = express();

// VULNERABLE: SQL Injection
app.get('/users/:id', (req, res) => {
  const query = `SELECT * FROM users WHERE id = ${req.params.id}`;
  db.query(query, (err, result) => {
    res.json(result);
  });
});

// VULNERABLE: No input validation
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  const user = users.find(u => u.username === username && u.password === password);
  if (user) {
    res.json({ token: user.id });  // Weak token
  }
});

// VULNERABLE: Secrets in code
const API_KEY = 'sk_live_abc123xyz789';
const DB_PASSWORD = 'admin123';
EOF

  print_info "Created demo files in ${DEMO_DIR}"
  echo ""
}

# Create Neovim demo script
create_nvim_demo() {
  print_step "Creating Neovim Demo Script"

  cat > "${DEMO_DIR}/ai-demo.vim" <<'EOF'
" AI Features Demo Script
" Usage: nvim -S ai-demo.vim

" Configure AI integration
lua << ENDLUA
require('claude-code').setup({
  ai_integration = {
    enabled = true,
    api_url = 'http://localhost:8004',
    auto_health_check = true,

    privacy = {
      send_file_paths = false,
      redact_secrets = true,
      max_code_size = 100000,
    },

    rate_limit = {
      max_requests_per_minute = 30,
      burst_size = 10,
    },
  },
})

vim.notify('AI Integration Enabled', vim.log.levels.INFO)
ENDLUA

echo "AI Features Demo"
echo "================"
sleep 2

" Demo 1: Code Quality Analysis
echo "\n1. Analyzing code quality..."
edit bad-code.js
sleep 1

" Show the bad code
normal! gg

echo "\nAnalyzing bad-code.js for quality issues..."
sleep 2

" Run analysis (would call AI)
lua << ENDLUA
local ai = require('claude-code.ai_integration')
local available, err = ai.check_health()
if available then
  vim.notify('NexaMind API: Ready', vim.log.levels.INFO)
else
  vim.notify('NexaMind API: ' .. (err or 'unavailable'), vim.log.levels.WARN)
end
ENDLUA

sleep 3

" Demo 2: Performance Optimization
echo "\n2. Optimizing React component..."
edit SlowComponent.tsx
sleep 1
normal! gg

echo "\nIdentifying performance bottlenecks..."
sleep 3

" Demo 3: Test Generation
echo "\n3. Generating tests..."
edit validators.ts
sleep 1
normal! gg

echo "\nGenerating comprehensive test suite..."
sleep 3

" Demo 4: Security Analysis
echo "\n4. Security audit..."
edit insecure.js
sleep 1
normal! gg

echo "\nScanning for security vulnerabilities..."
sleep 3

echo "\n\n=== Demo Complete ==="
echo "\nAI Features Available:"
echo "  :ClaudeCodeAnalyze       - Code quality analysis"
echo "  :ClaudeCodeOptimize      - Performance/security optimization"
echo "  :ClaudeCodeGenTests      - Test generation"
echo "  :ClaudeCodeSuggest       - Development suggestions"
echo "\nTry running these commands manually!"

sleep 5
EOF

  chmod +x "${DEMO_DIR}/ai-demo.vim"
  print_info "Created ai-demo.vim"
}

# Create interactive demo
create_interactive_demo() {
  print_step "Creating Interactive Demo"

  cat > "${DEMO_DIR}/interactive-demo.sh" <<'EOF'
#!/usr/bin/env bash

echo "=== AI Features Interactive Demo ==="
echo ""

demo_analysis() {
  echo "Running code quality analysis on bad-code.js..."
  nvim -c "edit bad-code.js" -c "lua require('claude-code.ai_integration').analyze_code_quality(vim.fn.join(vim.fn.readfile('bad-code.js'), '\n'), 'javascript')" -c "qa"
}

demo_optimization() {
  echo "Optimizing SlowComponent.tsx for performance..."
  nvim -c "edit SlowComponent.tsx" -c "qa"
}

demo_tests() {
  echo "Generating tests for validators.ts..."
  nvim -c "edit validators.ts" -c "qa"
}

demo_security() {
  echo "Security audit of insecure.js..."
  nvim -c "edit insecure.js" -c "qa"
}

PS3="Select demo: "
options=("Code Analysis" "Performance Optimization" "Test Generation" "Security Audit" "Quit")

select opt in "${options[@]}"; do
  case $opt in
    "Code Analysis")
      demo_analysis
      ;;
    "Performance Optimization")
      demo_optimization
      ;;
    "Test Generation")
      demo_tests
      ;;
    "Security Audit")
      demo_security
      ;;
    "Quit")
      break
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
done
EOF

  chmod +x "${DEMO_DIR}/interactive-demo.sh"
  print_info "Created interactive-demo.sh"
}

# Main execution
main() {
  print_step "AI Features Demo Setup"

  echo "This demo will:"
  echo "  1. Deploy NexaMind API (Docker)"
  echo "  2. Create sample code files"
  echo "  3. Generate interactive demo scripts"
  echo ""
  print_info "Demo location: ${DEMO_DIR}"
  echo ""

  read -p "Continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Demo cancelled"
    exit 0
  fi

  check_prerequisites
  deploy_api
  create_demo_project
  create_nvim_demo
  create_interactive_demo

  print_step "Demo Setup Complete! 🎉"

  cat <<EOF
Next Steps:

1. Navigate to demo directory:
   cd ${DEMO_DIR}

2. Run automated demo:
   nvim -S ai-demo.vim

3. Or run interactive demo:
   ./interactive-demo.sh

4. Or try AI features manually:
   nvim bad-code.js

   In Neovim:
   :lua vim.print(require('claude-code.ai_integration').check_health())

   " Analyze code
   :lua require('claude-code.ai_integration').analyze_code_quality(
     vim.fn.join(vim.fn.getline(1, '$'), '\\n'),
     'javascript'
   )

Demo Files Created:
  bad-code.js         - Poor quality code for analysis
  SlowComponent.tsx   - Unoptimized React component
  validators.ts       - Functions for test generation
  insecure.js         - Security vulnerabilities demo

API Status:
  curl http://localhost:8004/health

Stop API:
  docker stop nexamind-api

Clean up:
  docker stop nexamind-api && docker rm nexamind-api
  rm -rf ${DEMO_DIR}
EOF
}

main "$@"
