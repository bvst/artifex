# Artifex Docker Development Environment

This directory contains Docker configuration for local development and testing databases.

## Quick Start

```bash
# Start development database
make dev-up

# Start test database  
make test-up

# View all available commands
make help
```

## Database Setup

### Development Database
- **Host**: localhost:5430
- **Database**: artifex_dev
- **User**: artifex_user
- **Password**: artifex_dev_password
- **Persistent**: Yes (data survives container restarts)
- **Sample Data**: Yes (includes sample transformations)

### Test Database
- **Host**: localhost:5433
- **Database**: artifex_test
- **User**: artifex_test_user
- **Password**: artifex_test_password
- **Persistent**: No (clean slate for each test run)
- **Sample Data**: No (starts empty)

## Usage

### Starting Databases

```bash
# Start development environment (database + redis)
make dev-up

# Start only test database
make test-up

# Start everything
docker-compose up -d
```

### Connecting to Databases

#### Development Database
```bash
# Using psql
psql -h localhost -p 5430 -U artifex_user -d artifex_dev

# Using Docker exec
docker-compose exec artifex-dev-db psql -U artifex_user -d artifex_dev
```

#### Test Database
```bash
# Using psql  
psql -h localhost -p 5433 -U artifex_test_user -d artifex_test

# Using Docker exec
docker-compose exec artifex-test-db psql -U artifex_test_user -d artifex_test
```

### Managing Data

```bash
# Reset development database with fresh sample data
make reset-dev

# Reset test database (clean slate)
make reset-test

# View database logs
make logs

# Stop databases
make dev-down
make test-down

# Clean up everything (removes all data)
make clean
```

## Integration with Flutter

### Development
For local development, you can optionally connect your Flutter app to the PostgreSQL database instead of SQLite. This allows you to:
- View and manipulate data easily with SQL tools
- Test with larger datasets
- Debug database queries
- Share data between development sessions

### Testing
Integration tests can use either:
1. **In-memory SQLite** (faster, for unit-style tests)
2. **Test PostgreSQL** (more realistic, for integration tests)

## Schema

The databases use the same schema as the SQLite database but with PostgreSQL-specific optimizations:

```sql
-- Transformations table
CREATE TABLE transformations (
    id TEXT PRIMARY KEY,
    imageUrl TEXT NOT NULL,
    thumbnailUrl TEXT NOT NULL,
    prompt TEXT NOT NULL,
    style TEXT NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    localPath TEXT
);

-- Indexes for performance
CREATE INDEX idx_transformations_created_at ON transformations(createdAt);
CREATE INDEX idx_transformations_style ON transformations(style);
```

## Environment Variables

You can override database settings using environment variables:

```bash
# Development database
export POSTGRES_DEV_HOST=localhost
export POSTGRES_DEV_PORT=5430
export POSTGRES_DEV_DB=artifex_dev
export POSTGRES_DEV_USER=artifex_user
export POSTGRES_DEV_PASSWORD=artifex_dev_password

# Test database
export POSTGRES_TEST_HOST=localhost
export POSTGRES_TEST_PORT=5433
export POSTGRES_TEST_DB=artifex_test
export POSTGRES_TEST_USER=artifex_test_user
export POSTGRES_TEST_PASSWORD=artifex_test_password
```

## Troubleshooting

### Database Won't Start
```bash
# Check if ports are available
sudo netstat -tlnp | grep :5430
sudo netstat -tlnp | grep :5433

# Check container logs
docker-compose logs artifex-dev-db
docker-compose logs artifex-test-db

# Reset everything
make clean
make dev-up
```

### Connection Issues
```bash
# Test database connectivity
docker-compose exec artifex-dev-db pg_isready -U artifex_user -d artifex_dev

# Check if database is accepting connections
telnet localhost 5430
```

### Data Issues
```bash
# View sample data in development
docker-compose exec artifex-dev-db psql -U artifex_user -d artifex_dev -c "SELECT * FROM transformations;"

# Reset with fresh data
make reset-dev
```

## Redis Cache (Optional)

A Redis container is also available for future caching needs:
- **Host**: localhost:6379
- **Persistent**: Yes (data survives container restarts)

```bash
# Connect to Redis
docker-compose exec artifex-redis redis-cli

# Test Redis
docker-compose exec artifex-redis redis-cli ping
```