#!/bin/sh

# Inject Cloud Run environment variables into the built Vite app (static files)
# This replaces the placeholder we set in vite.config.ts

# Ensure GEMINI_API_KEY has a value or is empty string
TARGET_KEY=${GEMINI_API_KEY:-""}

echo "Injecting GEMINI_API_KEY into frontend assets..."

# Find all built JS and HTML files and replace the placeholder
find /app/dist -type f \( -name "*.js" -o -name "*.html" \) -exec sed -i "s|VITE_RUNTIME_ENV_GEMINI_API_KEY|${TARGET_KEY}|g" {} +

# Execute the main process
exec "$@"
