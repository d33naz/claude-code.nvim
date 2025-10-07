# AI-Powered Workflows Guide

## Overview

This guide demonstrates practical AI-powered development workflows using claude-code.nvim with NexaMind integration.

---

## Quick Start Workflows

### 1. Code Quality Analysis

**Scenario:** Review code before committing

```vim
" Open file with questionable code
:e src/components/UserList.tsx

" Analyze entire buffer
:ClaudeCodeAnalyze

" Or analyze selection (visual mode)
V}:ClaudeCodeAnalyze
```

**What it analyzes:**
- Code complexity and readability
- Potential bugs and edge cases
- Performance bottlenecks
- Security vulnerabilities
- Best practice violations

**Example output:**
```
Code Quality Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Score: 7.5/10

Issues Found:
1. High complexity in getUserData() (cyclomatic: 15)
   → Recommend extracting validation logic

2. Missing error handling for API calls (lines 42-56)
   → Add try-catch blocks

3. Inefficient array operations (line 78)
   → Use Set for O(1) lookups instead of includes()

Recommendations:
+ Add TypeScript strict null checks
+ Extract reusable validation functions
+ Consider memoization for expensive calculations
```

---

### 2. Performance Optimization

**Scenario:** Slow React component

```vim
" Open slow component
:e src/components/DataTable.tsx

" Request performance optimization
:ClaudeCodeOptimize performance
```

**AI will suggest:**
- Memoization opportunities (`useMemo`, `useCallback`)
- Virtual scrolling for large lists
- Debouncing/throttling for event handlers
- Bundle size reductions
- Lazy loading strategies

**Before:**
```typescript
function DataTable({ items }) {
  const filtered = items.filter(i => i.active);
  const sorted = filtered.sort((a, b) => a.name.localeCompare(b.name));

  return (
    <div>
      {sorted.map(item => (
        <Row key={item.id} data={item} onClick={() => handleClick(item)} />
      ))}
    </div>
  );
}
```

**After AI optimization:**
```typescript
const DataTable = React.memo(function DataTable({ items }) {
  const processed = useMemo(() => {
    return items
      .filter(i => i.active)
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [items]);

  const handleClick = useCallback((item) => {
    // Memoized callback
  }, []);

  return (
    <VirtualList items={processed}>
      {(item) => <Row key={item.id} data={item} onClick={handleClick} />}
    </VirtualList>
  );
});
```

---

### 3. Automated Test Generation

**Scenario:** Need tests for new feature

```vim
" Open implementation file
:e src/utils/validators.ts

" Generate Jest tests
:ClaudeCodeGenTests jest

" Creates: src/utils/validators.test.ts
```

**Generated test structure:**
```typescript
import { validateEmail, validatePassword, validateUsername } from './validators';

describe('validators', () => {
  describe('validateEmail', () => {
    it('should accept valid emails', () => {
      expect(validateEmail('user@example.com')).toBe(true);
      expect(validateEmail('name.surname@company.co.uk')).toBe(true);
    });

    it('should reject invalid emails', () => {
      expect(validateEmail('invalid')).toBe(false);
      expect(validateEmail('@example.com')).toBe(false);
      expect(validateEmail('user@')).toBe(false);
    });

    it('should handle edge cases', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail(null)).toBe(false);
      expect(validateEmail(undefined)).toBe(false);
    });
  });

  // ... more tests
});
```

**Supported frameworks:**
- JavaScript/TypeScript: jest, vitest, mocha
- Python: pytest, unittest
- Go: go-test
- Rust: cargo test

---

### 4. Code Refactoring for Readability

**Scenario:** Legacy code is hard to understand

```vim
" Open complex legacy file
:e src/legacy/payment-processor.js

" Request readability optimization
:ClaudeCodeOptimize readability
```

**AI transformations:**
- Extract magic numbers to constants
- Rename cryptic variables
- Break down long functions
- Add descriptive comments
- Improve naming conventions
- Simplify nested logic

**Before:**
```javascript
function p(d, a, t) {
  if (d.s === 1 && a > 100) {
    const r = a * 0.02;
    return (a + r) * (t === 2 ? 1.05 : 1);
  }
  return a;
}
```

**After:**
```javascript
const MIN_AMOUNT_FOR_FEE = 100;
const PROCESSING_FEE_RATE = 0.02;
const EXPRESS_SURCHARGE = 1.05;

/**
 * Calculate total payment amount including fees and surcharges
 * @param {Object} data - Payment data
 * @param {number} amount - Base amount
 * @param {number} type - Payment type (1: standard, 2: express)
 * @returns {number} Final amount to charge
 */
function calculatePaymentTotal(data, amount, type) {
  const isStandardPayment = data.status === 1;
  const requiresProcessingFee = amount > MIN_AMOUNT_FOR_FEE;

  if (isStandardPayment && requiresProcessingFee) {
    const processingFee = amount * PROCESSING_FEE_RATE;
    const baseTotal = amount + processingFee;
    const isExpressPayment = type === 2;

    return isExpressPayment ? baseTotal * EXPRESS_SURCHARGE : baseTotal;
  }

  return amount;
}
```

---

### 5. Security Hardening

**Scenario:** Need security review before deployment

```vim
" Analyze authentication module
:e src/auth/login.ts

" Request security-focused optimization
:ClaudeCodeOptimize security
```

**AI identifies:**
- SQL injection vulnerabilities
- XSS attack vectors
- Insecure password storage
- Missing input validation
- Weak cryptography
- Exposed secrets

**Security improvements:**
```typescript
// Before (VULNERABLE)
function login(username, password) {
  const query = `SELECT * FROM users WHERE username='${username}' AND password='${password}'`;
  return db.query(query);
}

// After (SECURE)
import bcrypt from 'bcrypt';
import { query as dbQuery } from './db';

async function login(username: string, password: string): Promise<User | null> {
  // Input validation
  if (!username || !password) {
    throw new ValidationError('Username and password required');
  }

  if (username.length > 100 || password.length > 100) {
    throw new ValidationError('Input exceeds maximum length');
  }

  // Parameterized query (prevents SQL injection)
  const user = await dbQuery(
    'SELECT id, username, password_hash FROM users WHERE username = ?',
    [username]
  );

  if (!user) {
    return null;
  }

  // Secure password comparison
  const isValid = await bcrypt.compare(password, user.password_hash);

  if (!isValid) {
    return null;
  }

  // Return user without password hash
  return {
    id: user.id,
    username: user.username,
  };
}
```

---

## Advanced Workflows

### 6. API Integration Assistant

**Scenario:** Integrating third-party API

```vim
" Get AI suggestions for API integration
:lua << EOF
local ai = require('claude-code.ai_integration')
local result = ai.get_development_suggestions({
  file_type = 'typescript',
  context = 'integrating Stripe payment API',
  project_type = 'e-commerce'
})
if result then
  vim.notify(vim.inspect(result), vim.log.levels.INFO)
end
EOF
```

**AI provides:**
- SDK recommendations
- Authentication patterns
- Error handling strategies
- Rate limiting implementation
- Webhook setup guidance
- Testing strategies

---

### 7. Database Query Optimization

**Scenario:** Slow database queries

```vim
" Open ORM/query file
:e src/db/queries.ts

" Analyze for performance
:ClaudeCodeOptimize performance
```

**AI suggestions:**
- Index recommendations
- N+1 query detection
- JOIN optimization
- Caching strategies
- Batch operations
- Connection pooling

**Before:**
```typescript
// N+1 problem
async function getPostsWithAuthors() {
  const posts = await Post.findAll();
  for (const post of posts) {
    post.author = await User.findById(post.authorId);
  }
  return posts;
}
```

**After:**
```typescript
async function getPostsWithAuthors() {
  const posts = await Post.findAll({
    include: [{
      model: User,
      as: 'author',
      attributes: ['id', 'name', 'email']
    }],
    order: [['createdAt', 'DESC']],
    limit: 50
  });
  return posts;
}
```

---

### 8. Type Safety Enhancement

**Scenario:** Adding TypeScript to JavaScript project

```vim
" Convert JS file to TS
:e src/utils/helpers.js

" Request type-safe version
:ClaudeCodeOptimize typescript
```

**Before (JavaScript):**
```javascript
function processUser(user) {
  return {
    name: user.name.toUpperCase(),
    age: user.age + 1,
    isAdmin: user.role === 'admin'
  };
}
```

**After (TypeScript):**
```typescript
interface User {
  name: string;
  age: number;
  role: 'admin' | 'user' | 'guest';
}

interface ProcessedUser {
  name: string;
  age: number;
  isAdmin: boolean;
}

function processUser(user: User): ProcessedUser {
  return {
    name: user.name.toUpperCase(),
    age: user.age + 1,
    isAdmin: user.role === 'admin'
  };
}
```

---

### 9. Documentation Generation

**Scenario:** Need comprehensive API documentation

```vim
" Generate docs for public API
:lua << EOF
local ai = require('claude-code.ai_integration')
local code = vim.fn.join(vim.fn.getline(1, '$'), '\n')
local result = ai.get_development_suggestions({
  file_type = 'typescript',
  context = 'generate API documentation with examples',
  code_sample = code
})
EOF
```

**Generated documentation:**
```typescript
/**
 * User Management API
 *
 * Provides endpoints for user CRUD operations with authentication.
 *
 * @example
 * // Create a new user
 * const user = await api.users.create({
 *   name: 'John Doe',
 *   email: 'john@example.com'
 * });
 *
 * @example
 * // Update user profile
 * await api.users.update(userId, {
 *   name: 'Jane Doe'
 * });
 */
export class UserAPI {
  /**
   * Creates a new user account
   *
   * @param data - User creation data
   * @param data.name - Full name (2-100 characters)
   * @param data.email - Valid email address
   * @param data.password - Password (min 8 characters)
   * @returns Created user object without password
   * @throws {ValidationError} If input validation fails
   * @throws {ConflictError} If email already exists
   */
  async create(data: CreateUserDTO): Promise<User> {
    // Implementation
  }
}
```

---

### 10. Migration Planning

**Scenario:** Planning upgrade or framework migration

```vim
" Get migration guidance
:lua << EOF
local ai = require('claude-code.ai_integration')
local result = ai.get_development_suggestions({
  context = 'migrating from React 17 to React 18',
  concerns = 'concurrent features, breaking changes, testing strategy'
})
EOF
```

**AI provides:**
- Migration checklist
- Breaking changes impact analysis
- Step-by-step upgrade path
- Code mod recommendations
- Testing strategy
- Rollback plan

---

## Team Workflows

### Code Review Assistant

```vim
" Before committing
:ClaudeCodeAnalyze

" Address issues, then
:ClaudeCodeGenTests jest

" Run tests
:!npm test

" If passing, commit
:Git add .
:Git commit
```

### Pre-Deployment Checklist

```vim
" 1. Security check
:ClaudeCodeOptimize security

" 2. Performance check
:ClaudeCodeOptimize performance

" 3. Generate/update tests
:ClaudeCodeGenTests

" 4. Run full test suite
:!npm run test:ci

" 5. Deploy
:!npm run deploy:production
```

---

## Programmatic Workflows

### Batch Processing Multiple Files

```lua
-- Analyze all TypeScript files in src/
local ai = require('claude-code.ai_integration')
local files = vim.fn.glob('src/**/*.ts', true, true)

for _, file in ipairs(files) do
  local content = table.concat(vim.fn.readfile(file), '\n')
  local result, err = ai.analyze_code_quality(content, 'typescript')

  if result then
    print(string.format('%s: Score %s/10', file, result.score or 'N/A'))
  else
    print(string.format('%s: Error - %s', file, err))
  end
end
```

### Custom AI Command

```vim
" Create custom command for your workflow
command! -nargs=0 MyCodeReview lua << EOF
  local ai = require('claude-code.ai_integration')
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local code = table.concat(lines, '\n')
  local ft = vim.bo[buf].filetype

  -- Custom analysis
  local result, err = ai.analyze_code_quality(code, ft)
  if not result then
    vim.notify('Analysis failed: ' .. err, vim.log.levels.ERROR)
    return
  end

  -- Custom reporting
  local report = string.format([[
Code Review Report
==================

File: %s
Type: %s
Lines: %d

%s
  ]], vim.fn.expand('%:p'), ft, #lines, vim.inspect(result))

  -- Write to report file
  vim.fn.writefile(vim.split(report, '\n'), 'code-review.txt')
  vim.notify('Review saved to code-review.txt', vim.log.levels.INFO)
EOF
```

---

## Best Practices

### When to Use AI

**✅ Good Use Cases:**
- Code review before commits
- Security audits
- Performance optimization
- Test generation
- Refactoring legacy code
- Documentation generation

**❌ Avoid:**
- Blindly accepting all suggestions
- Critical security decisions without review
- Production deployments without testing
- Replacing human code review entirely

### Quality Assurance

**Always:**
1. Review AI suggestions manually
2. Run tests after applying changes
3. Use version control (git)
4. Validate security recommendations
5. Performance test optimizations

**Never:**
1. Deploy AI-generated code untested
2. Skip human review for critical paths
3. Commit without understanding changes
4. Trust AI for business logic validation

### Rate Limiting Awareness

```lua
-- Check if approaching rate limit
local ai = require('claude-code.ai_integration')
local state = ai._rate_limit_state
local count = #state.requests

if count > 25 then  -- 30 is limit
  vim.notify('Approaching rate limit (' .. count .. '/30)', vim.log.levels.WARN)
end
```

---

## Troubleshooting

**AI not responding:**
```vim
:lua vim.print(require('claude-code.ai_integration').check_health())
```

**Rate limit exceeded:**
```vim
" Wait 1 minute or adjust limits in config
ai_integration = {
  rate_limit = {
    max_requests_per_minute = 60,  -- Increase if needed
  }
}
```

**Poor quality suggestions:**
```vim
" Provide more context
:lua << EOF
local ai = require('claude-code.ai_integration')
ai.get_development_suggestions({
  file_type = 'typescript',
  context = 'React component for user profile with form validation',
  frameworks = {'react', 'formik', 'yup'},
  requirements = 'accessibility, mobile-responsive'
})
EOF
```

---

## Quick Reference

| Workflow | Command | Use Case |
|----------|---------|----------|
| **Quality Check** | `:ClaudeCodeAnalyze` | Pre-commit review |
| **Performance** | `:ClaudeCodeOptimize performance` | Slow code |
| **Security** | `:ClaudeCodeOptimize security` | Security audit |
| **Readability** | `:ClaudeCodeOptimize readability` | Legacy code |
| **Tests** | `:ClaudeCodeGenTests jest` | Test coverage |
| **Suggestions** | `:ClaudeCodeSuggest` | General help |

---

**Estimated Time Savings:** 30-50% on code review, testing, and refactoring tasks
