#!/bin/sh

echo "▶️ Инициализация MariaDB..."

# Проверка: если MariaDB ещё не установлен
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "📦 Установка MariaDB..."
	mkdir -p /var/lib/mysql /run/mysqld
	chown -R mysql:mysql /var/lib/mysql /run/mysqld

	# Настраиваем доступ к сети
	sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
	sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

	# Устанавливаем систему
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
else
	echo "✅ MariaDB уже установлен"
fi

# Проверка: существует ли база данных
if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
	echo "⚙️ Создание базы данных и пользователя..."

	cat << EOF > /tmp/setup.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	mariadbd --user=mysql --bootstrap --verbose=0 < /tmp/setup.sql
	rm -f /tmp/setup.sql

	echo "✅ База данных '${DB_NAME}' создана."
else
	echo "ℹ️ База данных '${DB_NAME}' уже существует."
fi

# Запускаем MariaDB как основной процесс
exec "$@"
