FROM wordpress:latest

# Install sudo and dependencies for GD library
RUN apt-get update && apt-get install -y sudo libpng-dev && rm -rf /var/lib/apt/lists/*

# Install redis extension
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Copy custom entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

# Copy wp-content
COPY ./wp-content /var/www/html/wp-content/

# Re-apply WordPress permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80 and start php-fpm
EXPOSE 80
CMD ["apache2-foreground"]
