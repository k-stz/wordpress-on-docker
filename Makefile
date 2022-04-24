# Build the entire Application by calling `docker-compose.yml`
up:
	cd srcs && docker compose up

detach:
	cd srcs && docker compose up -d

down:
	cd srcs && docker compose down 

rebuild:
	cd srcs && docker compose up --build
