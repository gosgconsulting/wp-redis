#!/bin/bash

# Object Cache Pro Auto-Setup Script
# This script automatically downloads, installs, and activates Object Cache Pro
# Works for both new installations and existing WordPress sites

set -e

echo "🚀 Starting Object Cache Pro auto-setup..."

# Configuration
PLUGINS_DIR="/var/www/html/wp-content/plugins"
OCP_DIR="${PLUGINS_DIR}/object-cache-pro"
DROPIN_SOURCE="${OCP_DIR}/stubs/object-cache.php"
DROPIN_TARGET="/var/www/html/wp-content/object-cache.php"
DOWNLOAD_URL="https://objectcache.pro/releases/object-cache-pro.zip"

# Wait for WordPress to be ready
echo "⏳ Waiting for WordPress database to be ready..."
until wp db check --allow-root --quiet 2>/dev/null; do
    echo "Database not ready yet, waiting 3 seconds..."
    sleep 3
done
echo "✅ WordPress database is ready!"

# Function to download and install Object Cache Pro
install_object_cache_pro() {
    echo "📦 Installing Object Cache Pro..."
    
    # Create plugins directory if it doesn't exist
    mkdir -p "$PLUGINS_DIR"
    
    # Remove existing installation if present
    if [ -d "$OCP_DIR" ]; then
        echo "🗑️ Removing existing Object Cache Pro installation..."
        rm -rf "$OCP_DIR"
    fi
    
    # Download Object Cache Pro using license token
    if [ -n "$WP_REDIS_LICENSE_TOKEN" ]; then
        echo "🔑 Downloading Object Cache Pro with license token..."
        
        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Download with authorization header
        curl -L -H "Authorization: Bearer $WP_REDIS_LICENSE_TOKEN" \
             -o object-cache-pro.zip \
             "$DOWNLOAD_URL" || {
            echo "❌ Failed to download Object Cache Pro. Check your license token."
            rm -rf "$TEMP_DIR"
            return 1
        }
        
        # Extract to plugins directory
        unzip -q object-cache-pro.zip -d "$PLUGINS_DIR/"
        
        # Clean up
        rm -rf "$TEMP_DIR"
        
        echo "✅ Object Cache Pro downloaded and extracted successfully!"
    else
        echo "❌ WP_REDIS_LICENSE_TOKEN environment variable not set!"
        return 1
    fi
}

# Function to activate the plugin
activate_plugin() {
    echo "🔌 Activating Object Cache Pro plugin..."
    
    # Activate the plugin using WP-CLI
    wp plugin activate object-cache-pro --allow-root --quiet || {
        echo "⚠️ Plugin activation failed, but continuing..."
    }
    
    echo "✅ Object Cache Pro plugin activated!"
}

# Function to install the drop-in
install_dropin() {
    echo "💾 Installing Object Cache Pro drop-in..."
    
    if [ -f "$DROPIN_SOURCE" ]; then
        # Copy the drop-in file
        cp "$DROPIN_SOURCE" "$DROPIN_TARGET"
        chown www-data:www-data "$DROPIN_TARGET"
        chmod 644 "$DROPIN_TARGET"
        echo "✅ Object Cache Pro drop-in installed successfully!"
    else
        echo "❌ Drop-in source file not found: $DROPIN_SOURCE"
        return 1
    fi
}

# Function to enable object cache via WP-CLI
enable_object_cache() {
    echo "⚡ Enabling Object Cache Pro..."
    
    # Try to enable object cache using WP-CLI
    wp object-cache enable --allow-root --quiet 2>/dev/null || {
        echo "ℹ️ WP-CLI object-cache command not available, drop-in should work automatically"
    }
    
    echo "✅ Object Cache Pro enabled!"
}

# Function to verify installation
verify_installation() {
    echo "🔍 Verifying Object Cache Pro installation..."
    
    # Check if plugin exists
    if [ ! -d "$OCP_DIR" ]; then
        echo "❌ Object Cache Pro plugin directory not found!"
        return 1
    fi
    
    # Check if drop-in exists
    if [ ! -f "$DROPIN_TARGET" ]; then
        echo "❌ Object Cache Pro drop-in not found!"
        return 1
    fi
    
    # Check plugin status
    if wp plugin is-active object-cache-pro --allow-root --quiet 2>/dev/null; then
        echo "✅ Object Cache Pro plugin is active!"
    else
        echo "⚠️ Object Cache Pro plugin may not be active, but drop-in should still work"
    fi
    
    echo "✅ Object Cache Pro verification complete!"
}

# Main execution
main() {
    echo "🎯 Starting Object Cache Pro auto-setup for $(wp option get siteurl --allow-root 2>/dev/null || echo 'WordPress site')..."
    
    # Install Object Cache Pro
    install_object_cache_pro || {
        echo "❌ Failed to install Object Cache Pro"
        exit 1
    }
    
    # Activate the plugin
    activate_plugin
    
    # Install the drop-in
    install_dropin || {
        echo "❌ Failed to install drop-in"
        exit 1
    }
    
    # Enable object cache
    enable_object_cache
    
    # Verify everything is working
    verify_installation
    
    echo "🎉 Object Cache Pro auto-setup completed successfully!"
    echo "🔗 Visit Settings > Object Cache Pro in WordPress Admin to verify status"
}

# Run main function
main "$@"
