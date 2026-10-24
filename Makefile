# Runs the Eureka server (ServiceDiscoveryApplication) on its own. SERVER_PORT comes from the gitignored
# .env when it exists (see .env.example); without it the default in application.properties applies (8761).
# The root Makefile of the monorepo runs the whole stack instead.
#
#   make up         build if needed and run the registry in the foreground on :8761
#   make docker-up  run it as a container built from the Dockerfile instead

SHELL      := /bin/bash
.DEFAULT_GOAL := help

JAR        := target/ServiceDiscoveryApplication-0.0.1-SNAPSHOT.jar
SKIP_TESTS ?= true

# Export .env for one recipe line when present. Sourced by the shell (not `include`) so quoted values work.
WITH_ENV = set -a; [ ! -f ./.env ] || . ./.env; set +a;

.PHONY: help up jar run test clean docker-up docker-down

help: ## Show this help
	@grep -hE '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-12s %s\n", $$1, $$2}'

up: run ## Build and run the registry in the foreground (http://localhost:8761)

jar: ## Build the jar (tests skipped by default; use SKIP_TESTS=false to run them)
	@./mvnw clean package -DskipTests=$(SKIP_TESTS)
	@echo "Built $(JAR)"

run: ## Run the jar with .env loaded (builds it first if missing)
	@test -f $(JAR) || $(MAKE) --no-print-directory jar
	@$(WITH_ENV) java -jar $(JAR)

test: ## Run the tests
	@./mvnw test

clean: ## Delete target/
	@./mvnw clean

docker-up: ## Build the image and start the registry as a container (http://localhost:8761)
	docker compose up -d --build --wait

docker-down: ## Stop and remove the registry container
	docker compose down
