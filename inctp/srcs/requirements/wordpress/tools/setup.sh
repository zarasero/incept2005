#!/bin/sh

echo "▶️ Запуск настройки WordPress..."

WP_PATH="/var/www/html"

# Ожидаем подключения к базе данных
until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME" 2>/dev/null; do
  echo "⏳ Ожидание базы данных $DB_NAME..."
  sleep 2
done

# Установка WordPress, если он ещё не установлен
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "📦 Установка WordPress..."

  # Скачиваем и устанавливаем wp-cli
  curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

  # Загружаем ядро WordPress
  wp core download --path="$WP_PATH" --allow-root

  # Создаём wp-config.php
  wp config create --allow-root \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$DB_HOST" \
    --path="$WP_PATH"

  # Устанавливаем сайт
  wp core install --allow-root \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --path="$WP_PATH"

  echo "✅ WordPress установлен."

  # --- Автоматическое создание пользователя Lana ---
  if ! wp user get "$WP_USER" --allow-root --path="$WP_PATH" > /dev/null 2>&1; then
      wp user create "$WP_USER" "$WP_USER_EMAIL" --role=subscriber --user_pass="$WP_USER_PASSWORD" --allow-root --path="$WP_PATH"
      echo "✅ Пользователь '$WP_USER' создан."
  else
      echo "ℹ️ Пользователь '$WP_USER' уже существует."
  fi

else
  echo "ℹ️ WordPress уже установлен, пропускаем установку."
fi

# Настройка php-fpm: прослушивание на порту 9000
sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Запуск php-fpm или другой переданной команды
if [ $# -eq 0 ]; then
  exec php-fpm8.2 -F
else
  exec "$@"
fi

