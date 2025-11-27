#!/bin/bash
set -e

echo "WoWonder Docker Entrypoint Starting..."

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
until mysqladmin ping -h${DB_HOST:-mariadb} -u${DB_USER:-wowonder_user} -p${DB_PASSWORD:-wowonder_pass} --silent; do
  echo 'MySQL is unavailable - sleeping'
  sleep 2
done
echo "MySQL is up"

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
until redis-cli -h ${REDIS_HOST:-redis} -p ${REDIS_PORT:-6379} ping > /dev/null 2>&1; do
  echo 'Redis is unavailable - sleeping'
  sleep 2
done
echo "Redis is up"

# Create config.php if it doesn't exist
if [ ! -f /var/www/html/config.php ]; then
  echo "Creating config.php..."
  cat > /var/www/html/config.php << 'EOF'
<?php
// Database Configuration
$sql_db_host = getenv('DB_HOST') ?: 'localhost';
$sql_db_user = getenv('DB_USER') ?: 'wowonder_user';
$sql_db_pass = getenv('DB_PASSWORD') ?: 'wowonder_pass';
$sql_db_name = getenv('DB_NAME') ?: 'wowonder';

// Redis Configuration
$redis_host = getenv('REDIS_HOST') ?: 'localhost';
$redis_port = getenv('REDIS_PORT') ?: 6379;
$redis_password = getenv('REDIS_PASSWORD') ?: '';

// Site Configuration
$site_url = getenv('SITE_URL') ?: 'http://localhost';
$purchase_code = getenv('PURCHASE_CODE') ?: 'docker-development';

// Security Settings
$site_key = getenv('SITE_KEY') ?: bin2hex(random_bytes(32));

// Development/Production Mode
$developer_mode = getenv('DEVELOPER_MODE') ? 1 : 0;

// Session Configuration (using Redis)
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', "tcp://{$redis_host}:{$redis_port}");
if (!empty($redis_password)) {
    ini_set('session.save_path', "tcp://{$redis_host}:{$redis_port}?auth={$redis_password}");
}

// Cache Configuration
define('CACHE_DRIVER', 'redis');
EOF
  chmod 644 /var/www/html/config.php
  echo "config.php created successfully"
fi

# Create nodejs/config.json if it doesn't exist
if [ ! -f /var/www/html/nodejs/config.json ]; then
  echo "Creating nodejs/config.json..."
  cat > /var/www/html/nodejs/config.json << 'EOF'
{
    "sql_db_host": "DB_HOST_PLACEHOLDER",
    "sql_db_user": "DB_USER_PLACEHOLDER",
    "sql_db_pass": "DB_PASSWORD_PLACEHOLDER",
    "sql_db_name": "DB_NAME_PLACEHOLDER",
    "redis_host": "REDIS_HOST_PLACEHOLDER",
    "redis_port": "REDIS_PORT_PLACEHOLDER",
    "site_url": "SITE_URL_PLACEHOLDER",
    "purchase_code": "docker-development"
}
EOF
  
  # Replace placeholders with actual values
  sed -i "s|DB_HOST_PLACEHOLDER|${DB_HOST:-mariadb}|g" /var/www/html/nodejs/config.json
  sed -i "s|DB_USER_PLACEHOLDER|${DB_USER:-wowonder_user}|g" /var/www/html/nodejs/config.json
  sed -i "s|DB_PASSWORD_PLACEHOLDER|${DB_PASSWORD:-wowonder_pass}|g" /var/www/html/nodejs/config.json
  sed -i "s|DB_NAME_PLACEHOLDER|${DB_NAME:-wowonder}|g" /var/www/html/nodejs/config.json
  sed -i "s|REDIS_HOST_PLACEHOLDER|${REDIS_HOST:-redis}|g" /var/www/html/nodejs/config.json
  sed -i "s|REDIS_PORT_PLACEHOLDER|${REDIS_PORT:-6379}|g" /var/www/html/nodejs/config.json
  sed -i "s|SITE_URL_PLACEHOLDER|${SITE_URL:-http://localhost}|g" /var/www/html/nodejs/config.json
  
  chmod 644 /var/www/html/nodejs/config.json
  echo "nodejs/config.json created successfully"
fi

# Start Redis if not running in a separate container
if [ "${START_REDIS:-false}" = "true" ]; then
  echo "Starting Redis in background..."
  redis-server /etc/redis/redis.conf &
  REDIS_PID=$!
  sleep 2
fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 777 /var/www/html/upload 2>/dev/null || true

echo "Docker entrypoint setup complete"
echo "Starting Apache..."

# Execute the main command
exec "$@"
