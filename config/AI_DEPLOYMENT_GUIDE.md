# AI Integration Deployment Guide

## Overview

This guide covers deploying the NexaMind API for AI-powered development features in claude-code.nvim.

**Production Status:** Phase 4 - AI Integration

---

## Quick Start (Docker)

### Prerequisites

- Docker 20.10+ and Docker Compose
- 4GB RAM minimum (8GB recommended)
- 2+ CPU cores
- Network access to localhost:8004

### Option 1: Docker Compose (Recommended)

**Create `docker-compose.yml`:**

```yaml
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
      - WORKERS=2
      - MAX_CONCURRENT_REQUESTS=10
    volumes:
      - nexamind-models:/models
      - nexamind-cache:/cache
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8004/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    resources:
      limits:
        cpus: '2.0'
        memory: 4G
      reservations:
        cpus: '1.0'
        memory: 2G

volumes:
  nexamind-models:
  nexamind-cache:
```

**Start the service:**

```bash
docker-compose up -d

# Verify deployment
curl http://localhost:8004/health
# Expected: {"status":"healthy","engines":[...]}
```

### Option 2: Docker Run

```bash
docker run -d \
  --name nexamind-api \
  -p 8004:8004 \
  -e LOG_LEVEL=info \
  -e API_PORT=8004 \
  -v nexamind-models:/models \
  -v nexamind-cache:/cache \
  --restart unless-stopped \
  nexamind/api:latest

# Verify
docker logs nexamind-api
curl http://localhost:8004/health
```

---

## Plugin Configuration

### Enable AI Features

**In your claude-code profile:**

```lua
-- Add to backend.lua, frontend.lua, or devops.lua
require('claude-code').setup({
  -- ... existing config ...

  ai_integration = {
    enabled = true,
    api_url = 'http://localhost:8004',
    auto_health_check = true,
    health_check_interval = 30000, -- 30s

    -- Optional: Advanced config
    max_retries = 3,
    request_timeout = 30000,

    rate_limit = {
      max_requests_per_minute = 30,
      burst_size = 10,
    },

    privacy = {
      send_file_paths = false,     -- Don't send file paths
      redact_secrets = true,        -- Auto-redact API keys/passwords
      max_code_size = 100000,      -- 100KB limit
    },
  },
})
```

### Verify Installation

```vim
:checkhealth claude-code

" Expected output includes:
" ## AI Integration
" - OK: NexaMind API available (http://localhost:8004)
" - OK: Health check passed
```

---

## Available AI Commands

### Code Analysis

```vim
" Analyze current buffer for quality issues
:ClaudeCodeAnalyze

" Analyze specific code
:lua require('claude-code.ai_integration').analyze_code_quality([[
  function test() {
    console.log("test");
  }
]], 'javascript')
```

**Output:**
- Code quality score
- Potential issues
- Optimization suggestions
- Best practice recommendations

### Code Optimization

```vim
" Optimize for performance
:ClaudeCodeOptimize performance

" Optimize for readability
:ClaudeCodeOptimize readability

" Optimize for security
:ClaudeCodeOptimize security
```

**Programmatic:**
```lua
local ai = require('claude-code.ai_integration')
local result, err = ai.optimize_code(code_content, 'performance')
if result then
  vim.print(result)
end
```

### Test Generation

```vim
" Generate tests for current buffer
:ClaudeCodeGenTests jest

" Supported frameworks: jest, vitest, mocha, pytest, go-test
```

**Programmatic:**
```lua
local ai = require('claude-code.ai_integration')
local tests, err = ai.generate_tests(code_content, 'jest')
```

### Development Suggestions

```vim
" Get AI-powered suggestions for current context
:ClaudeCodeSuggest
```

**Programmatic:**
```lua
local ai = require('claude-code.ai_integration')
local suggestions, err = ai.get_development_suggestions({
  file_type = 'typescript',
  project_type = 'web-app',
  context = 'working on user authentication'
})
```

---

## AI Engines

NexaMind provides multiple specialized engines:

| Engine | Name | Capability |
|--------|------|------------|
| **DISE** | Dynamic Intent Scoring | Lead scoring, intent analysis |
| **CCAS** | Contextual Channel Automation | Multi-channel optimization |
| **ANA** | Adaptive Negotiation Algorithm | Strategy optimization |
| **LGM** | Lead Genome Mapping | Behavioral analysis |
| **RLGF** | ROI-Locked Guarantee Framework | Performance guarantees |

**List available engines:**
```vim
:lua vim.print(require('claude-code.ai_integration').engines)
```

---

## Production Deployment

### Environment Variables

```bash
# API Configuration
export NEXAMIND_API_URL=http://localhost:8004
export NEXAMIND_API_KEY=your-api-key-here  # If authentication enabled
export NEXAMIND_LOG_LEVEL=info

# Resource Limits
export NEXAMIND_MAX_WORKERS=4
export NEXAMIND_MAX_CONCURRENT_REQUESTS=20
export NEXAMIND_REQUEST_TIMEOUT=30000

# Privacy Settings
export NEXAMIND_REDACT_SECRETS=true
export NEXAMIND_MAX_CODE_SIZE=100000
```

### Docker Compose (Production)

```yaml
version: '3.8'

services:
  nexamind-api:
    image: nexamind/api:${NEXAMIND_VERSION:-latest}
    container_name: nexamind-api-prod
    ports:
      - "8004:8004"
    environment:
      - API_PORT=8004
      - LOG_LEVEL=${LOG_LEVEL:-info}
      - WORKERS=${WORKERS:-4}
      - MAX_CONCURRENT_REQUESTS=${MAX_CONCURRENT:-20}
      - API_KEY=${NEXAMIND_API_KEY}
    volumes:
      - ./models:/models:ro
      - ./cache:/cache
      - ./logs:/logs
    networks:
      - nexamind-net
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8004/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G

  # Optional: Reverse proxy for authentication
  nginx:
    image: nginx:alpine
    container_name: nexamind-nginx
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    networks:
      - nexamind-net
    depends_on:
      - nexamind-api
    restart: unless-stopped

networks:
  nexamind-net:
    driver: bridge
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexamind-api
  namespace: ai-services
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nexamind-api
  template:
    metadata:
      labels:
        app: nexamind-api
    spec:
      containers:
      - name: nexamind-api
        image: nexamind/api:latest
        ports:
        - containerPort: 8004
        env:
        - name: API_PORT
          value: "8004"
        - name: WORKERS
          value: "2"
        resources:
          limits:
            cpu: "2000m"
            memory: "4Gi"
          requests:
            cpu: "1000m"
            memory: "2Gi"
        livenessProbe:
          httpGet:
            path: /health
            port: 8004
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8004
          initialDelaySeconds: 10
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: nexamind-api
  namespace: ai-services
spec:
  selector:
    app: nexamind-api
  ports:
  - protocol: TCP
    port: 8004
    targetPort: 8004
  type: LoadBalancer
```

---

## Security Best Practices

### API Authentication

**Enable API key authentication:**

```lua
ai_integration = {
  enabled = true,
  api_url = 'http://localhost:8004',
  auth_token = os.getenv('NEXAMIND_API_KEY'),  -- Never hardcode!
}
```

**Generate API key:**
```bash
# In NexaMind API container
docker exec nexamind-api nexamind-cli generate-key
```

### Network Security

**Firewall rules:**
```bash
# Allow only localhost
sudo ufw allow from 127.0.0.1 to any port 8004

# Or specific subnet (team network)
sudo ufw allow from 192.168.1.0/24 to any port 8004
```

**TLS/SSL (Recommended for remote access):**
```nginx
server {
    listen 443 ssl;
    server_name nexamind.example.com;

    ssl_certificate /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;

    location / {
        proxy_pass http://nexamind-api:8004;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Data Privacy

**Automatic secret redaction:**

The plugin automatically redacts:
- API keys (pattern: `api_key="..."`)
- Passwords (pattern: `password="..."`)
- Tokens (pattern: `token="..."`)
- Long base64 strings (>32 chars)

**Manual review before sending:**
```lua
-- Preview what will be sent
local ai = require('claude-code.ai_integration')
local sanitized = ai._sanitize_code(code_content)
print(sanitized)  -- Review redacted version
```

### Rate Limiting

**Configure limits:**
```lua
rate_limit = {
  max_requests_per_minute = 30,  -- Adjust based on API capacity
  burst_size = 10,                -- Allow bursts
}
```

**Monitor usage:**
```vim
:lua vim.print(require('claude-code.ai_integration')._rate_limit_state)
```

---

## Monitoring & Observability

### Health Checks

**Manual health check:**
```bash
curl http://localhost:8004/health
```

**Automated monitoring:**
```vim
" Check AI availability
:lua vim.print(require('claude-code.ai_integration').check_health())
```

### Logs

**Docker logs:**
```bash
# Real-time
docker logs -f nexamind-api

# Last 100 lines
docker logs --tail 100 nexamind-api

# Filter errors
docker logs nexamind-api 2>&1 | grep ERROR
```

**Log aggregation (Production):**
```yaml
# In docker-compose.yml
logging:
  driver: "fluentd"
  options:
    fluentd-address: localhost:24224
    tag: nexamind.api
```

### Metrics

**API metrics endpoint:**
```bash
curl http://localhost:8004/api/v1/metrics/metrics/latest
```

**Response:**
```json
{
  "requests_total": 1523,
  "requests_success": 1498,
  "requests_failed": 25,
  "avg_response_time_ms": 152,
  "p95_response_time_ms": 287,
  "p99_response_time_ms": 412
}
```

**Prometheus integration:**
```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'nexamind-api'
    static_configs:
      - targets: ['localhost:8004']
    metrics_path: '/metrics'
```

---

## Performance Tuning

### Resource Allocation

**CPU and Memory:**
```yaml
# docker-compose.yml
resources:
  limits:
    cpus: '4.0'         # Adjust based on load
    memory: 8G          # 2GB per worker recommended
  reservations:
    cpus: '2.0'
    memory: 4G
```

**Workers:**
```bash
# Rule of thumb: 1-2 workers per CPU core
export WORKERS=$(($(nproc) * 2))
```

### Caching

**Model caching:**
```yaml
volumes:
  - nexamind-models:/models  # Persist models
  - nexamind-cache:/cache    # Response cache
```

**Cache configuration:**
```bash
export CACHE_ENABLED=true
export CACHE_TTL=3600       # 1 hour
export CACHE_MAX_SIZE=1G
```

### Request Optimization

**Plugin-side optimization:**
```lua
ai_integration = {
  request_timeout = 30000,    -- 30s (adjust for slow requests)
  max_retries = 3,            -- Retry on transient failures

  privacy = {
    max_code_size = 50000,    -- Reduce for faster processing
  },
}
```

---

## Troubleshooting

### API Not Responding

**Diagnosis:**
```bash
# Check if container is running
docker ps | grep nexamind

# Check logs
docker logs nexamind-api --tail 50

# Test connectivity
curl -v http://localhost:8004/health
```

**Solutions:**
```bash
# Restart container
docker restart nexamind-api

# Check resource usage
docker stats nexamind-api

# Verify port binding
netstat -tulpn | grep 8004
```

### High Latency

**Diagnosis:**
```vim
:lua vim.print(require('claude-code.ai_integration').get_api_metrics())
```

**Solutions:**
1. Increase workers: `export WORKERS=4`
2. Add more resources (CPU/memory)
3. Enable caching
4. Reduce `max_code_size` limit

### Rate Limiting Issues

**Symptom:** "Rate limit exceeded" errors

**Solutions:**
```lua
-- Increase limits
rate_limit = {
  max_requests_per_minute = 60,  -- Increase from 30
  burst_size = 20,                -- Increase burst
}
```

### Authentication Failures

**Symptom:** 401/403 errors

**Diagnosis:**
```bash
# Test with API key
curl -H "Authorization: Bearer YOUR_API_KEY" http://localhost:8004/health
```

**Solutions:**
```lua
-- Set API key
ai_integration = {
  auth_token = os.getenv('NEXAMIND_API_KEY'),
}
```

```bash
# Verify environment variable
echo $NEXAMIND_API_KEY
```

---

## Cost Optimization

### On-Premise vs Cloud

**On-Premise (Docker on local/team server):**
- **Pros:** No API costs, data privacy, low latency
- **Cons:** Infrastructure management, upfront hardware costs
- **Recommended for:** Teams with existing servers, privacy requirements

**Cloud (AWS/GCP/Azure):**
- **Pros:** Scalability, managed infrastructure
- **Cons:** Ongoing API/compute costs
- **Recommended for:** Distributed teams, high availability needs

### Resource Efficiency

**Auto-scaling:**
```yaml
# docker-compose.yml with autoscaler
deploy:
  replicas: 2
  update_config:
    parallelism: 1
    delay: 10s
  restart_policy:
    condition: on-failure
```

**Spot instances (AWS):**
```bash
# Use spot instances for 60-90% cost savings
aws ec2 run-instances \
  --instance-type c5.2xlarge \
  --spot-price "0.20" \
  --instance-market-options MarketType=spot
```

---

## Migration & Upgrade

### Upgrade NexaMind API

```bash
# Pull latest image
docker pull nexamind/api:latest

# Stop current container
docker stop nexamind-api

# Backup volumes
docker run --rm \
  -v nexamind-models:/from \
  -v $(pwd)/backup:/to \
  alpine sh -c "cd /from && tar czf /to/models-$(date +%Y%m%d).tar.gz ."

# Start with new image
docker-compose up -d

# Verify
curl http://localhost:8004/health
```

### Rollback

```bash
# Use specific version
docker-compose down
docker run -d \
  --name nexamind-api \
  -p 8004:8004 \
  nexamind/api:v1.2.3  # Specify version

# Restore from backup if needed
docker run --rm \
  -v nexamind-models:/to \
  -v $(pwd)/backup:/from \
  alpine sh -c "cd /to && tar xzf /from/models-backup.tar.gz"
```

---

## Quick Reference

**Start API:**
```bash
docker-compose up -d
```

**Stop API:**
```bash
docker-compose down
```

**View logs:**
```bash
docker logs -f nexamind-api
```

**Health check:**
```bash
curl http://localhost:8004/health
```

**Restart:**
```bash
docker restart nexamind-api
```

**Update:**
```bash
docker-compose pull
docker-compose up -d
```

---

## Support

**Check health:**
```vim
:checkhealth claude-code
```

**Test API manually:**
```bash
curl -X POST http://localhost:8004/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Test message"}]}'
```

**Debug mode:**
```bash
docker logs nexamind-api --tail 100 | grep ERROR
```

**Community:** GitHub Issues / Discussions

---

**Estimated Setup Time:** 15-30 minutes
**Production Deployment:** 1-2 hours (including security hardening)
