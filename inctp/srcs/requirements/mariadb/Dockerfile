# Используем минимальный стабильный образ Debian
FROM debian:11.11

# Устанавливаем MariaDB-сервер и клиент
RUN apt-get update && apt-get install -y \
	mariadb-server mariadb-client && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Создаём нужные директории для работы демона MariaDB
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Копируем конфиг и скрипт инициализации
COPY ./tools/init.sh /usr/local/bin/init.sh
COPY ./conf/my.cnf /etc/mysql/my.cnf

# Устанавливаем права на скрипт и указываем его как точку входа
RUN chmod +x /usr/local/bin/init.sh
ENTRYPOINT ["/usr/local/bin/init.sh"]

# Запускаем MariaDB после инициализации
CMD ["mariadbd", "--user=mysql"]
