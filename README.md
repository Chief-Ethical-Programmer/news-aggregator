# n8n News Aggregator - No API Required

Automated news aggregation system using **only RSS feeds** and **rule-based priority scoring**. No AI APIs needed!

## Features

- 📰 **Multiple RSS Sources** - Cybersecurity, AI, and Tech news
- ⭐ **Smart Rule-Based Rating** - 1-5 star priority system using keyword analysis
- 📧 **Daily Digest** - Email with high-priority articles (4-5 stars)
- 📊 **Weekly Summary** - Trend analysis and must-reads
- 🗄️ **SQLite Database** - All articles stored locally
- 🆓 **100% Free** - No API keys or subscriptions required

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Email account for SMTP (Gmail, Outlook, etc.)

### Installation

1. **Navigate to project directory**
   ```powershell
   cd d:\Work\n8n\Automations\news-aggregator
   ```

2. **Edit the .env file**
   - Set your n8n username and password
   - Configure email SMTP settings

3. **Start n8n**
   ```powershell
   docker-compose up -d
   ```

4. **Access n8n**
   - Open browser to http://localhost:5678
   - Login with credentials from .env file

5. **Setup the database**
   - In n8n, create a new workflow
   - Add an "Execute Command" node or "SQLite" node
   - Run the SQL script from `scripts/setup-database.sql`

6. **Build your workflows**
   - Create workflows using the RSS Feed nodes
   - Implement the priority scoring logic
   - Configure email notifications

## RSS News Sources

### Cybersecurity
- **The Hacker News**: https://feeds.feedburner.com/TheHackersNews
- **BleepingComputer**: https://www.bleepingcomputer.com/feed/
- **Threatpost**: https://threatpost.com/feed/

### AI/ML
- **AI News**: https://www.artificialintelligence-news.com/feed/
- **MarkTechPost**: https://www.marktechpost.com/feed/

### Tech
- **TechCrunch**: https://techcrunch.com/feed/
- **The Verge**: https://www.theverge.com/rss/index.xml

## Priority Rating System

The system uses keyword analysis to assign ratings:

### 5 Stars ⭐⭐⭐⭐⭐ (Must Read)
- Critical security vulnerabilities (zero-day, exploit)
- Major breakthroughs and innovations
- Urgent security advisories
- Recent articles with high-impact keywords

### 4 Stars ⭐⭐⭐⭐ (Important)
- Security patches and updates
- Significant product launches
- Important industry developments

### 3 Stars ⭐⭐⭐ (Relevant)
- Regular updates and announcements
- Standard news articles

### 2-1 Stars ⭐ (Lower Priority)
- Background information
- Minor updates

## How It Works

### Daily Workflow
1. **Schedule Trigger** - Runs daily at 8 AM
2. **RSS Feed Nodes** - Fetches articles from multiple sources
3. **Merge Node** - Combines all articles
4. **Code Node** - Analyzes content and assigns ratings based on:
   - Critical keywords (vulnerability, breach, breakthrough)
   - Important keywords (patch, update, launch)
   - Article freshness
   - Urgency indicators in title
   - Category relevance
5. **Database Node** - Saves articles to SQLite
6. **Filter Node** - Selects high-priority articles (4-5 stars)
7. **Email Node** - Sends daily digest

### Weekly Workflow
1. **Schedule Trigger** - Runs Sunday at 6 PM
2. **Database Query** - Gets week's top articles
3. **Code Node** - Analyzes trends:
   - Identifies must-read articles
   - Calculates keyword frequency
   - Groups by category
   - Generates strategic insights
4. **Email Node** - Sends comprehensive weekly summary

## Workflow Configuration

### Setting Up Daily Aggregation

1. Create a new workflow in n8n
2. Add **Schedule Trigger** node
   - Set cron: `0 8 * * *` (daily at 8 AM)
3. Add **RSS Feed Read** nodes for each source
4. Add **Merge** node to combine feeds
5. Add **Code** node with priority scoring logic
6. Add **SQLite** node to save articles
7. Add **IF** node to filter by rating >= 4
8. Add **Code** node to format email
9. Add **Email Send** node

### Setting Up Weekly Summary

1. Create a new workflow
2. Add **Schedule Trigger** node
   - Set cron: `0 18 * * 0` (Sunday at 6 PM)
3. Add **SQLite** node to query top articles
4. Add **Code** node to analyze trends
5. Add **Code** node to format summary
6. Add **SQLite** node to save summary
7. Add **Email Send** node

## Email Setup

### Gmail Configuration

1. Enable 2-Factor Authentication in your Google Account
2. Generate an App Password:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" and "Other (Custom name)"
   - Generate password
3. Use the App Password in your n8n Email node

### Environment Variables

Edit `.env` file:
```env
N8N_USER=admin
N8N_PASSWORD=your-secure-password
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
EMAIL_TO=recipient@example.com
```

## Database Schema

```sql
articles
├── id (PRIMARY KEY)
├── title
├── url (UNIQUE)
├── description
├── rating (1-5)
├── reasoning
├── category (cybersecurity/ai/tech)
├── keywords (JSON array)
├── published_date
├── aggregated_date
├── source
└── created_at

weekly_summaries
├── id (PRIMARY KEY)
├── week_start
├── week_end
├── must_reads (JSON array)
├── analysis (JSON)
├── total_articles
└── created_at
```

## Customization

### Add More RSS Sources

1. In the daily workflow, add new **RSS Feed Read** nodes
2. Connect them to the **Merge** node
3. Update the **Code** node keywords if needed

### Modify Rating Criteria

Edit the **Code** node in the daily workflow to adjust:
- Critical keywords list
- Important keywords list
- Scoring thresholds
- Freshness bonus

### Change Schedule

Modify the **Schedule Trigger** nodes:
- Daily: Default is `0 8 * * *` (8 AM)
- Weekly: Default is `0 18 * * 0` (Sunday 6 PM)

### Customize Email Format

Edit the **Code** nodes that format emails to change:
- HTML/Markdown layout
- Sections included
- Formatting style

## Troubleshooting

### n8n won't start
- Check if port 5678 is available
- Verify Docker is running
- Check logs: `docker-compose logs -f`

### No emails received
- Verify SMTP settings in Email node
- Check spam/junk folder
- Test with a simple email workflow first
- Ensure firewall allows SMTP traffic

### RSS feeds not loading
- Verify internet connection
- Check if RSS URLs are still valid
- Some feeds may require user agent headers

### Database errors
- Ensure the database schema is created
- Check file permissions in the database folder
- Verify SQLite node configuration

## Project Structure

```
news-aggregator/
├── docker-compose.yml        # Docker configuration
├── .env                       # Environment variables
├── .gitignore                 # Git ignore rules
├── README.md                  # This file
├── workflows/                 # n8n workflow JSON files
│   ├── daily-news-aggregation.json
│   └── weekly-summary.json
├── scripts/                   # Database and utility scripts
│   └── setup-database.sql
├── data/                      # n8n application data
├── database/                  # SQLite database files
├── credentials/               # n8n credentials (gitignored)
└── nodes/                     # Custom n8n nodes (if any)
    └── custom/
```

## Commands

### Start n8n
```powershell
docker-compose up -d
```

### Stop n8n
```powershell
docker-compose down
```

### View logs
```powershell
docker-compose logs -f
```

### Restart n8n
```powershell
docker-compose restart
```

### Backup database
```powershell
Copy-Item .\database\news.sqlite .\database\news.sqlite.backup
```

## Security Notes

- Change default n8n password in `.env`
- Never commit `.env` file to git
- Use app-specific passwords for email
- Keep n8n updated: `docker-compose pull && docker-compose up -d`

## License

MIT

## Support

For issues or questions:
- n8n documentation: https://docs.n8n.io/
- n8n community: https://community.n8n.io/

---

**Note**: The workflow files in this project are templates. You'll need to build the actual workflows in the n8n UI following the configuration guide above.
