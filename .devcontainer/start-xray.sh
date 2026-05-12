#!/bin/bash

# Generate dynamic VLESS link and configuration

set -e

echo "🚀 Starting G2Ray Fixed..."
echo ""

# Get Codespace details
if [ -z "$CODESPACE_NAME" ]; then
    echo "❌ Not running in Codespace. CODESPACE_NAME not set."
    exit 1
fi

echo "📍 Codespace detected: $CODESPACE_NAME"

# Generate VLESS link
UUID="550e8400-e29b-41d4-a716-446655440000"
CODESPACE_HOST="${CODESPACE_NAME}-443.app.github.dev"

echo "🔗 Generating VLESS link..."
echo ""
echo "========================================"
echo "✅ VLESS LINK:"
echo "vless://${UUID}@${CODESPACE_HOST}:443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=${CODESPACE_HOST}&alpn=h2,http/1.1"
echo "========================================"
echo ""

echo "📋 Configuration Details:"
echo "  • Protocol: VLESS"
echo "  • Address: ${CODESPACE_HOST}"
echo "  • Port: 443"
echo "  • UUID: ${UUID}"
echo "  • Security: TLS"
echo "  • Network: XHTTP"
echo ""

echo "🛡️  Setup Instructions:"
echo "  1. Copy the VLESS link above"
echo "  2. Import into: V2RayNG, Clash Meta, or compatible client"
echo "  3. Connect and test"
echo ""

echo "📊 Monitoring:"
echo "  • Process status: supervisorctl status"
echo "  • Access logs: tail -f /var/log/xray/access.log"
echo "  • Error logs: tail -f /var/log/xray/error.log"
echo "  • Supervisor logs: tail -f /var/log/supervisor/xray.log"
echo ""

echo "✨ Ready! Your proxy is running and will auto-restart on disconnect."
echo ""
