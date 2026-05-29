#!/bin/sh
set -e

cd /var/www/html

# Auto-generate APP_KEY if not set (handles CI and first-run scenarios)
if [ -z "$(grep '^APP_KEY=base64:' .env)" ]; then
  echo "APP_KEY not set — generating one now..."
  php artisan key:generate --force --no-interaction
fi

php artisan config:clear --no-interaction 2>/dev/null || true
php artisan migrate --force --no-interaction

exec "$@"
