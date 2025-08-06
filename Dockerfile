FROM wordpress:latest

# Install sudo, dependencies for GD library, and openssl for Redis salt generation
RUN apt-get update && apt-get install -y sudo libpng-dev openssl && rm -rf /var/lib/apt/lists/*

# Install redis extension
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Copy custom scripts to be run by the official entrypoint
COPY fix-permissions.sh /docker-entrypoint-initwp.d/
RUN chmod +x /docker-entrypoint-initwp.d/fix-permissions.sh

COPY setup-db.sh /docker-entrypoint-initwp.d/
RUN chmod +x /docker-entrypoint-initwp.d/setup-db.sh

COPY setup-redis.sh /docker-entrypoint-initwp.d/
RUN chmod +x /docker-entrypoint-initwp.d/setup-redis.sh

# Copy wp-content
COPY ./wp-content /var/www/html/wp-content/

# Re-apply WordPress permissions. This is a build-time step.
# The fix-permissions.sh script will handle runtime permissions.
RUN chown -R www-data:www-data /var/www/html

# Expose port 80 and start php-fpm
EXPOSE 80
CMD ["apache2-foreground"]
