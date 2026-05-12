#!/bin/bash

set -e

echo "📦 Installing G2Ray Fixed Dependencies..."

# Download Xray
echo "⬇️  Downloading Xray Core v26.3.27..."
if ! wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip; then
    echo "❌ Failed to download Xray"
    exit 1
fi

# Extract and install
echo "🔧 Extracting and installing Xray..."
cd /tmp
if ! unzip -q xray.zip; then
    echo "❌ Failed to extract Xray"
    exit 1
fi

if [ ! -f xray ]; then
    echo "❌ Xray binary not found after extraction"
    exit 1
fi

chmod +x xray
mv xray /usr/local/bin/xray

# Verify installation
echo "✅ Verifying Xray installation..."
if ! /usr/local/bin/xray -version; then
    echo "❌ Xray verification failed"
    exit 1
fi

# Cleanup
rm -rf /tmp/xray* /tmp/geo*

echo "✅ Installation complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Xray is configured for auto-restart"
echo "  2. Dynamic VLESS link will be generated at startup"
echo "  3. Check /var/log/xray/ for logs"
echo ""
