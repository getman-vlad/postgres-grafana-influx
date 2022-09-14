# Usage: make COMMAND
#
# Commands
#   help                    Show help message.
#   postgres-console        Login to postgres interactive terminal.
#   postgres-create-db      Create postgres database.
#   postgres-init-schema    Initialize postgres schema.
#   postgres-copy-data      Write data to postgres tables.
#   postgres-delete-tables  Delete postgres tables.
#   influx-console          Login to InfluxDB CLI.
#   influx-copy-data        Write data to InfluxDB.
#   build                   Build application.
#   service                 Start up application.
#   data-server             Serve data directory.
#   stop                    Stop running application.
#   clean                   Stop app and remove containers.
#   clean-all               Remove app, remove containers and volumes.
#
include .env

PSQL = PGPASSWORD=$(POSTGRES_PASSWORD) \
	docker exec -i $(POSTGRES_CONTAINER) \
	psql -h $(POSTGRES_HOST) -p 5432 -U $(POSTGRES_USER)

help:
	@head -18 Makefile

postgres-console:
	PGPASSWORD=$(POSTGRES_PASSWORD) \
	docker exec -it $(POSTGRES_CONTAINER) \
	psql -h $(POSTGRES_HOST) -p 5432 -U $(POSTGRES_USER) -d $(POSTGRES_DBNAME)

postgres-create-db:
	$(PSQL) -c "CREATE DATABASE $(POSTGRES_DBNAME)"

influx-console:
	docker exec -it $(INFLUX_CONTAINER) influx -database '$(INFLUX_DBNAME)'

build:
	docker-compose up -d
	make postgres-create-database
	make postgres-init-schema

service:
	docker-compose up -d

data-server:
	python -m http.server --directory ../data/

stop:
	docker-compose down

clean:
	make stop
	docker system prune -af

clean-all:
	make clean
	docker volume prune
