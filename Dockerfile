FROM wordpress:latest

# Install system dependencies for Redis and WordPress
RUN apt-get update && apt-get install -y \
    sudo \
    libpng-dev \
    openssl \
    curl \
    liblz4-dev \
    libigbinary-dev \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache's rewrite module, required for WordPress permalinks and .htaccess files
RUN a2enmod rewrite

# Copy custom Apache config to enable .htaccess overrides
COPY config/apache-custom.conf /etc/apache2/conf-enabled/apache-custom.conf

# Install performance extensions for Object Cache Pro
RUN pecl install -o -f igbinary \
    && docker-php-ext-enable igbinary

# Install Redis extension with igbinary and lz4 support
RUN pecl install -o -f redis --enable-redis-igbinary \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

# Copy custom scripts to be run by the official entrypoint
COPY fix-permissions.sh /docker-entrypoint-initwp.d/
RUN chmod +x /docker-entrypoint-initwp.d/fix-permissions.sh

# Copy the file manager
COPY wp-app/filemanager.php /var/www/html/

# wp-content will be managed manually through WordPress admin

# Copy the custom wp-config.php file
COPY wp-config-docker.php /var/www/html/wp-config.php

# Copy custom PHP config to override defaults
COPY config/php.conf.ini /usr/local/etc/php/conf.d/uploads.ini

# Re-apply WordPress permissions. This is a build-time step.
# The fix-permissions.sh script will handle runtime permissions.
RUN chown -R www-data:www-data /var/www/html

# Expose port 80 and start php-fpm
EXPOSE 80
CMD ["apache2-foreground"]
