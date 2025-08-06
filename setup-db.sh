#!/bin/bash
set -e

# Path to the wp-config.php file
WP_CONFIG_PATH="/var/www/html/wp-config.php"

# Check if wp-config.php exists. If not, the official entrypoint will create it.
if [ -f "$WP_CONFIG_PATH" ]; then
    echo "wp-config.php found. Checking database connection..."

    # Check if we can connect to the database with the current credentials
    if ! wp db check --allow-root; then
        echo "Database connection failed. Re-configuring wp-config.php..."
        
        # Use wp-cli to configure the database.
        # This will update the existing wp-config.php with new values.
        wp config set DB_HOST "$WORDPRESS_DB_HOST" --allow-root
        wp config set DB_NAME "$WORDPRESS_DB_NAME" --allow-root
        wp config set DB_USER "$WORDPRESS_DB_USER" --allow-root
        wp config set DB_PASSWORD "$WORDPRESS_DB_PASSWORD" --allow-root
        
        # Set the table prefix if it's defined
        if [ -n "$WORDPRESS_TABLE_PREFIX" ]; then
            wp config set table_prefix "$WORDPRESS_TABLE_PREFIX" --allow-root
            echo "Database table prefix set to: $WORDPRESS_TABLE_PREFIX"
        fi
        
        echo "wp-config.php has been re-configured."
    else
        echo "Database connection successful. No changes needed."
    fi
else
    echo "wp-config.php not found. The official entrypoint will create it."
    # We can also set the table prefix for the initial setup
    if [ -n "$WORDPRESS_TABLE_PREFIX" ]; then
        wp config set table_prefix "$WORDPRESS_TABLE_PREFIX" --allow-root
        echo "Database table prefix will be set to: $WORDPRESS_TABLE_PREFIX"
    fi
fi
