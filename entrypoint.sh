#!/bin/sh

set -e

echo "Fixing permissions for Laravel..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# 1. Migrate trước
echo "Running migrations..."
composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan migrate --force --no-interaction

# 2. Chỉ seed nếu DB trống
USER_COUNT=$(php artisan tinker --execute='echo DB::table("users")->count();')
if [ "$USER_COUNT" = "0" ]; then
    echo "Fresh database detected. Running seeders..."
    php artisan db:seed --force --no-interaction

else
    echo "Database already seeded. Skipping seeders."
fi
# Chạy lệnh mặc định (php-fpm hoặc lệnh bạn truyền vào)
exec "$@"
