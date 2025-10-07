#!/usr/bin/env bash
#
# Demo: Multi-Instance Mode for Monorepo with Packages
#
# This demo creates a realistic monorepo environment with multiple packages
# and demonstrates both shared and isolated instance modes.
#
# Usage:
#   ./config/demo-scenarios/monorepo-packages.sh

set -euo pipefail

DEMO_DIR="${HOME}/claude-code-demo-monorepo"
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

# Create monorepo structure
create_monorepo() {
  print_step "STEP 1: Creating Monorepo Structure"

  mkdir -p "$DEMO_DIR"
  cd "$DEMO_DIR"

  # Initialize git at root
  git init
  git config user.email "demo@example.com"
  git config user.name "Demo User"

  # Create package structure
  mkdir -p packages/{ui-components,design-system,utils,api-client,documentation}
  mkdir -p apps/{web-app,mobile-app,admin-dashboard}

  # Root package.json
  cat > package.json <<EOF
{
  "name": "acme-monorepo",
  "version": "1.0.0",
  "private": true,
  "workspaces": [
    "packages/*",
    "apps/*"
  ],
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "test": "turbo run test"
  }
}
EOF

  # Create ui-components package
  cd packages/ui-components
  cat > package.json <<EOF
{
  "name": "@acme/ui-components",
  "version": "1.0.0",
  "main": "dist/index.js",
  "dependencies": {
    "react": "^18.0.0"
  }
}
EOF

  mkdir -p src/components
  cat > src/components/Button.tsx <<EOF
import React from 'react';

export interface ButtonProps {
  label: string;
  onClick: () => void;
}

export const Button: React.FC<ButtonProps> = ({ label, onClick }) => {
  return <button onClick={onClick}>{label}</button>;
};
EOF

  cat > README.md <<EOF
# @acme/ui-components

Shared UI component library for the Acme ecosystem.

## Components

- Button
- Input
- Modal
- Card
EOF

  # Create design-system package
  cd ../../packages/design-system
  cat > package.json <<EOF
{
  "name": "@acme/design-system",
  "version": "1.0.0",
  "main": "dist/index.js"
}
EOF

  mkdir -p src/{tokens,themes}
  cat > src/tokens/colors.ts <<EOF
export const colors = {
  primary: '#007bff',
  secondary: '#6c757d',
  success: '#28a745',
  danger: '#dc3545',
};
EOF

  cat > README.md <<EOF
# @acme/design-system

Design tokens, themes, and guidelines.
EOF

  # Create utils package
  cd ../../packages/utils
  cat > package.json <<EOF
{
  "name": "@acme/utils",
  "version": "1.0.0",
  "main": "dist/index.js"
}
EOF

  mkdir -p src
  cat > src/string-utils.ts <<EOF
export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1);
}
EOF

  cat > README.md <<EOF
# @acme/utils

Shared utility functions.
EOF

  # Create web-app
  cd ../../apps/web-app
  cat > package.json <<EOF
{
  "name": "web-app",
  "version": "1.0.0",
  "dependencies": {
    "@acme/ui-components": "*",
    "@acme/design-system": "*",
    "@acme/utils": "*",
    "react": "^18.0.0",
    "next": "^13.0.0"
  }
}
EOF

  mkdir -p src/pages
  cat > src/pages/index.tsx <<EOF
import { Button } from '@acme/ui-components';

export default function Home() {
  return <Button label="Hello World" onClick={() => alert('Clicked!')} />;
}
EOF

  cat > README.md <<EOF
# Web App

Main customer-facing web application.
EOF

  # Commit structure
  cd "$DEMO_DIR"
  git add .
  git commit -m "Initial monorepo structure"

  print_info "Created monorepo with workspaces"
}

# Show structure
show_structure() {
  print_step "STEP 2: Monorepo Structure Created"

  cat <<EOF
${DEMO_DIR}/
├── packages/
│   ├── ui-components/      (React components)
│   ├── design-system/      (Design tokens)
│   ├── utils/              (Shared utilities)
│   ├── api-client/         (API client)
│   └── documentation/      (Docs)
└── apps/
    ├── web-app/            (Next.js app)
    ├── mobile-app/         (React Native)
    └── admin-dashboard/    (Admin UI)

Single git repository at root with workspace packages.
EOF
  echo ""
}

# Create demo configs
create_demo_configs() {
  print_step "STEP 3: Creating Demo Configurations"

  # Shared instance config
  cat > "${DEMO_DIR}/.nvim-shared.lua" <<'EOF'
-- Shared Instance Configuration
-- All packages share one Claude instance at monorepo root

require('claude-code').setup({
  git = {
    use_git_root = true,      -- Use monorepo root
    multi_instance = false,   -- Single instance for all packages
  },
  window = {
    position = 'float',
    float = {
      width = '90%',
      height = '90%',
    },
  },
  command_variants = {
    Component = '--context component',
    Package = '--context workspace-package',
  },
})

vim.notify('Shared Instance Mode: One Claude for entire monorepo', vim.log.levels.INFO)
EOF

  # Per-package instance config
  cat > "${DEMO_DIR}/.nvim-per-package.lua" <<'EOF'
-- Per-Package Instance Configuration
-- Each package gets its own Claude instance

require('claude-code').setup({
  git = {
    use_git_root = false,     -- Use current directory instead
    multi_instance = true,    -- Separate instance per package
  },
  window = {
    position = 'float',
    float = {
      width = '90%',
      height = '90%',
    },
  },
  command_variants = {
    Component = '--context component',
    Package = '--context workspace-package',
  },
})

vim.notify('Per-Package Mode: Separate Claude instance per package', vim.log.levels.INFO)
EOF

  print_info "Created configuration files"
}

# Create demo script
create_nvim_demo() {
  print_step "STEP 4: Creating Demo Scripts"

  cat > "${DEMO_DIR}/demo-shared.vim" <<'EOF'
" Shared Instance Demo
" All packages share one Claude instance

source .nvim-shared.lua

" Navigate to different packages
echo "Shared Instance Demo - All packages use same Claude instance"
sleep 2

cd packages/ui-components
echo "In ui-components..."
sleep 1
ClaudeCode
quit

cd ../../packages/design-system
echo "In design-system..."
sleep 1
ClaudeCode
echo "Same instance as ui-components!"
quit

ClaudeCodeInstanceStats
sleep 3

echo "Shared mode: 1 instance for entire monorepo"
EOF

  cat > "${DEMO_DIR}/demo-per-package.vim" <<'EOF'
" Per-Package Instance Demo
" Each package gets its own Claude instance

source .nvim-per-package.lua

echo "Per-Package Demo - Each package gets separate instance"
sleep 2

cd packages/ui-components
echo "Creating instance for ui-components..."
sleep 1
ClaudeCode
quit

cd ../../packages/design-system
echo "Creating instance for design-system..."
sleep 1
ClaudeCode
quit

cd ../../packages/utils
echo "Creating instance for utils..."
sleep 1
ClaudeCode
quit

ClaudeCodeInstances
sleep 2

ClaudeCodeInstanceStats
sleep 3

echo "Per-package mode: 3 separate instances"
EOF

  chmod +x "${DEMO_DIR}/demo-"*.vim
  print_info "Created demo scripts"
}

# Main execution
main() {
  print_step "Multi-Instance Monorepo Demo"

  print_info "This demo creates a realistic monorepo with packages"
  print_info "and shows both shared and per-package instance modes."
  echo ""
  print_info "Demo location: ${DEMO_DIR}"
  echo ""

  read -p "Continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Demo cancelled"
    exit 0
  fi

  create_monorepo
  show_structure
  create_demo_configs
  create_nvim_demo

  print_step "Demo Setup Complete! 🎉"

  cat <<EOF
Next Steps:

1. Navigate to demo directory:
   cd ${DEMO_DIR}

2. Try Shared Instance Mode (recommended for monorepos):
   nvim -S demo-shared.vim

   OR manually:
   nvim
   :source .nvim-shared.lua
   :cd packages/ui-components
   :ClaudeCode
   :cd ../../packages/design-system
   :ClaudeCode  # Same instance!

3. Try Per-Package Instance Mode:
   nvim -S demo-per-package.vim

   OR manually:
   nvim
   :source .nvim-per-package.lua
   :cd packages/ui-components
   :ClaudeCode
   :cd ../../packages/design-system
   :ClaudeCode  # Different instance!

Configuration Files:
  .nvim-shared.lua       - Shared instance config
  .nvim-per-package.lua  - Per-package instance config

Choose the mode that fits your workflow!

To clean up:
  rm -rf ${DEMO_DIR}
EOF
}

main "$@"
