#!/bin/bash
set -e

if [ -n "$WP_REDIS_ENABLED" ] && [ "$WP_REDIS_ENABLED" = "true" ]; then
    echo "Configuring Redis for WordPress..."

    if [ -f /var/www/html/wp-config.php ] && ! grep -q "WP_REDIS_CONFIG" /var/www/html/wp-config.php; then
        # Use a random salt for Redis
        WP_REDIS_SALT=$(openssl rand -base64 32)

        # Use 'cat' to append the Redis configuration block to wp-config.php
        cat <<'EOF' >> /var/www/html/wp-config.php

// Added by setup-redis.sh for Redis object cache
define( 'WP_REDIS_CONFIG', [
    'token'             => '$WP_REDIS_SALT',
    'host'              => getenv('WP_REDIS_HOST') ?: 'redis',
    'port'              => getenv('WP_REDIS_PORT') ?: 6379,
    'database'          => getenv('WP_REDIS_DATABASE') ?: 0,
    'password'          => getenv('WP_REDIS_PASSWORD') ?: null,
    'timeout'           => 1,
    'read_timeout'      => 1,
    'retry_interval'    => 3,
    'retries'           => 3,
    'backoff'           => 'decorrelated_jitter',
    'serializer'        => 'php',
    'compression'       => 'zstd',
    'async_flush'       => true,
    'split_alloptions'  => true,
    'client'            => 'pecl',
    'prefix'            => getenv('WP_REDIS_PREFIX') ?: 'wp_',
    'maxttl'            => 86400 * 7, // 7 days
    'debug'             => false,
    'save_commands'     => false,
] );

define( 'WP_REDIS_DISABLED', false );
EOF
        # Replace the placeholder salt with the generated one
        sed -i "s#\\\$WP_REDIS_SALT#$WP_REDIS_SALT#" /var/www/html/wp-config.php
        echo "Redis configuration added to wp-config.php."
    else
        echo "Redis configuration already exists or wp-config.php not found."
    fi
else
    echo "Redis is not enabled. Skipping configuration."
fi
