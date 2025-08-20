FROM debian:11.11

# Устанавливаем curl и gnupg для добавления репозитория
RUN apt-get update && apt-get install -y \
    curl \
    lsb-release \
    gnupg2

# Добавляем репозиторий PHP от Sury
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg

# Обновляем пакеты и устанавливаем PHP 8.2
RUN apt-get update && apt-get install -y \
    mariadb-client \
    php8.2 php8.2-fpm php8.2-mysql \
    php8.2-curl php8.2-xml php8.2-zip php8.2-mbstring php8.2-intl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Создаём нужные директории
RUN mkdir -p /run/php /var/www/html

# Копируем скрипт установки WordPress
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh


EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm8.2", "-F"]
