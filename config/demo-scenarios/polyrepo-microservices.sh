#!/usr/bin/env bash
#
# Demo: Multi-Instance Mode for Polyrepo Microservices
#
# This demo creates a realistic polyrepo microservices environment
# and demonstrates multi-instance Claude Code workflows.
#
# Usage:
#   ./config/demo-scenarios/polyrepo-microservices.sh

set -euo pipefail

DEMO_DIR="${HOME}/claude-code-demo-polyrepo"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Create demo environment
create_demo_repos() {
  print_step "STEP 1: Creating Microservices Repository Structure"

  mkdir -p "$DEMO_DIR"
  cd "$DEMO_DIR"

  # Create microservices
  repos=(
    "auth-service"
    "payment-service"
    "notification-service"
    "user-service"
    "inventory-service"
  )

  for repo in "${repos[@]}"; do
    mkdir -p "$repo"
    cd "$repo"

    # Initialize git
    git init
    git config user.email "demo@example.com"
    git config user.name "Demo User"

    # Create realistic file structure
    mkdir -p src/{api,models,services,tests}
    mkdir -p docs

    # Create sample files
    cat > README.md <<EOF
# ${repo}

Microservice for ${repo%-service} functionality.

## Architecture

- Language: Node.js / TypeScript
- Framework: Express
- Database: PostgreSQL
- API: REST

## Getting Started

\`\`\`bash
npm install
npm run dev
\`\`\`
EOF

    cat > src/api/routes.ts <<EOF
// API routes for ${repo}
import { Router } from 'express';

const router = Router();

router.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: '${repo}' });
});

export default router;
EOF

    cat > src/models/index.ts <<EOF
// Database models for ${repo}
export interface Model {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}
EOF

    cat > package.json <<EOF
{
  "name": "${repo}",
  "version": "1.0.0",
  "description": "${repo} microservice",
  "main": "src/index.ts",
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "test": "jest",
    "build": "tsc"
  }
}
EOF

    # Commit initial structure
    git add .
    git commit -m "Initial commit: ${repo} structure"

    print_info "Created ${repo}"
    cd "$DEMO_DIR"
  done

  # Create infrastructure repo
  mkdir -p "infra-terraform"
  cd "infra-terraform"
  git init
  git config user.email "demo@example.com"
  git config user.name "Demo User"

  mkdir -p {modules,environments/{dev,staging,prod}}

  cat > main.tf <<EOF
# Main Terraform configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
EOF

  git add .
  git commit -m "Initial commit: Infrastructure setup"
  print_info "Created infra-terraform"

  cd "$DEMO_DIR"
}

# Show demo structure
show_structure() {
  print_step "STEP 2: Repository Structure Created"

  cat <<EOF
${DEMO_DIR}/
├── auth-service/           (Node.js/TypeScript)
├── payment-service/        (Node.js/TypeScript)
├── notification-service/   (Node.js/TypeScript)
├── user-service/           (Node.js/TypeScript)
├── inventory-service/      (Node.js/TypeScript)
└── infra-terraform/        (Terraform/IaC)

Each repository is a separate git repository with its own history.
EOF
  echo ""
}

# Generate Neovim test script
create_nvim_demo() {
  print_step "STEP 3: Creating Neovim Demo Script"

  cat > "${DEMO_DIR}/nvim-demo.vim" <<'EOF'
" Multi-Instance Demo Script
" Usage: nvim -S nvim-demo.vim

" Ensure Claude Code is installed
lua << ENDLUA
local ok, claude_code = pcall(require, 'claude-code')
if not ok then
  vim.notify('Claude Code not installed!', vim.log.levels.ERROR)
  vim.cmd('qa!')
end

-- Setup with backend profile (multi-instance enabled)
claude_code.setup({
  git = {
    use_git_root = true,
    multi_instance = true,
  },
  window = {
    position = 'right',
    split_ratio = 0.35,
  },
})
ENDLUA

" Demo workflow
echo "Multi-Instance Demo Starting..."
sleep 2

" Instance 1: Auth Service
cd auth-service
echo "Changing to auth-service..."
sleep 1
ClaudeCode
echo "Created instance 1: auth-service"
sleep 2
quit

" Instance 2: Payment Service
cd ../payment-service
echo "Changing to payment-service..."
sleep 1
ClaudeCode
echo "Created instance 2: payment-service"
sleep 2
quit

" Instance 3: Infrastructure
cd ../infra-terraform
echo "Changing to infra-terraform..."
sleep 1
ClaudeCode
echo "Created instance 3: infra-terraform"
sleep 2
quit

" Show all instances
echo "Listing all instances..."
sleep 1
ClaudeCodeInstances

sleep 2

" Show statistics
echo "Instance statistics..."
sleep 1
ClaudeCodeInstanceStats

sleep 3

" Interactive switcher demo
echo "Opening instance switcher..."
sleep 1
ClaudeCodeInstanceSwitch

sleep 5

" Final message
echo "Demo complete! You now have 3 isolated Claude Code instances."
echo "Try: :ClaudeCodeInstances to see all instances"
echo "Try: :ClaudeCodeInstanceSwitch to switch between them"
EOF

  print_info "Created nvim-demo.vim"
}

# Create interactive demo
create_interactive_demo() {
  print_step "STEP 4: Creating Interactive Demo Commands"

  cat > "${DEMO_DIR}/demo-commands.sh" <<'EOF'
#!/usr/bin/env bash
#
# Interactive Multi-Instance Demo Commands
# Source this file: source demo-commands.sh

DEMO_ROOT="$(pwd)"

# Navigate to services quickly
alias goto-auth="cd ${DEMO_ROOT}/auth-service && pwd"
alias goto-payment="cd ${DEMO_ROOT}/payment-service && pwd"
alias goto-notif="cd ${DEMO_ROOT}/notification-service && pwd"
alias goto-user="cd ${DEMO_ROOT}/user-service && pwd"
alias goto-inventory="cd ${DEMO_ROOT}/inventory-service && pwd"
alias goto-infra="cd ${DEMO_ROOT}/infra-terraform && pwd"

# Demo workflow
demo-workflow() {
  echo "Multi-Instance Workflow Demo"
  echo "============================="
  echo ""
  echo "1. Navigate to auth-service: goto-auth"
  echo "2. Open Neovim and run: :ClaudeCode"
  echo "3. Navigate to payment-service: goto-payment"
  echo "4. Open Neovim and run: :ClaudeCode"
  echo "5. Check instances: :ClaudeCodeInstances"
  echo "6. Switch instances: :ClaudeCodeInstanceSwitch"
  echo ""
  echo "Commands available:"
  echo "  goto-auth, goto-payment, goto-notif, goto-user, goto-inventory, goto-infra"
}

echo "Demo environment loaded!"
echo "Run 'demo-workflow' for instructions"
EOF

  chmod +x "${DEMO_DIR}/demo-commands.sh"
  print_info "Created demo-commands.sh"
}

# Main execution
main() {
  print_step "Multi-Instance Polyrepo Microservices Demo"

  print_info "This demo will create a realistic polyrepo environment"
  print_info "with 5 microservices and 1 infrastructure repository."
  echo ""
  print_info "Demo location: ${DEMO_DIR}"
  echo ""

  read -p "Continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Demo cancelled"
    exit 0
  fi

  # Create demo environment
  create_demo_repos
  show_structure
  create_nvim_demo
  create_interactive_demo

  print_step "Demo Setup Complete! 🎉"

  cat <<EOF
Next Steps:

1. Navigate to demo directory:
   cd ${DEMO_DIR}

2. Option A - Interactive Demo:
   source demo-commands.sh
   demo-workflow

3. Option B - Automated Neovim Demo:
   nvim -S nvim-demo.vim

4. Option C - Manual Testing:
   cd auth-service
   nvim
   :ClaudeCode

   cd ../payment-service
   nvim
   :ClaudeCode

   :ClaudeCodeInstances      # List instances
   :ClaudeCodeInstanceSwitch # Switch between instances

Repository Structure:
  ${DEMO_DIR}/
  ├── auth-service/
  ├── payment-service/
  ├── notification-service/
  ├── user-service/
  ├── inventory-service/
  └── infra-terraform/

Each repo is isolated with its own Claude Code instance!

To clean up:
  rm -rf ${DEMO_DIR}
EOF
}

main "$@"
