# ---------- БАЗОВЫЙ ОБРАЗ ----------------------------------------------------
FROM debian:11.11

# ---------- УСТАНОВКА NGINX + OPENSSL -----------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------- ПАПКИ ДЛЯ TLS И PID --------------------------------
RUN mkdir -p /etc/nginx/ssl /run/nginx

# ---------- ГЕНЕРАЦИЯ САМОПОДПИСАННОГО СЕРТИФИКАТА ----------
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=FR/ST=PACA/L=Nice/O=42Nice/OU=zserobia/CN=zserobia.42.fr" \
    -keyout /etc/nginx/ssl/zserobia.42.fr.key \
    -out   /etc/nginx/ssl/zserobia.42.fr.crt

# ---------- КОНФИГ NGINX -------------------------------------
COPY ./tools/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
