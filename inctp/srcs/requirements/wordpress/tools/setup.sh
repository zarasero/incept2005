#!/bin/sh

echo "▶️ Starting WordPress setup..."  # Print message: WordPress setup is starting

WP_PATH="/var/www/html"  # Set the path where WordPress will be installed

# Wait until the database is available
until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME" 2>/dev/null; do
  echo "⏳ Waiting for database $DB_NAME..."  # Print message: waiting for the database to be ready
  sleep 2  # Wait 2 seconds before retrying
done

# Install WordPress if it's not installed yet
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "📦 Installing WordPress..."  # Print message: WordPress installation started

  # Download and install wp-cli
  curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar  # Download wp-cli PHAR file
  chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp  # Make it executable and move to /usr/local/bin

  # Download WordPress core files
  wp core download --path="$WP_PATH" --allow-root  # Download WordPress into the specified path

  # Create wp-config.php
  wp config create --allow-root \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$DB_HOST" \
    --path="$WP_PATH"  # Generate WordPress configuration file with database credentials

  # Install WordPress site
  wp core install --allow-root \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --path="$WP_PATH"  # Complete WordPress installation with site info and admin user

  echo "✅ WordPress installed."  # Print message: WordPress installation complete

  # --- Automatically create user Lana ---
  if ! wp user get "$WP_USER" --allow-root --path="$WP_PATH" > /dev/null 2>&1; then
      wp user create "$WP_USER" "$WP_USER_EMAIL" --role=subscriber --user_pass="$WP_USER_PASSWORD" --allow-root --path="$WP_PATH"
      echo "✅ User '$WP_USER' created."  # Print message: user created
  else
      echo "ℹ️ User '$WP_USER' already exists."  # Print message: user already exists
  fi

else
  echo "ℹ️ WordPress already installed, skipping installation."  # Print message: WordPress already installed
fi

# Configure php-fpm to listen on port 9000
sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf  # Update www.conf to listen on TCP port 9000

# Start php-fpm or run another passed command
if [ $# -eq 0 ]; then
  exec php-fpm8.2 -F  # Start PHP-FPM in the foreground
else
  exec "$@"  # Run any other command passed as argument
fi
