#!/bin/bash
set -e

# Render Apache MPM prefork tuning from environment variables (Railway-friendly)
# Runs at container start via /docker-entrypoint-initwp.d

# If no APACHE_* tuning vars are set, do nothing and keep Apache defaults
if [ -z "${APACHE_SERVER_LIMIT}${APACHE_START_SERVERS}${APACHE_MIN_SPARE_SERVERS}${APACHE_MAX_SPARE_SERVERS}${APACHE_MAX_REQUEST_WORKERS}${APACHE_MAX_CONNECTIONS_PER_CHILD}" ]; then
  echo "Apache MPM tuning: no env vars set, keeping defaults"
  exit 0
fi

CONF_NAME="z-mpm-tuning.conf"
CONF_DIR="/etc/apache2/conf-available"
CONF_PATH="${CONF_DIR}/${CONF_NAME}"

mkdir -p "$CONF_DIR"

cat > "$CONF_PATH" <<EOF
# Generated at container start from environment variables
<IfModule mpm_prefork_module>
    ServerLimit              ${APACHE_SERVER_LIMIT}
    StartServers             ${APACHE_START_SERVERS}
    MinSpareServers          ${APACHE_MIN_SPARE_SERVERS}
    MaxSpareServers          ${APACHE_MAX_SPARE_SERVERS}
    MaxRequestWorkers        ${APACHE_MAX_REQUEST_WORKERS}
    MaxConnectionsPerChild   ${APACHE_MAX_CONNECTIONS_PER_CHILD}
</IfModule>
EOF

# Enable the configuration if not already enabled
if [ ! -e "/etc/apache2/conf-enabled/${CONF_NAME}" ]; then
  a2enconf "$CONF_NAME" >/dev/null 2>&1 || a2enconf "$CONF_NAME"
fi

echo "Apache MPM tuning written to $CONF_PATH and enabled"


