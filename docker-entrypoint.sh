#!/bin/sh
set -e

# Ensure wp-content and its subdirectories are owned by www-data
# This allows for installing/updating plugins and themes from the WP admin.
chown -R www-data:www-data /var/www/html/wp-content

# Execute the original WordPress entrypoint
exec "/usr/local/bin/docker-entrypoint.sh" "$@"
