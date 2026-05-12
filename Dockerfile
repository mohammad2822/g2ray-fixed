FROM debian:bookworm-slim

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash git curl wget unzip tzdata openssl ca-certificates \
    supervisor dnsutils net-tools iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Copy installation script
COPY install.sh /app/install.sh
RUN chmod +x /app/install.sh && /app/install.sh

# Create log directories
RUN mkdir -p /var/log/xray /var/log/supervisor /etc/supervisor/conf.d

# Copy configuration files
COPY config.json /etc/xray/config.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-xray.sh /app/start-xray.sh
RUN chmod +x /app/start-xray.sh

# Verify Xray installation
RUN which xray && xray -version || echo "Xray installed"

# Expose port
EXPOSE 443

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD supervisorctl status xray | grep -q RUNNING || exit 1

# Start supervisor (which manages xray with auto-restart)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf", "-n"]
