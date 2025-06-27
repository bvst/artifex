-- Test database initialization
-- This script sets up a clean test database

-- Create the transformations table (matches your SQLite schema)
CREATE TABLE IF NOT EXISTS transformations (
    id TEXT PRIMARY KEY,
    imageUrl TEXT NOT NULL,
    thumbnailUrl TEXT NOT NULL,
    prompt TEXT NOT NULL,
    style TEXT NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    localPath TEXT
);

-- Create indexes for better performance in tests
CREATE INDEX IF NOT EXISTS idx_transformations_created_at ON transformations(createdAt);
CREATE INDEX IF NOT EXISTS idx_transformations_style ON transformations(style);

-- Create users table for future testing
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    preferences JSONB DEFAULT '{}'
);

-- No sample data for tests - tests should start with clean state