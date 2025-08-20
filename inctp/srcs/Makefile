# Пути
COMPOSE_FILE = ./requirements/docker-compose.yml



# Цвета (для ошибок)
RED   = \e[1;91m
RESET = \033[0m

# --- Цели ---


all: run

run:
	mkdir -p /home/zserobia/data/mariadb
	mkdir -p /home/zserobia/data/wordpress
	docker-compose -f $(COMPOSE_FILE) up --build -d

up:
	mkdir -p /home/zserobia/data/mariadb
	mkdir -p /home/zserobia/data/wordpress
	docker-compose -f $(COMPOSE_FILE) up --build -d

clean:
	docker-compose -f $(COMPOSE_FILE) down -v --rmi all --remove-orphans
	rm -rf /home/zserobia/data/mariadb
	rm -rf /home/zserobia/data/wordpress
	@docker network rm inception 2>/dev/null || true


# Перезапуск: пересборка + запуск
re: clean all

.PHONY: run up clean re
