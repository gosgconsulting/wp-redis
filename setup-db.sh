#!/bin/bash
set -e

# Path to the wp-config.php file
WP_CONFIG_PATH="/var/www/html/wp-config.php"

# This script will only run if wp-config.php already exists.
# If wp-config.php does not exist, it means this is a fresh installation.
# The official WordPress entrypoint script will create wp-config.php for us,
# using the WORDPRESS_* environment variables from docker-compose.yml.
if [ ! -f "$WP_CONFIG_PATH" ]; then
    echo "wp-config.php not found, skipping DB configuration check. The official entrypoint will handle it."
    exit 0
fi

echo "wp-config.php found. Checking database connection..."

# If we have a wp-config.php, we can check if the DB connection works.
# If it fails, it might be because the credentials in the .env file have
# changed. In that case, we'll update wp-config.php.
if ! wp db check --allow-root; then
    echo "Database connection failed. Re-configuring wp-config.php with current environment variables..."
    
    # Use wp-cli to update the database credentials in wp-config.php.
    wp config set DB_HOST "$WORDPRESS_DB_HOST" --allow-root
    wp config set DB_NAME "$WORDPRESS_DB_NAME" --allow-root
    wp config set DB_USER "$WORDPRESS_DB_USER" --allow-root
    wp config set DB_PASSWORD "$WORDPRESS_DB_PASSWORD" --allow-root
    
    # Also update the table prefix if it's defined in the environment.
    if [ -n "$WORDPRESS_TABLE_PREFIX" ]; then
        wp config set table_prefix "$WORDPRESS_TABLE_PREFIX" --allow-root
        echo "Database table prefix updated to: $WORDPRESS_TABLE_PREFIX"
    fi
    
    echo "wp-config.php has been re-configured."
else
    echo "Database connection successful. No changes needed."
fi
