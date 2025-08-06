# Object Cache Pro Plugin Directory

## Instructions:

1. **Download Object Cache Pro** from your account at https://objectcache.pro/
2. **Extract the ZIP file** 
3. **Copy all the plugin files** into this directory (`wp-content/plugins/object-cache-pro/`)
4. **Make sure the main plugin file** `object-cache-pro.php` is in this directory
5. **Deploy to Railway** - the plugin will be automatically activated

## Expected Structure:
```
wp-content/plugins/object-cache-pro/
├── object-cache-pro.php          (main plugin file)
├── stubs/
│   └── object-cache.php          (drop-in file)
├── src/
├── composer.json
└── (other plugin files...)
```

## Auto-Activation:
- ✅ Plugin will be automatically activated on container start
- ✅ Drop-in will be automatically installed
- ✅ Object cache will be automatically enabled
- ✅ Works for both new and existing WordPress installations

The activation script will handle everything automatically once you upload the plugin files here.
