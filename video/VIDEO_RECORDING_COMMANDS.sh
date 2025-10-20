#!/usr/bin/env bash
# Claude Code v2.0.0 - Demo Video Recording Commands
#
# This script provides all commands needed for recording the demo video.
# Use with asciinema or manual recording.
#
# Usage:
#   1. Source this file: source VIDEO_RECORDING_COMMANDS.sh
#   2. Or copy commands manually during recording
#   3. For asciinema: asciinema rec demo.cast

set -e

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Typing speed simulation (characters per second)
TYPING_SPEED=30

# Pause durations (seconds)
SHORT_PAUSE=1
MEDIUM_PAUSE=2
LONG_PAUSE=3

# Demo directory
DEMO_DIR="${HOME}/claude-code-demo-video"

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Simulate typing (for realistic demo)
type_command() {
    local cmd="$1"
    local speed="${2:-$TYPING_SPEED}"

    for (( i=0; i<${#cmd}; i++ )); do
        echo -n "${cmd:$i:1}"
        sleep $(echo "scale=3; 1/$speed" | bc)
    done
    echo ""
}

# Print section header
print_section() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    sleep $MEDIUM_PAUSE
}

# Wait with countdown
wait_countdown() {
    local seconds=$1
    local message="${2:-Pausing}"

    for ((i=seconds; i>0; i--)); do
        echo -ne "${YELLOW}${message}... ${i}s\r${NC}"
        sleep 1
    done
    echo -ne "\r\033[K"  # Clear line
}

# ==============================================================================
# SCENE 1: SETUP & OPENING
# ==============================================================================

scene_1_opening() {
    clear
    print_section "Scene 1: Claude Code v2.0.0 Demo"

    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║              🚀 Claude Code for Neovim v2.0.0                       ║
║                                                                      ║
║        AI-Powered Development with Multi-Instance Support           ║
║                                                                      ║
║  ✓ 7,100+ lines        ✓ 99.1% tests       ✓ 7 security features   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
EOF

    wait_countdown $LONG_PAUSE "Displaying title"
}

# ==============================================================================
# SCENE 2: INSTALLATION
# ==============================================================================

scene_2_installation() {
    print_section "Scene 2: Installation"

    echo -e "${CYAN}Creating demo configuration...${NC}\n"

    # Create demo config directory
    mkdir -p "${DEMO_DIR}/.config/nvim/lua/plugins"
    cd "${DEMO_DIR}"

    # Show Lazy.nvim config
    cat > .config/nvim/lua/plugins/claude-code.lua << 'EOF'
-- Claude Code Configuration
return {
  'anthropics/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup({
      window = {
        position = 'botright',
        split_ratio = 0.3,
      },
      git = {
        multi_instance = true,
        use_git_root = true,
      },
      ai_integration = {
        enabled = true,
        api_url = 'http://localhost:8004',
      },
    })
  end,
}
EOF

    # Display the config
    echo -e "${YELLOW}~/.config/nvim/lua/plugins/claude-code.lua${NC}"
    cat .config/nvim/lua/plugins/claude-code.lua

    wait_countdown $LONG_PAUSE "Showing config"
}

# ==============================================================================
# SCENE 3: BASIC USAGE
# ==============================================================================

scene_3_basic_usage() {
    print_section "Scene 3: Basic Usage - Toggle Terminal"

    # Create sample file
    mkdir -p src/components
    cat > src/components/UserList.tsx << 'EOF'
import React from 'react';

export function UserList({ users }) {
  return (
    <div className="user-list">
      {users.map(user => (
        <div key={user.id} className="user-item">
          <h3>{user.name}</h3>
          <p>{user.email}</p>
        </div>
      ))}
    </div>
  );
}
EOF

    echo -e "${CYAN}Opening file in Neovim...${NC}"
    echo -e "${YELLOW}nvim src/components/UserList.tsx${NC}\n"

    cat src/components/UserList.tsx

    echo -e "\n${CYAN}Commands to run in Neovim:${NC}"
    echo -e "  ${GREEN}:ClaudeCode${NC}     or     ${GREEN}<leader>cc${NC}"
    echo -e "\n${CYAN}Then ask Claude:${NC}"
    echo -e '  "Review this React component for best practices"'

    wait_countdown $LONG_PAUSE "Showing basic usage"
}

# ==============================================================================
# SCENE 4: MULTI-INSTANCE
# ==============================================================================

scene_4_multi_instance() {
    print_section "Scene 4: Multi-Instance Management"

    # Create multiple git repositories
    echo -e "${CYAN}Creating demo repositories...${NC}\n"

    # Repo A: auth-service
    mkdir -p repos/auth-service
    cd repos/auth-service
    git init -q
    git config user.email "demo@example.com"
    git config user.name "Demo User"
    echo "# Auth Service" > README.md
    git add . && git commit -q -m "Initial commit"
    echo -e "${GREEN}✓ Created: auth-service${NC}"
    cd ../..

    # Repo B: payment-service
    mkdir -p repos/payment-service
    cd repos/payment-service
    git init -q
    git config user.email "demo@example.com"
    git config user.name "Demo User"
    echo "# Payment Service" > README.md
    git add . && git commit -q -m "Initial commit"
    echo -e "${GREEN}✓ Created: payment-service${NC}"
    cd ../..

    # Repo C: user-service
    mkdir -p repos/user-service
    cd repos/user-service
    git init -q
    git config user.email "demo@example.com"
    git config user.name "Demo User"
    echo "# User Service" > README.md
    git add . && git commit -q -m "Initial commit"
    echo -e "${GREEN}✓ Created: user-service${NC}"
    cd ../..

    echo -e "\n${CYAN}Neovim commands to demonstrate:${NC}"
    echo -e "  ${YELLOW}cd repos/auth-service${NC}"
    echo -e "  ${GREEN}:ClaudeCode${NC}                    ${BLUE}# Creates instance A${NC}"
    echo -e ""
    echo -e "  ${YELLOW}cd ../payment-service${NC}"
    echo -e "  ${GREEN}:ClaudeCode${NC}                    ${BLUE}# Creates instance B${NC}"
    echo -e ""
    echo -e "  ${GREEN}:ClaudeCodeInstances${NC}           ${BLUE}# List all instances${NC}"
    echo -e ""
    cat << 'EOF'

┌─────────────────────────────────────────────────┐
│ Claude Code Instances                           │
├─────────────────────────────────────────────────┤
│ ● auth-service        (current)                 │
│ ○ payment-service     (active)                  │
│ ○ user-service        (active)                  │
└─────────────────────────────────────────────────┘
EOF

    echo -e "\n  ${GREEN}:ClaudeCodeInstanceSwitch${NC}     ${BLUE}# Interactive picker${NC}"

    wait_countdown $LONG_PAUSE "Showing multi-instance"
}

# ==============================================================================
# SCENE 5: AI CODE ANALYSIS
# ==============================================================================

scene_5_ai_analysis() {
    print_section "Scene 5: AI Code Analysis"

    # Create bad code sample
    cd "${DEMO_DIR}"
    cat > bad-code.js << 'EOF'
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

function calc(a, b, t) {
  if (t === 1) return a + b * 0.1;
  if (t === 2) return a + b * 0.2;
  return a + b;
}
EOF

    echo -e "${YELLOW}bad-code.js${NC}"
    cat bad-code.js

    echo -e "\n${CYAN}Neovim command:${NC}"
    echo -e "  ${GREEN}:ClaudeCodeAnalyze${NC}"

    echo -e "\n${CYAN}Expected AI Output:${NC}"
    cat << 'EOF'

Code Quality Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Score: 4.2/10

Issues Found:

1. Poor variable naming (d, r, s, n, x)
   → Use descriptive names: data, results, status, names

2. Using 'var' instead of 'const/let'
   → Modern JavaScript uses block-scoped variables

3. Magic numbers: 1, 0.1, 0.2
   → Extract to constants: ACTIVE_STATUS = 1

4. Nested loops (cyclomatic complexity: 8)
   → Consider using functional methods (filter, flatMap)

5. Missing input validation
   → Add null/undefined checks

Recommendations:
+ Use Array.prototype.filter() and flatMap()
+ Add JSDoc comments
+ Add error handling for edge cases
+ Extract magic numbers to named constants
EOF

    wait_countdown $LONG_PAUSE "Showing AI analysis"
}

# ==============================================================================
# SCENE 6: AI PERFORMANCE OPTIMIZATION
# ==============================================================================

scene_6_optimization() {
    print_section "Scene 6: Performance Optimization"

    cat > slow-component.tsx << 'EOF'
import React from 'react';

function DataTable({ items }) {
  const filtered = items.filter(i => i.active);
  const sorted = filtered.sort((a, b) => a.name.localeCompare(b.name));

  return (
    <div>
      {sorted.map(item => (
        <Row
          key={item.id}
          data={item}
          onClick={() => handleClick(item)}
          onDelete={() => handleDelete(item.id)}
        />
      ))}
    </div>
  );
}

function handleClick(item) {
  console.log('Clicked:', item);
  const data = JSON.parse(JSON.stringify(item));
  processItem(data);
}
EOF

    echo -e "${YELLOW}slow-component.tsx${NC}"
    cat slow-component.tsx

    echo -e "\n${CYAN}Neovim command:${NC}"
    echo -e "  ${GREEN}:ClaudeCodeOptimize performance${NC}"

    echo -e "\n${CYAN}AI Suggestions (optimized version):${NC}"
    cat << 'EOF'

const DataTable = React.memo(function DataTable({ items }) {
  // Memoize expensive calculations
  const processed = useMemo(() => {
    return items
      .filter(i => i.active)
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [items]);

  // Memoize callbacks
  const handleClick = useCallback((item) => {
    console.log('Clicked:', item);
    processItem(item);  // No need for deep clone
  }, []);

  const handleDelete = useCallback((id) => {
    deleteItem(id);
  }, []);

  return (
    <VirtualList items={processed}>
      {(item) => (
        <Row
          key={item.id}
          data={item}
          onClick={handleClick}
          onDelete={handleDelete}
        />
      )}
    </VirtualList>
  );
});

Improvements:
✓ React.memo prevents unnecessary re-renders
✓ useMemo caches filtered/sorted data
✓ useCallback stabilizes event handlers
✓ VirtualList for large datasets
✓ Removed unnecessary JSON deep clone

Performance gain: ~10x faster for 1000+ items
EOF

    wait_countdown $LONG_PAUSE "Showing optimization"
}

# ==============================================================================
# SCENE 7: TEST GENERATION
# ==============================================================================

scene_7_test_generation() {
    print_section "Scene 7: Test Generation"

    cat > validators.ts << 'EOF'
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

    echo -e "${YELLOW}validators.ts${NC}"
    cat validators.ts

    echo -e "\n${CYAN}Neovim command:${NC}"
    echo -e "  ${GREEN}:ClaudeCodeGenTests jest${NC}"

    echo -e "\n${CYAN}Generated: validators.test.ts${NC}"
    cat << 'EOF'

import { validateEmail, validatePassword, validateUsername } from './validators';

describe('validators', () => {
  describe('validateEmail', () => {
    it('should accept valid emails', () => {
      expect(validateEmail('user@example.com')).toBe(true);
      expect(validateEmail('name+tag@company.co.uk')).toBe(true);
      expect(validateEmail('test_user@sub.domain.org')).toBe(true);
    });

    it('should reject invalid emails', () => {
      expect(validateEmail('invalid')).toBe(false);
      expect(validateEmail('@example.com')).toBe(false);
      expect(validateEmail('user@')).toBe(false);
      expect(validateEmail('user @example.com')).toBe(false);
    });

    it('should handle edge cases', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail(' ')).toBe(false);
    });
  });

  describe('validatePassword', () => {
    it('should accept strong passwords', () => {
      expect(validatePassword('Password1')).toBe(true);
      expect(validatePassword('Str0ng!Pass')).toBe(true);
    });

    it('should reject weak passwords', () => {
      expect(validatePassword('short')).toBe(false);
      expect(validatePassword('nouppercase1')).toBe(false);
      expect(validatePassword('NOLOWERCASE1')).toBe(false);
      expect(validatePassword('NoNumbers')).toBe(false);
    });
  });

  describe('validateUsername', () => {
    it('should accept valid usernames', () => {
      expect(validateUsername('john_doe')).toBe(true);
      expect(validateUsername('user123')).toBe(true);
    });

    it('should reject invalid usernames', () => {
      expect(validateUsername('ab')).toBe(false);  // Too short
      expect(validateUsername('a'.repeat(21))).toBe(false);  // Too long
      expect(validateUsername('user-name')).toBe(false);  // Invalid char
      expect(validateUsername('user name')).toBe(false);  // Space
    });
  });
});

Test Coverage: 100%
Edge cases: ✓ Covered
Framework: Jest
EOF

    wait_countdown $LONG_PAUSE "Showing test generation"
}

# ==============================================================================
# SCENE 8: SECURITY FEATURES
# ==============================================================================

scene_8_security() {
    print_section "Scene 8: Security Features"

    echo -e "${CYAN}Built-in Security Protection:${NC}\n"

    echo -e "${YELLOW}1. Automatic Secret Redaction${NC}"
    cat << 'EOF'

Before sending to AI:
  const API_KEY = "sk_live_abc123xyz789";
  const password = "SuperSecret123!";
  const token = "ghp_1234567890abcdef";

After automatic redaction:
  const api_key = "[REDACTED]";
  const password = "[REDACTED]";
  const token = "[REDACTED]";

Patterns detected: API keys, passwords, tokens, secrets, credentials
EOF

    sleep $MEDIUM_PAUSE

    echo -e "\n${YELLOW}2. Rate Limiting${NC}"
    cat << 'EOF'

┌─────────────────────────────────┐
│ Rate Limit Status               │
├─────────────────────────────────┤
│ Current:  12/30 requests        │
│ Window:   60 seconds            │
│ Burst:    10 requests allowed   │
│ Status:   ✓ OK                  │
└─────────────────────────────────┘

Configurable per environment:
  ai_integration = {
    rate_limit = {
      max_requests_per_minute = 60,
      burst_size = 20,
    },
  }
EOF

    sleep $MEDIUM_PAUSE

    echo -e "\n${YELLOW}3. Complete Security Checklist${NC}"
    cat << 'EOF'

✓ Automatic secret redaction (5 patterns)
✓ Rate limiting (30 req/min default)
✓ Code size validation (100KB max)
✓ Local-first processing
✓ Zero telemetry
✓ Input sanitization
✓ Enhanced error handling

All features enabled by default!
EOF

    wait_countdown $LONG_PAUSE "Showing security features"
}

# ==============================================================================
# SCENE 9: TEAM PROFILES
# ==============================================================================

scene_9_team_profiles() {
    print_section "Scene 9: Team Profiles"

    echo -e "${CYAN}Pre-built configurations for different roles:${NC}\n"

    echo -e "${YELLOW}Backend Developer Profile${NC}"
    cat << 'EOF'
Window: Right side (35%)
Variants:
  <leader>aa - API context & documentation
  <leader>ad - Database schema analysis
  <leader>at - Test coverage review
  <leader>ar - Security audit
EOF

    sleep $MEDIUM_PAUSE

    echo -e "\n${YELLOW}Frontend Developer Profile${NC}"
    cat << 'EOF'
Window: Floating (80% × 80%)
Variants:
  <leader>ac - Component optimization
  <leader>as - Style/CSS review
  <leader>ax - Accessibility check
  <leader>ap - Performance analysis
EOF

    sleep $MEDIUM_PAUSE

    echo -e "\n${YELLOW}DevOps Engineer Profile${NC}"
    cat << 'EOF'
Window: Bottom (25%)
Variants:
  <leader>ai - Infrastructure review
  <leader>ak - Kubernetes config
  <leader>am - Monitoring setup
  <leader>ad - Docker optimization
EOF

    echo -e "\n${CYAN}Migration command:${NC}"
    echo -e "  ${GREEN}./config/migrate-config.sh backend${NC}"
    echo -e "\n${CYAN}Output:${NC}"
    cat << 'EOF'

✓ Validated backend profile
✓ Checked for keymap conflicts
✓ Created backup: ~/.config/nvim.backup-20250107
✓ Applied backend configuration
✓ Migration complete!

Restart Neovim to activate new profile.
EOF

    wait_countdown $LONG_PAUSE "Showing team profiles"
}

# ==============================================================================
# SCENE 10: DOCUMENTATION
# ==============================================================================

scene_10_documentation() {
    print_section "Scene 10: Comprehensive Documentation"

    cat << 'EOF'
📚 8 Comprehensive Guides (4,000+ lines)

config/
├── README.md (966 lines)
│   ✓ Complete feature reference
│   ✓ Installation for 4 package managers
│   ✓ 30+ documented commands
│   ✓ Configuration examples
│
├── AI_DEPLOYMENT_GUIDE.md (750 lines)
│   ✓ Docker deployment
│   ✓ Kubernetes configuration
│   ✓ Production setup
│   ✓ Monitoring & logging
│
├── AI_WORKFLOWS.md (700 lines)
│   ✓ 10 practical workflows
│   ✓ Code review process
│   ✓ Performance optimization
│   ✓ Test generation strategies
│
├── AI_SECURITY.md (650 lines)
│   ✓ Threat model
│   ✓ Security architecture
│   ✓ Best practices
│   ✓ Compliance matrix
│
├── MULTI_INSTANCE_GUIDE.md (600 lines)
│   ✓ Polyrepo workflows
│   ✓ Instance management
│   ✓ Advanced configuration
│   ✓ Troubleshooting
│
├── TROUBLESHOOTING.md (500 lines)
│   ✓ Common issues
│   ✓ Error solutions
│   ✓ FAQ
│   ✓ Debug tips
│
├── TEAM_ONBOARDING.md (450 lines)
│   ✓ 5-minute setup
│   ✓ Role-based guides
│   ✓ Best practices
│   ✓ Team standards
│
└── config/README.md (350 lines)
    ✓ Configuration reference
    ✓ Option descriptions
    ✓ Examples
    ✓ Migration guide
EOF

    wait_countdown $LONG_PAUSE "Showing documentation"
}

# ==============================================================================
# SCENE 11: CLOSING
# ==============================================================================

scene_11_closing() {
    print_section "Scene 11: Summary & Call to Action"

    echo -e "${CYAN}Key Features Recap:${NC}\n"
    cat << 'EOF'
✓ In-Editor Terminal Integration
✓ Multi-Instance Management (per git repo)
✓ Smart File Refresh
✓ AI Code Quality Analysis
✓ AI Performance Optimization
✓ AI Test Generation
✓ AI Security Hardening
✓ Automatic Secret Redaction
✓ Rate Limiting & Size Validation
✓ Team Collaboration Profiles
✓ 99.1% Test Coverage
✓ Zero Breaking Changes
EOF

    sleep $MEDIUM_PAUSE

    clear
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║                  Claude Code v2.0.0 for Neovim                      ║
║                                                                      ║
║          github.com/anthropics/claude-code.nvim                     ║
║                                                                      ║
║  ✓ 7,100+ lines of code     ✓ 99.1% test coverage                  ║
║  ✓ 7 security features      ✓ Zero breaking changes                ║
║  ✓ 8 comprehensive guides   ✓ 3 role-based profiles                ║
║                                                                      ║
║              Install today and start coding smarter!                ║
║                                                                      ║
║  Installation:                                                      ║
║    {                                                                ║
║      'anthropics/claude-code.nvim',                                 ║
║      dependencies = { 'nvim-lua/plenary.nvim' },                    ║
║      config = function()                                            ║
║        require('claude-code').setup()                               ║
║      end,                                                           ║
║    }                                                                ║
║                                                                      ║
║  Resources:                                                         ║
║    • Documentation: See config/ directory                           ║
║    • Community: GitHub Discussions                                  ║
║    • Issues: GitHub Issues                                          ║
║    • Support: README.md troubleshooting section                     ║
║                                                                      ║
║                      Happy coding with Claude! 🚀                   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝

EOF

    wait_countdown $LONG_PAUSE "End card"
}

# ==============================================================================
# MAIN RECORDING SEQUENCE
# ==============================================================================

main() {
    echo -e "${GREEN}Claude Code v2.0.0 - Video Recording Script${NC}"
    echo -e "${CYAN}This script will generate all content needed for the demo video.${NC}\n"

    # Create demo directory
    mkdir -p "${DEMO_DIR}"
    cd "${DEMO_DIR}"

    echo -e "Demo directory: ${YELLOW}${DEMO_DIR}${NC}\n"

    read -p "Press Enter to start recording sequence..."

    # Run all scenes in sequence
    scene_1_opening
    scene_2_installation
    scene_3_basic_usage
    scene_4_multi_instance
    scene_5_ai_analysis
    scene_6_optimization
    scene_7_test_generation
    scene_8_security
    scene_9_team_profiles
    scene_10_documentation
    scene_11_closing

    echo -e "\n${GREEN}✓ Recording sequence complete!${NC}"
    echo -e "\n${CYAN}Next steps:${NC}"
    echo -e "  1. Review generated files in: ${YELLOW}${DEMO_DIR}${NC}"
    echo -e "  2. Record video using OBS or asciinema"
    echo -e "  3. Add voiceover using script in VIDEO_VOICEOVER_SCRIPT.txt"
    echo -e "  4. Edit in DaVinci Resolve or Premiere Pro"
    echo -e "  5. Upload to YouTube and social media\n"
}

# ==============================================================================
# ASCIINEMA RECORDING COMMANDS
# ==============================================================================

# For automated asciinema recording, use:
# asciinema rec demo.cast --command "bash VIDEO_RECORDING_COMMANDS.sh"

# ==============================================================================
# EXECUTE
# ==============================================================================

# If script is sourced, don't run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
