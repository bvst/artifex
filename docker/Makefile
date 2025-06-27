# Artifex Docker Development Commands

.PHONY: help dev-up dev-down test-up test-down clean logs reset-dev reset-test

help:
	@echo "Artifex Docker Commands:"
	@echo "  dev-up      - Start development database"
	@echo "  dev-down    - Stop development database"
	@echo "  test-up     - Start test database"
	@echo "  test-down   - Stop test database"
	@echo "  clean       - Remove all containers and volumes"
	@echo "  logs        - View logs from databases"
	@echo "  reset-dev   - Reset development database with fresh data"
	@echo "  reset-test  - Reset test database"

dev-up:
	docker-compose up -d artifex-dev-db artifex-redis
	@echo "Development database starting on localhost:5430"
	@echo "Redis cache starting on localhost:6379"
	@echo "Waiting for database to be ready..."
	@sleep 5
	@docker-compose exec artifex-dev-db pg_isready -U artifex_user -d artifex_dev && echo "✅ Development database is ready!"

dev-down:
	docker-compose stop artifex-dev-db artifex-redis

test-up:
	docker-compose up -d artifex-test-db
	@echo "Test database starting on localhost:5433"
	@echo "Waiting for test database to be ready..."
	@sleep 3
	@docker-compose exec artifex-test-db pg_isready -U artifex_test_user -d artifex_test && echo "✅ Test database is ready!"

test-down:
	docker-compose stop artifex-test-db

clean:
	docker-compose down -v
	docker volume prune -f
	@echo "🧹 All containers and volumes removed"

logs:
	docker-compose logs -f

reset-dev:
	docker-compose stop artifex-dev-db
	docker-compose rm -f artifex-dev-db
	docker volume rm artifex_artifex_dev_data 2>/dev/null || true
	docker-compose up -d artifex-dev-db
	@echo "🔄 Development database reset with fresh sample data"

reset-test:
	docker-compose stop artifex-test-db
	docker-compose rm -f artifex-test-db
	docker-compose up -d artifex-test-db
	@echo "🔄 Test database reset"