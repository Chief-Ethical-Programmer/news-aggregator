-- PostgreSQL Database Schema for News Aggregator

-- Articles table
CREATE TABLE IF NOT EXISTS articles (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    url TEXT UNIQUE NOT NULL,
    description TEXT,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    reasoning TEXT,
    category TEXT,
    keywords JSONB, -- JSON array stored as JSONB for better querying
    published_date TIMESTAMP,
    aggregated_date TIMESTAMP NOT NULL DEFAULT NOW(),
    source TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Weekly summaries table
CREATE TABLE IF NOT EXISTS weekly_summaries (
    id SERIAL PRIMARY KEY,
    week_start TIMESTAMP NOT NULL,
    week_end TIMESTAMP NOT NULL,
    must_reads JSONB, -- JSON array stored as JSONB
    analysis JSONB, -- JSON object for structured insights
    total_articles INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Newsletter subscribers table (for future newsletter feature)
CREATE TABLE IF NOT EXISTS subscribers (
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    subscribed_at TIMESTAMP DEFAULT NOW(),
    status TEXT DEFAULT 'active', -- active, unsubscribed, bounced
    preferences JSONB, -- JSON for subscription preferences
    unsubscribe_token TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Email sends tracking table
CREATE TABLE IF NOT EXISTS email_sends (
    id SERIAL PRIMARY KEY,
    subscriber_id INTEGER REFERENCES subscribers(id),
    email_type TEXT, -- daily, weekly, custom
    article_ids JSONB, -- Array of article IDs sent
    sent_at TIMESTAMP DEFAULT NOW(),
    status TEXT, -- sent, failed, bounced
    open_count INTEGER DEFAULT 0,
    last_opened_at TIMESTAMP
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_articles_rating ON articles(rating);
CREATE INDEX IF NOT EXISTS idx_articles_date ON articles(aggregated_date DESC);
CREATE INDEX IF NOT EXISTS idx_articles_category ON articles(category);
CREATE INDEX IF NOT EXISTS idx_articles_keywords ON articles USING GIN(keywords);
CREATE INDEX IF NOT EXISTS idx_weekly_date ON weekly_summaries(week_start DESC);
CREATE INDEX IF NOT EXISTS idx_subscribers_email ON subscribers(email);
CREATE INDEX IF NOT EXISTS idx_subscribers_status ON subscribers(status);
CREATE INDEX IF NOT EXISTS idx_email_sends_date ON email_sends(sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_email_sends_subscriber ON email_sends(subscriber_id);

-- Comments for documentation
COMMENT ON TABLE articles IS 'Stores all aggregated news articles with AI-based priority ratings';
COMMENT ON TABLE weekly_summaries IS 'Weekly analysis and summaries of top articles';
COMMENT ON TABLE subscribers IS 'Newsletter subscriber management';
COMMENT ON TABLE email_sends IS 'Tracks all email sends for analytics';

COMMENT ON COLUMN articles.rating IS 'Priority rating from 1-5 stars';
COMMENT ON COLUMN articles.keywords IS 'JSONB array of extracted keywords';
COMMENT ON COLUMN subscribers.preferences IS 'JSONB object for category preferences, frequency, etc.';
COMMENT ON COLUMN email_sends.article_ids IS 'JSONB array of article IDs included in the email';
