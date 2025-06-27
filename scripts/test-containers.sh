#!/bin/bash

set -e

echo "🐳 Testing Artifex Database Containers"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose is not installed or not in PATH"
    exit 1
fi

print_status "Docker and docker-compose are available"

# Start test database
echo ""
echo "🚀 Starting test database container..."
cd docker
make test-up

# Wait a moment for the database to be fully ready
echo ""
echo "⏳ Waiting for database to be ready..."
sleep 5

# Test database connectivity
echo ""
echo "🔌 Testing database connectivity..."

# Test with psql if available
if command -v psql &> /dev/null; then
    if PGPASSWORD=artifex_test_password psql -h localhost -p 5433 -U artifex_test_user -d artifex_test -c "SELECT 1;" &> /dev/null; then
        print_status "Database connection successful"
    else
        print_error "Failed to connect to database"
        exit 1
    fi
else
    print_warning "psql not available, skipping direct database test"
fi

# Test using Docker exec
echo ""
echo "🐳 Testing database via Docker exec..."
if docker-compose exec -T artifex-test-db psql -U artifex_test_user -d artifex_test -c "SELECT 1;" &> /dev/null; then
    print_status "Docker exec database test successful"
else
    print_error "Docker exec database test failed"
    exit 1
fi

# Test table creation
echo ""
echo "📋 Testing table operations..."
docker-compose exec -T artifex-test-db psql -U artifex_test_user -d artifex_test -c "
    INSERT INTO transformations (id, imageUrl, thumbnailUrl, prompt, style, createdAt) 
    VALUES ('test_script', 'https://example.com/test.png', 'https://example.com/test_thumb.png', 'Test prompt', 'artistic', NOW());
"

# Verify the insert
RECORD_COUNT=$(docker-compose exec -T artifex-test-db psql -U artifex_test_user -d artifex_test -t -c "SELECT COUNT(*) FROM transformations WHERE id = 'test_script';" | tr -d ' \n')

if [ "$RECORD_COUNT" = "1" ]; then
    print_status "Table operations working correctly"
else
    print_error "Table operations failed (expected 1 record, got $RECORD_COUNT)"
    exit 1
fi

# Clean up test data
docker-compose exec -T artifex-test-db psql -U artifex_test_user -d artifex_test -c "DELETE FROM transformations WHERE id = 'test_script';"

# Stop test database
echo ""
echo "🛑 Stopping test database..."
make test-down

print_status "All container tests passed!"
echo ""
echo "📝 To run the integration tests:"
echo "   1. Start test database: make test-up"
echo "   2. Run tests: flutter test test/integration/database_container_test.dart"
echo "   3. Stop database: make test-down"