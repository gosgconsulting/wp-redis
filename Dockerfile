FROM wordpress:php8.2-fpm

# Install system dependencies for Redis, PHP-FPM, and Nginx
RUN apt-get update && apt-get install -y \
    sudo \
    libpng-dev \
    openssl \
    curl \
    unzip \
    liblz4-dev \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy Nginx configuration
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx-default.conf /etc/nginx/conf.d/default.conf

# Install PHP extensions in the correct order for Object Cache Pro
# 1. Install igbinary first (required by Redis)
RUN pecl install -o -f igbinary \
    && docker-php-ext-enable igbinary

# 2. Install Redis extension configured with igbinary support
# Use environment variables to configure Redis compilation
RUN pecl install -o -f --configureoptions 'enable-redis-igbinary="yes" enable-redis-lz4="yes"' redis \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

# Install WP-CLI for WordPress management
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy custom scripts to be run by the official entrypoint
COPY fix-permissions.sh /docker-entrypoint-initwp.d/
COPY scripts/setup-object-cache-pro.sh /docker-entrypoint-initwp.d/
COPY scripts/copy-object-cache-pro.sh /docker-entrypoint-initwp.d/
COPY scripts/opcache-from-env.sh /docker-entrypoint-initwp.d/
COPY scripts/fpm-from-env.sh /docker-entrypoint-initwp.d/
RUN chmod +x /docker-entrypoint-initwp.d/fix-permissions.sh \
    && chmod +x /docker-entrypoint-initwp.d/setup-object-cache-pro.sh \
    && chmod +x /docker-entrypoint-initwp.d/copy-object-cache-pro.sh \
    && chmod +x /docker-entrypoint-initwp.d/opcache-from-env.sh \
    && chmod +x /docker-entrypoint-initwp.d/fpm-from-env.sh

# Copy the file manager
COPY wp-app/filemanager.php /var/www/html/

# Create directory for Object Cache Pro plugin
RUN mkdir -p /var/www/html/wp-content/plugins/object-cache-pro/

# Copy the custom wp-config.php file
COPY wp-config-docker.php /var/www/html/wp-config.php

# Copy custom PHP config to override defaults
COPY config/php.conf.ini /usr/local/etc/php/conf.d/uploads.ini

# Re-apply WordPress permissions. This is a build-time step.
# The fix-permissions.sh script will handle runtime permissions.
RUN chown -R www-data:www-data /var/www/html \
    && mkdir -p /run/php \
    && mkdir -p /var/log/nginx

# Expose port 80 and start php-fpm + nginx
EXPOSE 80
CMD ["sh", "-c", "php-fpm -F & exec nginx -g 'daemon off;' "]
