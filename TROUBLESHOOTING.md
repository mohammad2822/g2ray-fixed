# G2Ray Fixed - Troubleshooting Guide

## Quick Reference

### Common Issues & Quick Fixes

| Issue | Quick Fix |
|-------|----------|
| Connection fails after disconnect | Wait 5-10s, auto-restart kicks in |
| Xray not running | `supervisorctl restart xray` |
| Can't see VLESS link | Check Codespace startup logs |
| Port 443 not accessible | Verify Codespace ports are public |
| Authentication fails | Check UUID in your client config |
| High latency | Switch to different Codespace location |
| Process keeps crashing | Check `/var/log/xray/error.log` |

---

## Detailed Solutions

### 1. ❌ Connection Fails After Disconnect/Reconnect

**Symptoms:**
- Was connected, disconnected
- Can't reconnect immediately
- Error: "Connection refused" or "Network unreachable"

**Why it happens:**
- Network interruption detected
- Xray process crashed

**Solution - Wait for Auto-Restart:**
```bash
# This is NORMAL and EXPECTED behavior
# Supervisor will automatically restart Xray within 5-10 seconds

# Wait 10 seconds
sleep 10

# Try reconnecting in your client
# Connection should work now
```

**Verify Status:**
```bash
# Check if Xray is running
supervisorctl status xray

# Output should show: RUNNING
# Example: xray RUNNING pid 1234, uptime 0:05:23
```

**Manual Restart (if needed):**
```bash
supervisorctl restart xray
echo "Waiting for restart..."
sleep 5
supervisorctl status xray
```

**View Restart Logs:**
```bash
# See when Xray restarted
tail -20 /var/log/supervisor/xray.log | grep -i restart

# Monitor in real-time
watch -n 1 'supervisorctl status && echo "---" && tail -3 /var/log/supervisor/xray.log'
```

---

### 2. ❌ Can't Connect to Proxy at All

**Symptoms:**
- VLESS link imports but won't connect
- Error: "Connection timeout"
- Client shows "Unreachable"

**Step 1: Verify Port is Public**
```bash
# Check port forwarding
gh codespace ports

# Output should show:
# 443 Forwarded    Public    https://[name]-443.app.github.dev
#
# If "Private", make it public:
gh codespace ports visibility 443:public
```

**Step 2: Verify Xray is Running**
```bash
# Check process status
supervisorctl status xray

# Should show: RUNNING (not STOPPED, not EXITED)

# If not running:
supervisorctl start xray
sleep 3
supervisorctl status xray
```

**Step 3: Check for Errors**
```bash
# View error logs
tail -50 /var/log/xray/error.log

# Look for error messages like:
# - "permission denied"
# - "address already in use"
# - "TLS certificate error"
```

**Step 4: Verify Configuration**
```bash
# Check Xray config is valid
xray -c /etc/xray/config.json -test

# Output should show: 
# Configuration OK
```

**Step 5: Test Connection Locally**
```bash
# Try connecting to localhost (should fail, expected)
curl -v https://localhost:443 --http2

# This is normal - verifies port is listening
```

**Resolution:**
1. ✅ Port is public
2. ✅ Xray is running
3. ✅ Config is valid
4. ✅ Import link again and test

---

### 3. ❌ Xray Process Keeps Crashing/Restarting

**Symptoms:**
- Supervisor shows frequent restarts
- `supervisorctl status` shows BACKOFF state
- Connection drops repeatedly

**Check Supervisor Logs:**
```bash
tail -50 /var/log/supervisor/xray.log

# Look for:
# - ERROR
# - FAILED
# - EXITED
```

**Check Xray Error Logs:**
```bash
tail -50 /var/log/xray/error.log

# Common errors:
# 1. "permission denied" → Run as root: sudo supervisord
# 2. "port already in use" → Kill process on port 443
# 3. "TLS error" → Check certificate
# 4. "config error" → Validate JSON
```

**Port Already in Use?**
```bash
# Find what's using port 443
sudo lsof -i :443

# Kill it
sudo kill -9 <PID>

# Restart Xray
supervisorctl restart xray
```

**Config JSON Invalid?**
```bash
# Validate config
xray -c /etc/xray/config.json -test

# If error, check syntax:
jq . /etc/xray/config.json

# If jq fails, JSON is invalid
# Check file:
cat /etc/xray/config.json
```

**Permission Issue?**
```bash
# Ensure supervisor runs as root
sudo supervisord -c /etc/supervisor/conf.d/supervisord.conf

# Check ownership
ls -la /usr/local/bin/xray
ls -la /etc/xray/config.json

# Should be readable/executable
```

**Fix Retry Settings:**
```bash
# Edit supervisor config
sudo nano /etc/supervisor/conf.d/supervisord.conf

# Increase startsecs (wait longer before considering failed):
# startsecs=10  # was 5
# retries=5     # was 3

# Reload
supervisorctl reread
supervisorctl update
```

---

### 4. ❌ Can't See VLESS Link at Startup

**Symptoms:**
- VLESS link not printed in terminal
- Startup looks silent
- Can't find connection details

**View Startup Logs:**
```bash
# Check entire supervisor log
cat /var/log/supervisor/xray.log

# Or view Xray startup
xray -c /etc/xray/config.json
# Press Ctrl+C to stop
```

**Check Codespace Logs:**
```bash
# In Codespace, view build output
echo "Checking build logs..."
ls -la /tmp/*.log

# View devcontainer build log
cat ~/.devcontainer.log 2>/dev/null
```

**Manually Generate Link:**
```bash
# Run startup script manually
bash /app/start-xray.sh

# Should print VLESS link
```

**Or manually construct:**
```bash
# Get your codespace name
echo $CODESPACE_NAME

# Construct link
echo "vless://550e8400-e29b-41d4-a716-446655440000@${CODESPACE_NAME}-443.app.github.dev:443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=${CODESPACE_NAME}-443.app.github.dev&alpn=h2,http/1.1"
```

---

### 5. ❌ UUID/Authentication Not Working

**Symptoms:**
- VLESS link imports but auth fails
- Error: "Invalid UUID"
- Client says "Auth failed"

**Check UUID Configuration:**
```bash
# View configured UUID
cat /etc/xray/config.json | grep -A2 '"clients"'

# Should show:
# "id": "550e8400-e29b-41d4-a716-446655440000"
```

**Verify UUID in Link:**
```bash
# Extract UUID from your link
echo "your-vless-link-here" | grep -oP '(?<=vless://)[^@]+'

# Should match the one in config.json
```

**Use Same UUID:**
```bash
# Default UUID in config:
550e8400-e29b-41d4-a716-446655440000

# Use this in your VLESS link as:
vless://550e8400-e29b-41d4-a716-446655440000@[host]:443?...
```

**Generate New UUID (if needed):**
```bash
# Generate UUID
xray uuid

# Output: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Update config:
sudo nano /etc/xray/config.json
# Find "id" and replace UUID

# Restart:
supervisorctl restart xray
```

---

### 6. ❌ Secondary IP Not Working

**Symptoms:**
- Configuration has secondary IP
- Doesn't actually route through secondary
- No fallback happening

**Verify Configuration:**
```bash
cat /etc/xray/config.json | jq '.outbounds'

# Should show multiple outbound entries:
# - primary (tag: "direct")
# - secondary (tag: "secondary")
```

**Check Routing Rules:**
```bash
cat /etc/xray/config.json | jq '.routing.rules'

# Should have rules directing to different outbounds
```

**Add Secondary IP Configuration:**

**Edit `/etc/xray/config.json`:**
```json
{
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct",
      "settings": {"domainStrategy": "UseIP"}
    },
    {
      "protocol": "freedom",
      "tag": "secondary",
      "settings": {"domainStrategy": "UseIPv6"}
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "domain": ["example.com"],
        "outboundTag": "secondary"
      }
    ]
  }
}
```

**Apply Changes:**
```bash
# Test config
xray -c /etc/xray/config.json -test

# Restart Xray
supervisorctl restart xray

# Monitor
supervisorctl status xray
```

---

### 7. ❌ High Latency / Slow Connection

**Symptoms:**
- Connection works but very slow
- High ping/latency
- Packet loss

**Check Codespace Location:**
```bash
# Codespaces may be geographically distant
# No direct control, but can create new ones

# Current Codespace info:
echo "Name: $CODESPACE_NAME"
echo "Region info not directly available"
```

**Solutions:**
1. **Create new Codespace** (may get different region):
   ```bash
   gh codespace create --repo vlonevli/g2ray-fixed
   ```

2. **Stop and restart current one** (may reset region):
   ```bash
   gh codespace stop -c $CODESPACE_NAME
   # Wait 1 minute
   gh codespace start -c $CODESPACE_NAME
   ```

3. **Optimize configuration** for speed:
   ```bash
   # Edit config.json
   # Reduce buffer sizes
   # Disable unnecessary logging
   ```

**Monitor Latency:**
```bash
# From client side, ping server
ping your-codespace.app.github.dev

# Check packet loss
ping -c 100 your-codespace.app.github.dev

# If >5% loss, network is unstable
```

---

### 8. ❌ Logs Not Appearing

**Symptoms:**
- `/var/log/xray/` is empty
- No access.log or error.log
- Can't debug issues

**Verify Log Configuration:**
```bash
# Check if logging is enabled in config
cat /etc/xray/config.json | jq '.log'

# Should show:
# "loglevel": "info",
# "access": "/var/log/xray/access.log",
# "error": "/var/log/xray/error.log"
```

**Check Directory Permissions:**
```bash
ls -la /var/log/xray/

# Should show:
# total 0
# drwxr-xr-x ... xray/

# If missing, create:
sudo mkdir -p /var/log/xray
sudo chmod 755 /var/log/xray
```

**Restart Xray:**
```bash
supervisorctl restart xray

# Wait 5 seconds
sleep 5

# Check logs
ls -la /var/log/xray/

# Should now have files
ls -la /var/log/xray/access.log
```

**Enable Debug Logging:**
```bash
# Edit config
sudo nano /etc/xray/config.json

# Change loglevel:
# "loglevel": "debug"

# Restart:
supervisorctl restart xray

# More verbose output now
```

---

### 9. ❌ GitHub Codespaces Quota Exceeded

**Symptoms:**
- Error: "Compute hours limit reached"
- Can't create new Codespace
- Existing ones stop

**Check Quota:**
```bash
gh api user/codespaces --paginate | jq '.[] | {name, state, created_at, updated_at}'
```

**Solutions:**

1. **Delete unused Codespaces:**
   ```bash
   # List all
   gh codespace list
   
   # Delete specific
   gh codespace delete -c <name>
   ```

2. **Stop current Codespace:**
   ```bash
   gh codespace stop
   ```

3. **Upgrade GitHub Plan:**
   - Free: 120 hours/month
   - Pro: 180 hours/month
   - Enterprise: Varies

4. **Wait for Reset:**
   - Quota resets monthly
   - Track usage at: https://github.com/settings/codespaces

**Monitor Usage:**
```bash
# Check remaining hours
gh api user -q '.billing_info.codespaces_minutes_used_this_cycle'
```

---

### 10. ❌ Codespace Won't Start

**Symptoms:**
- Codespace creation fails
- Stuck on "Setting up..."
- Container build fails

**Solutions:**

1. **Delete and Recreate:**
   ```bash
   gh codespace delete -c <name>
   # Wait 1 minute
   gh codespace create --repo vlonevli/g2ray-fixed
   ```

2. **Check Account Quotas:**
   ```bash
   gh api user/codespaces/quota
   ```

3. **Verify Repository:**
   ```bash
   gh repo view vlonevli/g2ray-fixed
   ```

4. **Check Dockerfile:**
   - Ensure `.devcontainer/Dockerfile` is valid
   - No syntax errors
   - All dependencies available

5. **Try Different Machine Type:**
   - Default: 2 core
   - Try 4 core (if available)

---

## Monitoring & Health Check

### Real-Time Monitoring

```bash
# Watch Xray status and recent logs
watch -n 1 'supervisorctl status xray && echo "" && tail -5 /var/log/xray/access.log'

# Exit: Ctrl+C
```

### Automated Health Check Script

```bash
#!/bin/bash
# health-check.sh

echo "🏥 G2Ray Health Check"
echo ""

# Check Xray status
echo "1️⃣  Process Status:"
supervisorctl status xray

# Check configuration
echo ""
echo "2️⃣  Configuration:"
xray -c /etc/xray/config.json -test 2>&1 | tail -1

# Check logs for errors
echo ""
echo "3️⃣  Recent Errors:"
tail -5 /var/log/xray/error.log 2>/dev/null || echo "No errors"

# Check port
echo ""
echo "4️⃣  Port Status:"
gh codespace ports 2>/dev/null || echo "Not in Codespace"

# Connection count
echo ""
echo "5️⃣  Active Connections:"
grep -c "inbound connection" /var/log/xray/access.log 2>/dev/null || echo "0"

echo ""
echo "✅ Health check complete"
```

**Run:**
```bash
bash health-check.sh
```

---

## Emergency Recovery

### Complete Reset

```bash
# Stop supervisor
sudo supervisorctl shutdown

# Remove logs
sudo rm -rf /var/log/xray/*
sudo rm -rf /var/log/supervisor/*

# Restart supervisor
sudo /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

# Verify
supervisorctl status xray
```

### Force Restart Xray

```bash
# Hard kill
sudo pkill -9 xray

# Supervisor should restart it automatically
sleep 5
supervisorctl status xray
```

---

## Getting Help

1. **Check logs first:**
   ```bash
   tail -50 /var/log/xray/error.log
   tail -50 /var/log/supervisor/xray.log
   ```

2. **Collect diagnostics:**
   ```bash
   echo "=== Status ==="
   supervisorctl status
   echo "=== Config Test ==="
   xray -c /etc/xray/config.json -test
   echo "=== Recent Errors ==="
   tail -20 /var/log/xray/error.log
   ```

3. **Create issue with:**
   - Error messages
   - Diagnostic output
   - Steps to reproduce
   - Expected vs actual behavior

---

## Prevention Tips

✅ **Do:**
- Monitor logs regularly
- Check Codespace hours remaining
- Stop Codespace when not in use
- Keep config backup
- Test after any changes

❌ **Don't:**
- Share VLESS link publicly
- Leave Codespace running 24/7
- Modify core Xray binary
- Use on untrusted networks
- Ignore error messages

---

**Still stuck?** Check the latest error logs and verify each step above. Most issues have simple solutions! 🚀
