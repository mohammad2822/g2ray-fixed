# G2Ray Fixed 🚀

> Enhanced V2Ray proxy via GitHub Codespaces with **dynamic IP detection**, **automatic reconnection**, and **secondary IP support**

## 🎯 Why G2Ray Fixed?

The original G2Ray had critical issues:
- ❌ Hardcoded IP addresses - fails when IP changes
- ❌ No automatic reconnection - manual restart required
- ❌ No secondary IP support - single point of failure
- ❌ Limited logging - difficult to debug issues

**This version fixes all of these!** ✅

## ✨ Key Improvements

| Feature | Original | Fixed |
|---------|----------|-------|
| **IP Detection** | Hardcoded (94.130.50.12) | 🎯 Dynamic & Automatic |
| **Reconnection** | ❌ None (manual restart) | 🔄 Auto via Supervisor |
| **Secondary IPs** | ❌ Not supported | ✅ Fully extensible |
| **Logging** | ⚠️ Limited | 📊 Comprehensive |
| **Error Handling** | Minimal | 🛡️ Robust |
| **Monitoring** | None | 👁️ Active monitoring |

## 🚀 Quick Start

### Step 1: Fork or Clone
```bash
gh repo clone vlonevli/g2ray-fixed
cd g2ray-fixed
```

### Step 2: Create Codespace
1. Go to https://github.com/vlonevli/g2ray-fixed
2. Click **"Code"** → **"Codespaces"** → **"Create codespace on main"**
3. Wait 3-5 minutes for setup

### Step 3: Get Your VLESS Link
Your VLESS proxy link will be displayed automatically:
```
✅ VLESS LINK:
vless://550e8400-e29b-41d4-a716-446655440000@your-codespace.app.github.dev:443?...
```

### Step 4: Connect
Copy the link and import into:
- **V2RayNG** (Android)
- **Clash Meta** (Windows/Mac/Linux)
- **Any VLESS-compatible client**

## 🔧 How It Works

### Dynamic IP Detection
```bash
# Automatically detects Codespace domain
# Generates fresh VLESS link on each startup
# No hardcoded IPs ever
```

### Automatic Reconnection
```bash
# Supervisor daemon monitors Xray process
# Restarts automatically on crash
# Handles network interruptions gracefully
```

### Process Management
```bash
# Check status
supervisorctl status

# Restart Xray
supervisorctl restart xray

# View logs
tail -f /var/log/xray/access.log
```

## 📊 Monitoring & Logs

### View Real-Time Logs
```bash
# Access logs (who's connecting)
tail -f /var/log/xray/access.log

# Error logs (troubleshooting)
tail -f /var/log/xray/error.log

# Process logs (supervisor)
tail -f /var/log/supervisor/xray.log
```

### Check Process Status
```bash
supervisorctl status xray

# Output example:
# xray                             RUNNING   pid 1234, uptime 2:34:56
```

## 🔍 Troubleshooting

### Connection Fails After Disconnect
**Fixed!** Supervisor automatically restarts the process. Wait 5-10 seconds and try again.

### Secondary IP Not Working
**Solution:** The infrastructure supports multiple IPs. Check the configuration:
```bash
cat /etc/xray/config.json
```

### Want Better Logging?
```bash
# Monitor all connections in real-time
watch -n 1 'supervisorctl status && echo "---" && tail -5 /var/log/xray/access.log'
```

### Process Keeps Restarting
Check logs:
```bash
tail -20 /var/log/xray/error.log
```

## 📋 Configuration

Base configuration stored in `.devcontainer/config.json`:
- **Protocol:** VLESS
- **Security:** TLS
- **Transport:** XHTTP (packet-up mode)
- **Port:** 443

### Customize

Edit `.devcontainer/config.json` to add:
- Secondary IPs
- Additional protocols
- Custom routing rules
- Performance tuning

## 🌐 Compatible Networks

Tested on:
- Shecan (free plan)
- Standard ISP networks
- University networks
- Most regional proxies

## 💡 Advanced Usage

### Add Secondary IP

Edit `.devcontainer/config.json`:
```json
{
  "outbounds": [
    {"protocol": "freedom", "tag": "primary"},
    {"protocol": "freedom", "tag": "secondary", "settings": {"domainStrategy": "preferIPv6"}}
  ]
}
```

### Modify Health Check

Edit `.devcontainer/supervisord.conf`:
```ini
[program:xray]
autorestart=true
startsecs=10  # Wait 10 seconds before marking as failed
stopwaitsecs=15  # Wait 15 seconds before force-kill
```

## 📦 System Requirements

- GitHub Codespaces (2 core minimum recommended)
- 120 free compute hours/month (60 hours for 2-core)
- GitHub CLI access
- Stable internet connection

## ⚠️ Important Notes

### GitHub Codespaces Quota
- **120 compute hours per month** (per core)
- For 2-core Codespace: 120 ÷ 2 = **60 hours/month**
- **Stop when not in use** to preserve hours
- Always restartable later

### Security Notes
1. Use a **secondary GitHub account** (not your main)
2. Keep your **UUID secret** (shown in VLESS link)
3. Share VLESS link only with trusted people
4. Monitor logs for suspicious activity

## 🐛 Known Issues & Fixes

| Issue | Status | Solution |
|-------|--------|----------|
| Disconnect/reconnect fails | ✅ Fixed | Auto-restart via Supervisor |
| Secondary IP not working | ✅ Extensible | Config ready, add as needed |
| Hardcoded IP errors | ✅ Fixed | Dynamic detection |
| No process monitoring | ✅ Fixed | Supervisor + logging |
| Silent failures | ✅ Fixed | Comprehensive error handling |

## 📚 File Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json       # Codespace config + supervisor
│   ├── Dockerfile              # Build image with dependencies
│   ├── install.sh              # Installation script
│   ├── start-xray.sh           # Dynamic IP + VLESS generation
│   ├── supervisord.conf        # Process management
│   └── config.json             # Xray configuration
├── README.md                   # This file
├── IMPROVEMENTS.md             # Detailed fixes
└── TROUBLESHOOTING.md          # 10+ solutions
```

## 🤝 Contributing

Found an issue? Have improvements?
1. Create an issue describing the problem
2. Fork and make your changes
3. Submit a pull request

## 📞 Support

For issues:
1. Check `TROUBLESHOOTING.md`
2. Review logs: `/var/log/xray/error.log`
3. Check supervisor status: `supervisorctl status`
4. Create an issue with logs attached

## 📄 License

Maintained as open-source. Based on original G2Ray project.

## ⭐ Credits

- **Original G2Ray:** mashayekhsina-afk/g2ray
- **Improvements:** Dynamic IP, Auto-reconnect, Multi-IP support
- **Xray Core:** XTLS/Xray-core

---

**Made with ❤️ for reliable proxy access**

Join the community and star if this helps you! ⭐
