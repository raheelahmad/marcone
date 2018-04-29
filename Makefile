build:
	docker-compose build
run:
	docker-compose up db web

test:
	docker-compose up db test

db:
	docker-compose up db

down:
	docker-compose down
