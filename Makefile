.PHONY: help setup up down restart logs status ps migrate buckets infra apps clean

# Default target
help:
	@echo ""
	@echo "ClientFacing Stack — Commands"
	@echo "=============================="
	@echo ""
	@echo "  make setup      First-time setup: generate .env with secrets"
	@echo "  make up         Start all services"
	@echo "  make down       Stop all services"
	@echo "  make restart    Restart all services"
	@echo "  make status     Show running containers + URLs"
	@echo "  make logs       Tail all logs"
	@echo "  make migrate    Run DB migrations (Chatwoot)"
	@echo "  make buckets    Create MinIO buckets (run after first 'make up')"
	@echo "  make infra      Start infrastructure only (postgres, redis, minio, mailpit)"
	@echo "  make apps       Start app services only (after infra is healthy)"
	@echo "  make clean      Remove all containers, volumes, and data (DESTRUCTIVE)"
	@echo ""
	@echo "Service URLs (after 'make up'):"
	@echo "  Chatwoot    http://localhost:3300  — support inbox"
	@echo "  Documenso   http://localhost:3301  — contracts"
	@echo "  Metabase    http://localhost:3302  — dashboards"
	@echo "  BookStack   http://localhost:3303  — docs"
	@echo "  Plane       http://localhost:3304  — projects (client + internal)"
	@echo "  n8n         http://localhost:5678  — automation"
	@echo "  MinIO       http://localhost:9001  — storage console"
	@echo "  Mailpit     http://localhost:8025  — email catcher"
	@echo ""

setup:
	@bash scripts/setup.sh

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f --tail=50

status: ps
	@echo ""
	@echo "Service URLs:"
	@echo "  Chatwoot    http://localhost:3300"
	@echo "  Documenso   http://localhost:3301"
	@echo "  Metabase    http://localhost:3302"
	@echo "  BookStack   http://localhost:3303"
	@echo "  Plane       http://localhost:3304"
	@echo "  n8n         http://localhost:5678"
	@echo "  MinIO       http://localhost:9001"
	@echo "  Mailpit     http://localhost:8025"

ps:
	docker compose ps

migrate:
	@bash scripts/migrate.sh

buckets:
	@bash scripts/create-buckets.sh

infra:
	docker compose up -d postgres mariadb redis minio mailpit

apps:
	docker compose up -d chatwoot chatwoot-worker documenso metabase bookstack n8n plane-web plane-api plane-worker plane-beat

# Logs for individual services
logs-%:
	docker compose logs -f --tail=100 $*

# Restart individual service
restart-%:
	docker compose restart $*

clean:
	@echo "WARNING: This will delete ALL data including volumes."
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	docker compose down -v --remove-orphans
