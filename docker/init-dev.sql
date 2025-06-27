-- Development database initialization
-- This script sets up the development database with sample data

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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_transformations_created_at ON transformations(createdAt);
CREATE INDEX IF NOT EXISTS idx_transformations_style ON transformations(style);

-- Insert sample data for development
INSERT INTO transformations (id, imageUrl, thumbnailUrl, prompt, style, createdAt, localPath) VALUES
('dev_sample_1', 'https://example.com/sample1.png', 'https://example.com/sample1_thumb.png', 'A beautiful sunset over mountains', 'artistic', NOW() - INTERVAL '2 days', NULL),
('dev_sample_2', 'https://example.com/sample2.png', 'https://example.com/sample2_thumb.png', 'Modern city skyline at night', 'futuristic', NOW() - INTERVAL '1 day', '/local/sample2.png'),
('dev_sample_3', 'https://example.com/sample3.png', 'https://example.com/sample3_thumb.png', 'Vintage portrait of a classic car', 'vintage', NOW() - INTERVAL '3 hours', NULL),
('dev_sample_4', 'https://example.com/sample4.png', 'https://example.com/sample4_thumb.png', 'Abstract geometric patterns', 'abstract', NOW() - INTERVAL '1 hour', '/local/sample4.png')
ON CONFLICT (id) DO NOTHING;

-- Create a user for the application (if needed for future features)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    preferences JSONB DEFAULT '{}'
);

-- Insert a sample user
INSERT INTO users (email, preferences) VALUES
('dev@example.com', '{"theme": "dark", "defaultStyle": "artistic"}')
ON CONFLICT (email) DO NOTHING;