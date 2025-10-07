#!/usr/bin/env bash
#
# Configuration Migration Helper
# Migrates from default config to role-based team profiles
#
# Usage:
#   ./config/migrate-config.sh [backend|frontend|devops]
#
# Examples:
#   ./config/migrate-config.sh backend
#   ./config/migrate-config.sh frontend --dry-run

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_CONFIG_DIR="${HOME}/.config/nvim"
BACKUP_DIR="${NVIM_CONFIG_DIR}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Print colored message
print_info() {
  echo -e "${BLUE}ℹ️  ${1}${NC}"
}

print_success() {
  echo -e "${GREEN}✅ ${1}${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️  ${1}${NC}"
}

print_error() {
  echo -e "${RED}❌ ${1}${NC}"
}

print_header() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

# Show usage
usage() {
  cat <<EOF
Claude Code Configuration Migration Tool

Usage:
  $(basename "$0") <profile> [options]

Profiles:
  backend    Backend developer profile (API, database, microservices)
  frontend   Frontend developer profile (components, styling, UI)
  devops     DevOps/SRE profile (infrastructure, deployment)

Options:
  --dry-run      Show what would be done without making changes
  --backup-only  Create backup without migrating
  --validate     Validate profile before migration
  -h, --help     Show this help message

Examples:
  $(basename "$0") backend
  $(basename "$0") frontend --dry-run
  $(basename "$0") devops --validate

EOF
  exit 1
}

# Validate profile argument
validate_profile() {
  local profile=$1
  case $profile in
    backend|frontend|devops)
      return 0
      ;;
    *)
      print_error "Invalid profile: $profile"
      echo "Valid profiles: backend, frontend, devops"
      exit 1
      ;;
  esac
}

# Create backup of existing configuration
create_backup() {
  local config_file="${NVIM_CONFIG_DIR}/lua/plugins/claude-code.lua"

  if [[ ! -f "$config_file" ]]; then
    print_warning "No existing configuration found, skipping backup"
    return 0
  fi

  mkdir -p "$BACKUP_DIR"
  local backup_file="${BACKUP_DIR}/claude-code_${TIMESTAMP}.lua"

  cp "$config_file" "$backup_file"
  print_success "Backup created: $backup_file"
}

# Validate profile configuration
validate_profile_config() {
  local profile=$1
  local profile_file="${PLUGIN_ROOT}/config/team-profiles/${profile}.lua"

  print_info "Validating ${profile} profile..."

  if [[ ! -f "$profile_file" ]]; then
    print_error "Profile file not found: $profile_file"
    exit 1
  fi

  # Check if Lua is available
  if command -v lua &> /dev/null; then
    if lua "${PLUGIN_ROOT}/config/validate-config.lua" "$profile_file"; then
      print_success "Profile validation passed"
      return 0
    else
      print_error "Profile validation failed"
      exit 1
    fi
  else
    print_warning "Lua not found, skipping validation"
    return 0
  fi
}

# Install profile
install_profile() {
  local profile=$1
  local dry_run=$2
  local template_file="${PLUGIN_ROOT}/config/workspace-templates/lazy-nvim-${profile}.lua"
  local target_file="${NVIM_CONFIG_DIR}/lua/plugins/claude-code.lua"

  if [[ ! -f "$template_file" ]]; then
    print_error "Template file not found: $template_file"
    exit 1
  fi

  if [[ "$dry_run" == "true" ]]; then
    print_info "[DRY RUN] Would copy: $template_file → $target_file"
    return 0
  fi

  # Ensure directory exists
  mkdir -p "$(dirname "$target_file")"

  # Copy template to target
  cp "$template_file" "$target_file"
  print_success "Installed ${profile} profile to: $target_file"
}

# Show migration summary
show_summary() {
  local profile=$1
  local dry_run=$2

  print_header "MIGRATION SUMMARY"

  if [[ "$dry_run" == "true" ]]; then
    print_warning "DRY RUN MODE - No changes made"
    echo ""
  fi

  cat <<EOF
Profile: ${profile}
Target: ${NVIM_CONFIG_DIR}/lua/plugins/claude-code.lua
Backup: ${BACKUP_DIR}/claude-code_${TIMESTAMP}.lua

Next Steps:
1. Restart Neovim or run :Lazy reload claude-code.nvim
2. Verify configuration: :lua vim.print(require('claude-code').config)
3. Test keymaps: See config/TEAM_ONBOARDING.md

Profile Features:
EOF

  case $profile in
    backend)
      cat <<EOF
  - Window: Vertical split (35% width)
  - Keymaps: <leader>ai (toggle), <leader>aa (API), <leader>ad (database)
  - Variants: API, Database, Test, Review
EOF
      ;;
    frontend)
      cat <<EOF
  - Window: Floating window (90% screen)
  - Keymaps: <leader>cc (toggle), <leader>cp (component), <leader>cs (style)
  - Variants: Component, Style, Test, Perf, A11y
EOF
      ;;
    devops)
      cat <<EOF
  - Window: Bottom split (50% height)
  - Keymaps: <leader>op (toggle), <leader>oi (infra), <leader>ok (k8s)
  - Variants: Infra, K8s, Deploy, Security, Debug
EOF
      ;;
  esac

  echo ""
  print_success "Migration complete!"
}

# Main execution
main() {
  if [[ $# -eq 0 ]]; then
    usage
  fi

  local profile=""
  local dry_run=false
  local backup_only=false
  local validate_only=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      backend|frontend|devops)
        profile=$1
        shift
        ;;
      --dry-run)
        dry_run=true
        shift
        ;;
      --backup-only)
        backup_only=true
        shift
        ;;
      --validate)
        validate_only=true
        shift
        ;;
      -h|--help)
        usage
        ;;
      *)
        print_error "Unknown option: $1"
        usage
        ;;
    esac
  done

  if [[ -z "$profile" ]]; then
    print_error "Profile required"
    usage
  fi

  print_header "CLAUDE CODE CONFIGURATION MIGRATION"

  validate_profile "$profile"

  if [[ "$validate_only" == "true" ]]; then
    validate_profile_config "$profile"
    exit 0
  fi

  if [[ "$dry_run" == "true" ]]; then
    print_warning "Running in DRY RUN mode"
  fi

  # Step 1: Create backup
  print_header "STEP 1: BACKUP"
  create_backup

  if [[ "$backup_only" == "true" ]]; then
    print_success "Backup-only mode complete"
    exit 0
  fi

  # Step 2: Validate profile
  print_header "STEP 2: VALIDATION"
  validate_profile_config "$profile"

  # Step 3: Install profile
  print_header "STEP 3: INSTALLATION"
  install_profile "$profile" "$dry_run"

  # Step 4: Show summary
  show_summary "$profile" "$dry_run"
}

main "$@"
