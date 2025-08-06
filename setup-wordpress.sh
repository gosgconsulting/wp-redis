#!/bin/bash

set -e

# wait for DB to be ready
while ! mysqladmin ping -hdb -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    echo "Waiting for database connection..."
    sleep 2
done


# Check if WordPress is installed
if ! $(wp core is-installed); then
    echo "WordPress is not installed. Installing..."

    # Install WordPress
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL"

    echo "WordPress installed successfully."
else
    echo "WordPress is already installed."
fi
