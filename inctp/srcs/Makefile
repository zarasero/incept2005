
COMPOSE_FILE = ./requirements/docker-compose.yml


# Цвета (для ошибок)
RED   = \e[1;91m
RESET = \033[0m


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
	sudo rm -rf /home/zserobia/data/mariadb
	sudo rm -rf /home/zserobia/data/wordpress
	@docker network rm inception 2>/dev/null || true


re: clean all

.PHONY: run up clean re
