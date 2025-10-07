# AI Integration Security Guide

## Overview

Security considerations and best practices for using AI-powered features in claude-code.nvim with NexaMind API.

---

## Security Architecture

### Threat Model

**Assets to Protect:**
- Source code (intellectual property)
- API keys and secrets
- User credentials
- Private business logic
- Infrastructure configuration

**Threat Actors:**
- Malicious insiders
- External attackers with network access
- Compromised dependencies
- Supply chain attacks

**Attack Vectors:**
- Network interception
- Data exfiltration via AI requests
- API key theft
- Code injection
- Unauthorized access to API

---

## Built-in Security Features

### 1. Automatic Secret Redaction

**How it works:**

The plugin automatically scans code for common secret patterns before sending to the AI:

```lua
-- Automatically redacts:
local patterns = {
  { pattern = '(["\'])([A-Za-z0-9+/=]{32,})%1', replacement = '%1[REDACTED_SECRET]%1' },
  { pattern = 'password%s*=%s*["\']([^"\']+)["\']', replacement = 'password="[REDACTED]"' },
  { pattern = 'api[_-]?key%s*=%s*["\']([^"\']+)["\']', replacement = 'api_key="[REDACTED]"' },
  { pattern = 'token%s*=%s*["\']([^"\']+)["\']', replacement = 'token="[REDACTED]"' },
  { pattern = 'secret%s*=%s*["\']([^"\']+)["\']', replacement = 'secret="[REDACTED]"' },
}
```

**Example:**

**Before redaction:**
```javascript
const API_KEY = "sk_live_abc123xyz789";
const password = "SuperSecret123!";
```

**After redaction (sent to AI):**
```javascript
const api_key = "[REDACTED]";
const password = "[REDACTED]";
```

**Enable/disable:**
```lua
ai_integration = {
  privacy = {
    redact_secrets = true,  -- Default: true
  }
}
```

### 2. Code Size Limits

**Prevents excessive data transmission:**

```lua
privacy = {
  max_code_size = 100000,  -- 100KB limit (default)
}
```

**Behavior:**
- Requests exceeding limit are rejected before transmission
- Error message shows actual vs max size
- Prevents accidental data dumps

### 3. File Path Privacy

**Prevents leaking directory structure:**

```lua
privacy = {
  send_file_paths = false,  -- Default: false
}
```

**Impact:**
- File paths not included in AI requests
- Only code content is transmitted
- Protects organizational structure

### 4. Rate Limiting

**Prevents API abuse:**

```lua
rate_limit = {
  max_requests_per_minute = 30,  -- Adjustable
  burst_size = 10,
}
```

**Protection against:**
- Accidental infinite loops
- Malicious automation
- Resource exhaustion

---

## Network Security

### Localhost-Only (Recommended)

**Default configuration:**
```lua
ai_integration = {
  api_url = 'http://localhost:8004',  -- Local only
}
```

**Security benefits:**
- No external network traffic
- Not exposed to internet
- Immune to network interception
- Fast response times

### TLS/SSL for Remote Access

**If remote access is required:**

**1. Generate certificates:**
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/certs/key.pem \
  -out /etc/nginx/certs/cert.pem
```

**2. Configure Nginx reverse proxy:**
```nginx
server {
    listen 443 ssl;
    server_name nexamind.internal.company.com;

    ssl_certificate /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Client certificate authentication (optional)
    ssl_client_certificate /etc/nginx/certs/ca.pem;
    ssl_verify_client on;

    location / {
        proxy_pass http://nexamind-api:8004;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**3. Update plugin configuration:**
```lua
ai_integration = {
  api_url = 'https://nexamind.internal.company.com',
}
```

### Firewall Rules

**Restrict access to API:**

```bash
# Allow only localhost
sudo ufw allow from 127.0.0.1 to any port 8004

# Or specific subnet (team network)
sudo ufw allow from 192.168.1.0/24 to any port 8004

# Deny all other access
sudo ufw deny 8004
```

**Docker network isolation:**
```yaml
# docker-compose.yml
services:
  nexamind-api:
    networks:
      - internal-only

networks:
  internal-only:
    internal: true  # No external access
```

---

## API Authentication

### API Key Setup

**1. Generate API key:**
```bash
docker exec nexamind-api nexamind-cli generate-key
# Output: nxm_abc123xyz789...
```

**2. Store securely:**
```bash
# Use environment variable (NEVER hardcode!)
export NEXAMIND_API_KEY="nxm_abc123xyz789..."

# Or use password manager / secrets vault
```

**3. Configure plugin:**
```lua
ai_integration = {
  api_url = 'http://localhost:8004',
  auth_token = os.getenv('NEXAMIND_API_KEY'),  -- Read from env
}
```

**4. Verify authentication:**
```bash
curl -H "Authorization: Bearer $NEXAMIND_API_KEY" \
  http://localhost:8004/health
```

### Key Rotation

**Rotate keys regularly (recommended: quarterly):**

```bash
# Generate new key
NEW_KEY=$(docker exec nexamind-api nexamind-cli generate-key)

# Update environment
export NEXAMIND_API_KEY="$NEW_KEY"

# Revoke old key
docker exec nexamind-api nexamind-cli revoke-key OLD_KEY

# Restart Neovim to pick up new key
```

---

## Data Privacy

### What Gets Sent to AI

**Transmitted:**
- Code content (with redaction)
- File type (e.g., "javascript", "python")
- Context hints (if provided)

**NOT transmitted:**
- File paths (if `send_file_paths = false`)
- Git history
- Environment variables
- System information
- Other open files

### Code Review Before Transmission

**Manual review workflow:**

```vim
" Preview what will be sent
:lua << EOF
local ai = require('claude-code.ai_integration')
local code = vim.fn.join(vim.fn.getline(1, '$'), '\n')

-- Check sanitization
local sanitized, err = ai._sanitize_code(code)
if sanitized then
  -- Open in new buffer for review
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(sanitized, '\n'))
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = 80,
    height = 20,
    row = 5,
    col = 10,
    border = 'rounded',
  })
  vim.notify('Review sanitized code before sending', vim.log.levels.INFO)
else
  vim.notify('Sanitization failed: ' .. err, vim.log.levels.ERROR)
end
EOF
```

### Compliance Requirements

**GDPR/Privacy Regulations:**

```lua
-- Minimal data collection
ai_integration = {
  privacy = {
    send_file_paths = false,     -- Don't send paths
    redact_secrets = true,        -- Redact sensitive data
    max_code_size = 50000,       -- Limit data size
  },

  -- Disable telemetry
  telemetry = false,
}
```

**Data retention:**
- Plugin: No data stored
- NexaMind API: Configure retention policy
- Logs: Rotate and purge regularly

---

## Secure Configuration

### Environment-Based Configuration

**Development:**
```lua
-- dev.lua
return {
  ai_integration = {
    enabled = true,
    api_url = 'http://localhost:8004',
    auth_token = os.getenv('NEXAMIND_DEV_KEY'),
  }
}
```

**Production:**
```lua
-- prod.lua
return {
  ai_integration = {
    enabled = true,
    api_url = 'https://nexamind-api.company.internal',
    auth_token = os.getenv('NEXAMIND_PROD_KEY'),

    -- Stricter limits
    rate_limit = {
      max_requests_per_minute = 15,
      burst_size = 5,
    },

    privacy = {
      send_file_paths = false,
      redact_secrets = true,
      max_code_size = 50000,
    },
  }
}
```

**Load based on environment:**
```lua
local env = os.getenv('ENV') or 'dev'
local config = require('ai-config.' .. env)
require('claude-code').setup(config)
```

### Secrets Management

**DO NOT:**
```lua
-- ❌ NEVER hardcode secrets
ai_integration = {
  auth_token = "nxm_abc123xyz789...",  -- UNSAFE!
}
```

**DO:**
```lua
-- ✅ Use environment variables
ai_integration = {
  auth_token = os.getenv('NEXAMIND_API_KEY'),
}
```

```lua
-- ✅ Or use secrets manager
local secrets = require('company.secrets')
ai_integration = {
  auth_token = secrets.get('nexamind_api_key'),
}
```

---

## Audit & Monitoring

### Request Logging

**Enable audit logging:**

```bash
# In NexaMind API container
docker exec nexamind-api \
  nexamind-cli config set audit_log_enabled true
```

**Log format:**
```json
{
  "timestamp": "2025-01-15T10:23:45Z",
  "user_id": "user@company.com",
  "endpoint": "/ai/chat",
  "code_size": 1523,
  "file_type": "typescript",
  "ip_address": "192.168.1.100",
  "status": "success"
}
```

**Review logs:**
```bash
docker logs nexamind-api | grep AUDIT
```

### Rate Limit Monitoring

**Check current usage:**
```vim
:lua << EOF
local ai = require('claude-code.ai_integration')
local state = ai._rate_limit_state
local count = #state.requests

vim.notify(
  string.format('Rate limit: %d/%d requests',
    count,
    ai.config.rate_limit.max_requests_per_minute
  ),
  vim.log.levels.INFO
)
EOF
```

**Set up alerts:**
```lua
-- Auto-warn at 80% of rate limit
vim.api.nvim_create_autocmd('User', {
  pattern = 'AIRequestSent',
  callback = function()
    local ai = require('claude-code.ai_integration')
    local count = #ai._rate_limit_state.requests
    local limit = ai.config.rate_limit.max_requests_per_minute

    if count / limit > 0.8 then
      vim.notify(
        string.format('Approaching rate limit: %d/%d', count, limit),
        vim.log.levels.WARN
      )
    end
  end,
})
```

### Security Incident Response

**If compromised:**

1. **Immediately:**
   ```bash
   # Stop API
   docker stop nexamind-api

   # Rotate keys
   export NEXAMIND_API_KEY="new-key-here"

   # Review logs
   docker logs nexamind-api > incident-logs.txt
   ```

2. **Investigate:**
   - Check audit logs for suspicious requests
   - Review network traffic
   - Identify compromised credentials

3. **Remediate:**
   - Update all API keys
   - Patch vulnerabilities
   - Update firewall rules
   - Enable additional authentication

4. **Post-incident:**
   - Document findings
   - Update security policies
   - Train team on new procedures

---

## Best Practices Checklist

### Deployment Security

- [ ] API runs on localhost or internal network only
- [ ] TLS/SSL enabled for remote access
- [ ] Firewall rules restrict access
- [ ] API key authentication enabled
- [ ] Keys stored in environment variables (not code)
- [ ] Regular key rotation (quarterly)
- [ ] Audit logging enabled

### Configuration Security

- [ ] Secret redaction enabled
- [ ] File paths not transmitted
- [ ] Code size limits enforced
- [ ] Rate limiting configured
- [ ] Telemetry disabled (if applicable)
- [ ] Minimal permissions granted

### Operational Security

- [ ] Regular security audits
- [ ] Log review and monitoring
- [ ] Incident response plan documented
- [ ] Team trained on security practices
- [ ] Regular updates and patches applied

---

## Compliance Matrix

| Requirement | Configuration | Validation |
|-------------|---------------|------------|
| **Data Minimization** | `send_file_paths = false` | ✅ Paths not sent |
| **Secret Protection** | `redact_secrets = true` | ✅ Auto-redacted |
| **Size Limits** | `max_code_size = 100000` | ✅ Enforced |
| **Encryption (Remote)** | TLS 1.2+ | ✅ Nginx config |
| **Access Control** | Firewall + Auth | ✅ UFW rules |
| **Audit Trail** | Logging enabled | ✅ Docker logs |
| **Rate Limiting** | 30 req/min | ✅ Enforced |

---

## Security FAQs

**Q: Is my code sent to external servers?**
A: No, if using `localhost:8004`. All processing happens locally.

**Q: What if I accidentally send a secret?**
A: Auto-redaction catches common patterns. Review code before sending.

**Q: Can I disable AI features entirely?**
A: Yes, set `ai_integration.enabled = false`

**Q: How do I know if the API is secure?**
A: Run `curl http://localhost:8004/health` - should only work from localhost

**Q: What data is logged?**
A: Request metadata (not code content) - see audit logs

**Q: Can team members see each other's requests?**
A: Only if using shared API and audit logs are accessible

---

## Quick Reference

**Secure Configuration Template:**
```lua
ai_integration = {
  enabled = true,
  api_url = 'http://localhost:8004',              -- Localhost only
  auth_token = os.getenv('NEXAMIND_API_KEY'),    -- From env

  privacy = {
    send_file_paths = false,                      -- No paths
    redact_secrets = true,                        -- Auto-redact
    max_code_size = 100000,                      -- 100KB limit
  },

  rate_limit = {
    max_requests_per_minute = 30,
    burst_size = 10,
  },
}
```

**Security Commands:**
```bash
# Check API health
curl http://localhost:8004/health

# Review logs
docker logs nexamind-api | grep ERROR

# Rotate API key
docker exec nexamind-api nexamind-cli generate-key

# Stop API
docker stop nexamind-api
```

---

**Last Updated:** 2025-01-15
**Review Schedule:** Quarterly
**Next Review:** 2025-04-15
