# PostgreSQL Setup - Complete! ✅

## Database Configuration

**Database Name:** `news_aggregator`
**User:** `n8n_user`  
**Password:** See `.env` file (`POSTGRES_PASSWORD`)
**Host:** `postgres` (internal Docker network)
**Port:** `5432`

## Tables Created

### 1. **articles** - News Articles Storage
```sql
- id (PRIMARY KEY, auto-increment)
- title, url (unique), description
- rating (1-5 stars), reasoning, category
- keywords (JSONB array)
- published_date, aggregated_date
- source, created_at
```

### 2. **weekly_summaries** - Weekly Analysis
```sql
- id, week_start, week_end
- must_reads (JSONB), analysis (JSONB)
- total_articles, created_at
```

### 3. **subscribers** - Newsletter Management
```sql
- id, email (unique), name
- subscribed_at, status, preferences (JSONB)
- unsubscribe_token, created_at, updated_at
```

### 4. **email_sends** - Email Tracking
```sql
- id, subscriber_id, email_type
- article_ids (JSONB), sent_at, status
- open_count, last_opened_at
```

## Connecting from n8n

### Add PostgreSQL Credentials in n8n:

1. Open n8n at http://localhost:5678
2. Go to **Settings** → **Credentials**
3. Click **"Add Credential"**
4. Search for **"Postgres"**
5. Configure:
   ```
   Host: postgres
   Database: news_aggregator
   User: n8n_user
   Password: [from .env file]
   Port: 5432
   SSL: Disable (internal network)
   ```
6. **Test Connection** and **Save**

## Example Queries for Workflows

### Insert Article
```sql
INSERT INTO articles (
    title, url, description, rating, reasoning, 
    category, keywords, published_date, aggregated_date, source
) VALUES (
    $1, $2, $3, $4, $5, $6, $7::jsonb, $8, $9, $10
)
ON CONFLICT (url) DO NOTHING
RETURNING id;
```

### Get High-Priority Articles (Last 24 hours)
```sql
SELECT * FROM articles 
WHERE rating >= 4 
AND aggregated_date >= NOW() - INTERVAL '24 hours'
ORDER BY rating DESC, aggregated_date DESC;
```

### Get This Week's Top Articles
```sql
SELECT * FROM articles 
WHERE rating >= 4 
AND aggregated_date >= DATE_TRUNC('week', NOW())
ORDER BY rating DESC, aggregated_date DESC;
```

### Search by Keywords (using JSONB)
```sql
SELECT * FROM articles
WHERE keywords @> '["vulnerability"]'::jsonb
ORDER BY aggregated_date DESC
LIMIT 20;
```

### Get Articles by Category
```sql
SELECT * FROM articles
WHERE category = 'cybersecurity'
AND rating = 5
ORDER BY published_date DESC;
```

### Weekly Summary Stats
```sql
SELECT 
    category,
    COUNT(*) as total,
    AVG(rating) as avg_rating,
    COUNT(*) FILTER (WHERE rating = 5) as five_star_count
FROM articles
WHERE aggregated_date >= NOW() - INTERVAL '7 days'
GROUP BY category;
```

## Using in n8n Workflows

### PostgreSQL Node Configuration:

**Operation:** `Execute Query` or `Insert`

**For INSERT with parameters (recommended):**
```javascript
// In Code node before PostgreSQL node
return [{
  json: {
    params: [
      $json.title,
      $json.url,
      $json.description,
      $json.rating,
      $json.reasoning,
      $json.category,
      JSON.stringify($json.keywords),
      $json.publishedDate,
      new Date().toISOString(),
      $json.source
    ]
  }
}];
```

**In PostgreSQL node:**
- Query: Use the INSERT query above with $1, $2, etc.
- Parameters: `{{ $json.params }}`

**For SELECT queries:**
- Just use the query directly
- Results will be in JSON format

## Backup & Maintenance

### Backup Database
```powershell
docker exec news-aggregator-postgres pg_dump -U n8n_user news_aggregator > backup.sql
```

### Restore Database
```powershell
cat backup.sql | docker exec -i news-aggregator-postgres psql -U n8n_user news_aggregator
```

### Check Database Size
```powershell
docker exec news-aggregator-postgres psql -U n8n_user -d news_aggregator -c "SELECT pg_size_pretty(pg_database_size('news_aggregator'));"
```

### View Recent Articles
```powershell
docker exec news-aggregator-postgres psql -U n8n_user -d news_aggregator -c "SELECT id, title, rating, category FROM articles ORDER BY created_at DESC LIMIT 10;"
```

## Connection String (for external tools)

If you want to connect from tools like pgAdmin, DBeaver, etc.:

```
postgresql://n8n_user:SecurePassword123!ChangeMe@localhost:5432/news_aggregator
```

**Note:** Change the password to match your `.env` file

## Next Steps

1. ✅ PostgreSQL is running
2. ✅ Database schema created
3. ✅ Tables ready
4. **Next:** Build the n8n workflows using the `WORKFLOW-SETUP-GUIDE.md`

## Troubleshooting

**Can't connect from n8n:**
- Make sure hostname is `postgres` (not `localhost`)
- Verify credentials match `.env` file
- Check containers are on same network: `docker network inspect news-aggregator_news-aggregator`

**Tables not created:**
- SQL file should be in `/docker-entrypoint-initdb.d/` in container
- Only runs on first initialization
- To reset: `docker-compose down -v` then `docker-compose up -d`

**Performance issues:**
- Check indexes are created
- Use JSONB queries efficiently  
- Consider partitioning for large datasets (100k+ articles)
