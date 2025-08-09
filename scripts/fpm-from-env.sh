#!/bin/bash
set -e

# Generate PHP-FPM pool config from environment variables

POOL_CONF="/usr/local/etc/php-fpm.d/zz-www.conf"

cat > "$POOL_CONF" <<EOF
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = ${PHP_FPM_PM:-dynamic}
pm.max_children = ${PHP_FPM_MAX_CHILDREN:-20}
pm.start_servers = ${PHP_FPM_START_SERVERS:-5}
pm.min_spare_servers = ${PHP_FPM_MIN_SPARE_SERVERS:-5}
pm.max_spare_servers = ${PHP_FPM_MAX_SPARE_SERVERS:-10}
pm.max_requests = ${PHP_FPM_MAX_REQUESTS:-1000}
request_terminate_timeout = ${PHP_FPM_REQUEST_TERMINATE_TIMEOUT:-120s}
catch_workers_output = yes
EOF

echo "PHP-FPM pool written to $POOL_CONF"


