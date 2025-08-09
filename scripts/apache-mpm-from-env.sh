#!/bin/bash
set -e

# Render Apache MPM prefork tuning from environment variables (Railway-friendly)
# Runs at container start via /docker-entrypoint-initwp.d

CONF_NAME="z-mpm-tuning.conf"
CONF_DIR="/etc/apache2/conf-available"
CONF_PATH="${CONF_DIR}/${CONF_NAME}"

mkdir -p "$CONF_DIR"

cat > "$CONF_PATH" <<EOF
# Generated at container start from environment variables
<IfModule mpm_prefork_module>
    ServerLimit              ${APACHE_SERVER_LIMIT:-200}
    StartServers             ${APACHE_START_SERVERS:-20}
    MinSpareServers          ${APACHE_MIN_SPARE_SERVERS:-20}
    MaxSpareServers          ${APACHE_MAX_SPARE_SERVERS:-40}
    MaxRequestWorkers        ${APACHE_MAX_REQUEST_WORKERS:-200}
    MaxConnectionsPerChild   ${APACHE_MAX_CONNECTIONS_PER_CHILD:-10000}
</IfModule>
EOF

# Enable the configuration if not already enabled
if [ ! -e "/etc/apache2/conf-enabled/${CONF_NAME}" ]; then
  a2enconf "$CONF_NAME" >/dev/null 2>&1 || a2enconf "$CONF_NAME"
fi

echo "Apache MPM tuning written to $CONF_PATH and enabled"


