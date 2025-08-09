#!/bin/bash
set -e

# Generate OPcache config from environment variables (Railway-friendly)

OPCACHE_INI="/usr/local/etc/php/conf.d/zz-opcache.ini"

cat > "$OPCACHE_INI" <<EOF
opcache.enable=${PHP_OPCACHE_ENABLE:-1}
opcache.memory_consumption=${PHP_OPCACHE_MEMORY:-128}
opcache.max_accelerated_files=${PHP_OPCACHE_MAX_FILES:-10000}
opcache.revalidate_freq=${PHP_OPCACHE_REVALIDATE_FREQ:-60}
opcache.validate_timestamps=${PHP_OPCACHE_VALIDATE_TIMESTAMPS:-1}
opcache.save_comments=${PHP_OPCACHE_SAVE_COMMENTS:-1}
opcache.fast_shutdown=${PHP_OPCACHE_FAST_SHUTDOWN:-1}
opcache.jit=${PHP_OPCACHE_JIT:-0}
opcache.jit_buffer_size=${PHP_OPCACHE_JIT_BUFFER_SIZE:-0M}
EOF

echo "Wrote OPcache config to $OPCACHE_INI"


