init_db:
	docker-compose run --rm db psql -h db -U postgres -d weight_keeper < priv/init_db.sql

psql:
	docker-compose run --rm db psql -h db -U postgres -d weight_keeper
