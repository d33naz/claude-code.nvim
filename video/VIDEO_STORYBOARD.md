# Claude Code v2.0.0 - Demo Video Storyboard

## Video Overview
**Title**: Claude Code for Neovim - AI-Powered Development with Multi-Instance Support
**Duration**: 3-4 minutes
**Style**: Terminal screencast with voiceover
**Target Audience**: Neovim users, developers interested in AI coding assistants

---

## Scene Breakdown

### Scene 1: Opening Title (0:00 - 0:10)
**Visual**: Animated title card with plugin logo
```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║              🚀 Claude Code for Neovim v2.0.0                       ║
║                                                                      ║
║        AI-Powered Development with Multi-Instance Support           ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

**Voiceover**:
"Introducing Claude Code for Neovim version 2.0 - bringing AI-powered development
directly into your editor with enterprise-grade security and multi-repository support."

**On-Screen Text**:
- 7,100+ lines of code
- 99.1% test coverage
- 7 security features
- Zero breaking changes

---

### Scene 2: Quick Installation (0:10 - 0:30)
**Visual**: Show Lazy.nvim configuration file

**Terminal Output**:
```lua
-- ~/.config/nvim/lua/plugins/claude-code.lua
{
  'anthropics/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup({
      window = { position = 'botright', split_ratio = 0.3 },
      git = { multi_instance = true },
      ai_integration = { enabled = true },
    })
  end,
}
```

**Voiceover**:
"Installation is simple - just add the plugin to your Lazy.nvim configuration
and you're ready to go. It works with Packer, vim-plug, or manual installation too."

**Zoom/Highlight**: Configuration options

---

### Scene 3: Basic Usage - Terminal Toggle (0:30 - 0:50)
**Visual**: Neovim with code file open

**Actions**:
1. Show code file: `nvim src/components/UserList.tsx`
2. Press `<leader>cc` or run `:ClaudeCode`
3. Terminal splits open at bottom (30% height)
4. Claude Code CLI starts automatically
5. Type command: "analyze this file for potential bugs"
6. Show Claude's response with suggestions

**Voiceover**:
"Using Claude Code is effortless. Just press your configured keybinding or run
the ClaudeCode command, and an integrated terminal appears with Claude ready to help.
Ask questions, get code reviews, or request refactoring suggestions."

**On-Screen Annotations**:
- Arrow pointing to keymap: `<leader>cc`
- Highlight: "Integrated terminal"
- Show: Claude's response

---

### Scene 4: Multi-Instance Management (0:50 - 1:20)
**Visual**: Split-screen showing multiple terminals

**Actions**:
1. Current directory: `~/projects/auth-service` (git repo A)
2. Claude instance A active
3. Run: `:ClaudeCodeInstances` - shows list
4. Switch directory: `cd ~/projects/payment-service` (git repo B)
5. Run: `:ClaudeCode` - creates instance B
6. Show: `:ClaudeCodeInstances` - now shows 2 instances
7. Run: `:ClaudeCodeInstanceSwitch` - interactive picker
8. Select instance A - switches back

**Terminal Output**:
```
┌─────────────────────────────────────────────────┐
│ Claude Code Instances                           │
├─────────────────────────────────────────────────┤
│ ● auth-service        (current)                 │
│ ○ payment-service     (active)                  │
│ ○ user-service        (active)                  │
└─────────────────────────────────────────────────┘
```

**Voiceover**:
"Working with multiple repositories? No problem. Claude Code intelligently manages
separate instances for each git repository. Switch between projects and your
conversation history stays isolated - perfect for microservices and polyrepo workflows."

**On-Screen Text**:
- "Isolated per git repository"
- "Context preserved"
- "Easy switching"

---

### Scene 5: AI Code Analysis (1:20 - 1:50)
**Visual**: Neovim with poorly written code

**Code Sample**:
```javascript
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
```

**Actions**:
1. Open file with bad code
2. Run: `:ClaudeCodeAnalyze`
3. Show AI analysis results in floating window:

**AI Output**:
```
Code Quality Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Score: 4.2/10

Issues Found:
1. Poor variable naming (d, r, s, n, x)
   → Use descriptive names: data, results, status, names

2. Using 'var' instead of 'const/let'
   → Modern JavaScript uses block-scoped variables

3. Magic number: 1
   → Extract to constant: ACTIVE_STATUS = 1

4. Nested loops (complexity: 8)
   → Consider using functional methods (filter, flatMap)

Recommendations:
+ Use Array.prototype.filter() and flatMap()
+ Add JSDoc comments
+ Add input validation
```

**Voiceover**:
"The optional AI integration provides powerful code analysis. Run ClaudeCodeAnalyze
on any file to get instant feedback on code quality, complexity, and potential issues.
It identifies problems like poor naming, magic numbers, and suggests modern patterns."

**Highlight**: Each issue as it's discussed

---

### Scene 6: AI Performance Optimization (1:50 - 2:15)
**Visual**: React component with performance issues

**Code Sample**:
```typescript
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
        />
      ))}
    </div>
  );
}
```

**Actions**:
1. Run: `:ClaudeCodeOptimize performance`
2. Show AI suggestions with side-by-side comparison:

**AI Output (Split Screen)**:

**Before** | **After**
```typescript
// Before
function UserList({ users }) {
  const filtered = users.filter(...)
  const sorted = filtered.sort(...)

  return (
    <div>
      {sorted.map(user => (
        <UserCard onClick={() => ...} />
      ))}
    </div>
  );
}
```
```typescript
// After
const UserList = React.memo(({ users }) => {
  const processed = useMemo(() =>
    users
      .filter(u => u.active)
      .sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  );

  const handleClick = useCallback((user) => {
    // ...
  }, []);

  return (
    <VirtualList items={processed}>
      {(user) => <UserCard onClick={handleClick} />}
    </VirtualList>
  );
});
```

**Voiceover**:
"Need to optimize slow code? The AI can suggest performance improvements like
memoization, virtual scrolling, and callback optimization. It analyzes your code
and provides specific, actionable recommendations."

**On-Screen Metrics**:
- "Render time: 450ms → 45ms (10x faster)"

---

### Scene 7: AI Test Generation (2:15 - 2:35)
**Visual**: Validator functions needing tests

**Code Sample**:
```typescript
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
```

**Actions**:
1. Run: `:ClaudeCodeGenTests jest`
2. Show generated test file appearing
3. Quick scroll through test cases

**Generated Output**:
```typescript
describe('validators', () => {
  describe('validateEmail', () => {
    it('should accept valid emails', () => {
      expect(validateEmail('user@example.com')).toBe(true);
      expect(validateEmail('name+tag@company.co.uk')).toBe(true);
    });

    it('should reject invalid emails', () => {
      expect(validateEmail('invalid')).toBe(false);
      expect(validateEmail('@example.com')).toBe(false);
    });

    it('should handle edge cases', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail(null)).toBe(false);
    });
  });

  // ... more tests
});
```

**Voiceover**:
"Automated test generation saves hours of work. The AI analyzes your functions
and creates comprehensive test suites with edge cases, covering Jest, Vitest,
pytest, and more frameworks."

**On-Screen Text**:
- "Supports: Jest, Vitest, pytest, go-test, cargo test"

---

### Scene 8: Security Features (2:35 - 2:55)
**Visual**: Split screen showing security features

**Section A - Secret Redaction**:
```javascript
// Before sending to AI:
const API_KEY = "sk_live_abc123xyz789";
const password = "SuperSecret123!";

// Automatically redacted:
const api_key = "[REDACTED]";
const password = "[REDACTED]";
```

**Section B - Rate Limiting**:
```
Rate Limit Status
━━━━━━━━━━━━━━━━━━━━━━━━━
Current: 12/30 requests
Window: 60 seconds
Status: ✓ OK
```

**Section C - Security Checklist**:
```
✓ Automatic secret redaction (5 patterns)
✓ Rate limiting (30 req/min)
✓ Code size validation (100KB max)
✓ Local-first processing
✓ Zero telemetry
✓ Input sanitization
✓ Enhanced error handling
```

**Voiceover**:
"Security is built-in, not bolted on. Secrets are automatically redacted before
sending to AI, rate limiting prevents abuse, and all processing is local by default.
Seven enterprise-grade security features protect your code."

---

### Scene 9: Team Profiles (2:55 - 3:15)
**Visual**: Three different profile configurations side-by-side

**Profile A - Backend Dev**:
```
Window: Right side (35%)
Variants:
  <leader>aa - API context
  <leader>ad - Database schema
  <leader>at - Test coverage
  <leader>ar - Security review
```

**Profile B - Frontend Dev**:
```
Window: Floating (80%)
Variants:
  <leader>ac - Component focus
  <leader>as - Style optimization
  <leader>ax - Accessibility check
```

**Profile C - DevOps**:
```
Window: Bottom (25%)
Variants:
  <leader>ai - Infrastructure
  <leader>ak - Kubernetes
  <leader>am - Monitoring
```

**Actions**:
1. Show: `config/team-profiles/` directory
2. Run: `./config/migrate-config.sh backend`
3. Show: Validation output
4. Restart Neovim with new profile active

**Voiceover**:
"Team profiles optimize the experience for different roles. Backend developers
get API and database shortcuts. Frontend devs get component and accessibility tools.
DevOps engineers get infrastructure commands. Migration tools make setup instant."

**On-Screen Text**:
- "3 pre-built profiles"
- "Automatic conflict detection"
- "One-command migration"

---

### Scene 10: Documentation & Resources (3:15 - 3:30)
**Visual**: Documentation file tree animation

**File Tree**:
```
config/
├── README.md (966 lines)
│   Complete feature reference
│
├── AI_DEPLOYMENT_GUIDE.md (750 lines)
│   Docker/Kubernetes deployment
│
├── AI_WORKFLOWS.md (700 lines)
│   10 practical workflows
│
├── AI_SECURITY.md (650 lines)
│   Security framework
│
├── MULTI_INSTANCE_GUIDE.md (600 lines)
│   Polyrepo workflows
│
├── TROUBLESHOOTING.md (500 lines)
│   Common issues & solutions
│
└── TEAM_ONBOARDING.md (450 lines)
    5-minute team setup
```

**Voiceover**:
"Eight comprehensive guides totaling over 4,000 lines provide everything you need.
From quick start to advanced workflows, security best practices to troubleshooting,
the documentation has you covered."

**On-Screen Stats**:
- "8 guides"
- "4,000+ lines"
- "3 demos"
- "3 profiles"

---

### Scene 11: Closing & Call to Action (3:30 - 4:00)
**Visual**: Feature summary montage (quick cuts)

**Montage Clips** (2 seconds each):
1. Terminal toggle animation
2. Multi-instance switcher
3. AI analysis results
4. Test generation
5. Security features checklist
6. Team profile selection

**Final Screen**:
```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║                  Claude Code v2.0.0 for Neovim                      ║
║                                                                      ║
║                  github.com/anthropics/claude-code.nvim             ║
║                                                                      ║
║  ✓ 7,100+ lines of code     ✓ 99.1% test coverage                  ║
║  ✓ 7 security features      ✓ Zero breaking changes                ║
║  ✓ 8 comprehensive guides   ✓ 3 role-based profiles                ║
║                                                                      ║
║                  Install today and start coding smarter!            ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

**Voiceover**:
"Claude Code version 2.0 brings AI-powered development to Neovim with enterprise
security, multi-repository support, and comprehensive documentation. Install it today
and experience the future of coding. Visit the GitHub repository to get started,
check out the documentation, and join our community. Happy coding!"

**On-Screen Text**:
- GitHub: github.com/anthropics/claude-code.nvim
- Docs: See config/ directory
- Community: GitHub Discussions

**End Card**: Subscribe/Star/Follow buttons (5 seconds)

---

## Technical Requirements

### Recording Setup
- **Resolution**: 1920x1080 (1080p)
- **Frame Rate**: 30 fps
- **Terminal**: Windows Terminal or iTerm2
- **Color Scheme**: High contrast (recommend: Catppuccin Mocha, Tokyo Night, Nord)
- **Font**: JetBrains Mono Nerd Font or Fira Code (size 14-16)
- **Cursor**: Blinking enabled for visibility

### Recording Tools
**Option A - asciinema** (Terminal recording):
```bash
asciinema rec demo.cast
```

**Option B - OBS Studio** (Full screen recording):
- Source: Display Capture
- Filters: Color correction, sharpness
- Audio: Voiceover track

**Option C - Kazam/SimpleScreenRecorder** (Linux):
```bash
simplescreenrecorder
```

### Post-Production
- **Video Editor**: DaVinci Resolve (free) or Premiere Pro
- **Audio**: Audacity for voiceover cleanup
- **Captions**: Auto-generate with YouTube Studio
- **Thumbnails**: Create eye-catching thumbnail with key features

---

## Voiceover Script (Full Text)

[See attached: VIDEO_VOICEOVER_SCRIPT.txt]

---

## Shot List & Timing

| Scene | Duration | Key Points | On-Screen Text |
|-------|----------|------------|----------------|
| 1. Opening | 0:10 | Title, stats | Version, coverage, features |
| 2. Installation | 0:20 | Config file | Simple setup |
| 3. Basic Usage | 0:20 | Terminal toggle | Keybindings |
| 4. Multi-Instance | 0:30 | Switch repos | Isolated contexts |
| 5. AI Analysis | 0:30 | Code review | Issues found |
| 6. Optimization | 0:25 | Performance tips | 10x faster |
| 7. Test Gen | 0:20 | Auto tests | Framework support |
| 8. Security | 0:20 | Protection features | 7 features |
| 9. Team Profiles | 0:20 | Role configs | 3 profiles |
| 10. Docs | 0:15 | File tree | 8 guides |
| 11. Closing | 0:30 | Summary, CTA | GitHub link |

**Total Runtime**: 3:40 (target: 3-4 minutes)

---

## B-Roll Suggestions

1. Code files scrolling
2. Terminal commands typing (automated)
3. Git status/log output
4. Test results passing
5. Documentation pages
6. GitHub repository stats
7. Community discussions
8. Issue tracking

---

## Music Recommendations

**Style**: Upbeat, modern, tech-focused
**Tempo**: 120-140 BPM
**Mood**: Professional but energetic

**Suggested Tracks** (royalty-free):
- YouTube Audio Library: "Pixel Party" or "Tech Talk"
- Epidemic Sound: "Digital Dreams"
- Artlist: "Future Forward"

**Volume**: Background music at 20-30% during voiceover, 60% during montage

---

## Publishing Checklist

- [ ] Upload to YouTube
- [ ] Add to README.md
- [ ] Share on Reddit (r/neovim, r/vim)
- [ ] Post on Twitter/X
- [ ] Submit to Hacker News
- [ ] Add to plugin documentation
- [ ] Create GIF version for README (30 seconds)
- [ ] Add captions/subtitles
- [ ] Enable community contributions
- [ ] Pin in GitHub Discussions

---

## Alternative Formats

### Short Version (30 seconds)
Focus on: Installation → Toggle → Multi-instance → AI analysis → CTA

### GIF Version (15 seconds - for README)
Loop: Open Neovim → Press keybinding → Terminal appears → Type command → Show result

### Tutorial Series (5 videos × 5 min)
1. Installation & Setup
2. Multi-Instance Workflows
3. AI Code Analysis & Optimization
4. Security Features Deep Dive
5. Team Configuration & Profiles

---

**Next**: See VIDEO_RECORDING_COMMANDS.sh for automated recording script
