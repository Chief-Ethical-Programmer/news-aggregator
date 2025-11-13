# n8n News Aggregator - Workflow Setup Guide

Follow these steps to build your news aggregation system in n8n.

## Step 1: Add PostgreSQL Credentials

1. **Open n8n** at http://localhost:5678
2. Go to **Settings** (click your avatar) → **Credentials**
3. Click **"Add Credential"**
4. Search for **"Postgres"**
5. Configure:
   - **Host**: `postgres` (important: not localhost!)
   - **Database**: `news_aggregator`
   - **User**: `n8n_user`
   - **Password**: `SecurePassword123!ChangeMe` (or check your .env file)
   - **Port**: `5432`
   - **SSL Mode**: `disable`
6. Click **"Test"** to verify connection
7. Click **"Save"**

**Note:** Database tables are already created automatically! Skip to Step 2.

## Step 2: Build Daily News Aggregation Workflow

### Create New Workflow
1. Click **"Add workflow"** button
2. Name it: **"Daily News Aggregation"**

### Add Nodes (follow this order):

#### Node 1: Schedule Trigger
1. Click the "+" button
2. Search for **"Schedule Trigger"**
3. Configure:
   - **Trigger Interval**: Cron
   - **Cron Expression**: `0 8 * * *` (runs daily at 8 AM)
   - **Timezone**: Your timezone

#### Node 2-8: RSS Feed Read Nodes (Add 7 of these)

**Node 2: Cybersecurity - HackerNews**
- Search for **"RSS Feed Read"**
- **URL**: `https://feeds.feedburner.com/TheHackersNews`

**Node 3: Cybersecurity - BleepingComputer**
- **URL**: `https://www.bleepingcomputer.com/feed/`

**Node 4: AI - AI News**
- **URL**: `https://www.artificialintelligence-news.com/feed/`

**Node 5: AI - VentureBeat AI**
- **URL**: `https://venturebeat.com/category/ai/feed/`

**Node 6: Tech - TechCrunch**
- **URL**: `https://techcrunch.com/feed/`

**Node 7: Tech - The Verge**
- **URL**: `https://www.theverge.com/rss/index.xml`

**Node 8: Tech - Wired**
- **URL**: `https://www.wired.com/feed/rss`

**Connect all RSS nodes to Schedule Trigger**

#### Node 9: Merge
1. Add **"Merge"** node
2. Configure:
   - **Mode**: Combine
   - **Combination Mode**: Merge By Position
3. **Connect all 7 RSS nodes** to this Merge node

#### Node 10: Code - Priority Scoring
1. Add **"Code"** node
2. Name it: **"Smart Priority Scoring"**
3. Paste this code:

```javascript
// Rule-based priority scoring system
const items = $input.all();
const articles = [];

// High priority keywords by category
const criticalKeywords = {
  cybersecurity: ['zero-day', 'vulnerability', 'breach', 'ransomware', 'exploit', 'critical', 'urgent', 'emergency', 'attack', 'malware', 'phishing', 'hack', 'cve-', 'patch'],
  ai: ['breakthrough', 'gpt-5', 'agi', 'openai', 'google ai', 'deepmind', 'chatgpt', 'claude', 'gemini', 'large language model', 'llm', 'artificial general intelligence'],
  tech: ['layoff', 'acquisition', 'ipo', 'bankruptcy', 'regulation', 'antitrust', 'launch', 'release', 'funding']
};

const importantKeywords = {
  cybersecurity: ['patch', 'update', 'security', 'threat', 'warning', 'advisory', 'flaw', 'fix'],
  ai: ['model', 'training', 'research', 'paper', 'study', 'development', 'innovation', 'api'],
  tech: ['announcement', 'partnership', 'startup', 'product', 'feature', 'update']
};

function determineCategory(title, description) {
  const text = (title + ' ' + description).toLowerCase();
  
  const cyberScore = criticalKeywords.cybersecurity.filter(kw => text.includes(kw)).length +
                     importantKeywords.cybersecurity.filter(kw => text.includes(kw)).length;
  const aiScore = criticalKeywords.ai.filter(kw => text.includes(kw)).length +
                  importantKeywords.ai.filter(kw => text.includes(kw)).length;
  const techScore = criticalKeywords.tech.filter(kw => text.includes(kw)).length +
                    importantKeywords.tech.filter(kw => text.includes(kw)).length;
  
  if (cyberScore >= aiScore && cyberScore >= techScore && cyberScore > 0) return 'cybersecurity';
  if (aiScore >= techScore && aiScore > 0) return 'ai';
  if (techScore > 0) return 'tech';
  return 'general';
}

function calculateRating(title, description, category, pubDate) {
  const text = (title + ' ' + description).toLowerCase();
  let score = 3; // Base score
  
  // Check for critical keywords (+2 points)
  const criticalMatches = criticalKeywords[category]?.filter(kw => text.includes(kw)).length || 0;
  if (criticalMatches >= 2) score += 2;
  else if (criticalMatches === 1) score += 1;
  
  // Check for important keywords (+1 point)
  const importantMatches = importantKeywords[category]?.filter(kw => text.includes(kw)).length || 0;
  if (importantMatches >= 2) score += 1;
  
  // Check article freshness (recent = higher priority)
  if (pubDate) {
    const hoursSincePublish = (Date.now() - new Date(pubDate).getTime()) / (1000 * 60 * 60);
    if (hoursSincePublish <= 6) score += 1;
  }
  
  // Check for urgency words in title
  const urgencyWords = ['breaking', 'urgent', 'critical', 'major', 'massive', 'significant', 'important'];
  if (urgencyWords.some(word => title.toLowerCase().includes(word))) score += 1;
  
  // Cap at 5 stars, minimum 1
  return Math.min(5, Math.max(1, score));
}

function generateReasoning(rating, category, title, description) {
  const text = (title + ' ' + description).toLowerCase();
  let reasons = [];
  
  if (rating === 5) {
    reasons.push('Critical priority - immediate attention required');
  } else if (rating === 4) {
    reasons.push('High priority - important development');
  } else if (rating === 3) {
    reasons.push('Moderate priority - relevant information');
  } else {
    reasons.push('Standard news item');
  }
  
  // Add specific reasoning
  if (text.includes('zero-day') || text.includes('vulnerability')) {
    reasons.push('Security vulnerability detected');
  }
  if (text.includes('breach') || text.includes('hack')) {
    reasons.push('Security incident reported');
  }
  if (text.includes('breakthrough') || text.includes('innovation')) {
    reasons.push('Significant technological advancement');
  }
  if (text.includes('critical') || text.includes('urgent')) {
    reasons.push('Requires immediate attention');
  }
  
  return reasons.join('. ');
}

function extractKeywords(title, description, category) {
  const text = (title + ' ' + description).toLowerCase();
  const allKeywords = [
    ...(criticalKeywords[category] || []), 
    ...(importantKeywords[category] || [])
  ];
  return allKeywords.filter(kw => text.includes(kw));
}

for (const item of items) {
  const title = item.json.title || '';
  const description = item.json.description || item.json.content || item.json.summary || '';
  const pubDate = item.json.pubDate || item.json.isoDate || item.json.published;
  const url = item.json.link || item.json.url || '';
  
  // Skip if no title or URL
  if (!title || !url) continue;
  
  const category = determineCategory(title, description);
  const rating = calculateRating(title, description, category, pubDate);
  const reasoning = generateReasoning(rating, category, title, description);
  const keywords = extractKeywords(title, description, category);
  
  articles.push({
    json: {
      title: title.substring(0, 500).replace(/[\r\n]+/g, ' ').trim(),
      url: url,
      description: description.substring(0, 1000).replace(/[\r\n]+/g, ' ').trim(),
      rating: rating,
      reasoning: reasoning.replace(/[\r\n]+/g, ' ').trim(),
      category: category,
      keywords: JSON.stringify(keywords),
      publishedDate: pubDate || new Date().toISOString(),
      aggregatedDate: new Date().toISOString(),
      source: (item.json.creator || 'RSS Feed').replace(/[\r\n]+/g, ' ').trim()
    }
  });
}

// Sort by rating (highest first)
articles.sort((a, b) => b.json.rating - a.json.rating);

return articles;
```

#### Node 11: PostgreSQL - Save Articles
1. Add **"Postgres"** node
2. Configure:
   - **Credential**: Select the PostgreSQL credential you created
   - **Operation**: `Execute Query`
   - **Query**:
```sql
INSERT INTO articles (
  title, url, description, rating, reasoning, 
  category, keywords, published_date, aggregated_date, source
) VALUES (
  $1, $2, $3, $4, $5, $6, $7::jsonb, $8::timestamp, $9::timestamp, $10
)
ON CONFLICT (url) DO NOTHING;
```
   - **Query Parameters**: Add these in order (click + to add each):
     - `{{ $json.title }}`
     - `{{ $json.url }}`
     - `{{ $json.description }}`
     - `{{ $json.rating }}`
     - `{{ $json.reasoning }}`
     - `{{ $json.category }}`
     - `{{ $json.keywords }}`
     - `{{ $json.publishedDate }}`
     - `{{ $json.aggregatedDate }}`
     - `{{ $json.source }}`

#### Node 12: IF - Filter High Priority
1. Add **"IF"** node
2. Configure:
   - **Condition**: Number
   - **Value 1**: `{{ $json.rating }}`
   - **Operation**: Larger or Equal
   - **Value 2**: `4`

#### Node 13: Code - Format Email
1. Add **"Code"** node after the TRUE branch of IF
2. Name it: **"Format Daily Email"**
3. Paste this code:

```javascript
const articles = $input.all().map(item => item.json);

if (articles.length === 0) {
  return [{ json: { noArticles: true } }];
}

const fiveStars = articles.filter(a => a.rating === 5);
const fourStars = articles.filter(a => a.rating === 4);

const today = new Date().toLocaleDateString('en-US', { 
  weekday: 'long', 
  year: 'numeric', 
  month: 'long', 
  day: 'numeric' 
});

let emailBody = `# 📰 Daily High-Priority News Digest\n\n**${today}**\n\n`;

if (fiveStars.length > 0) {
  emailBody += `## 🔥 Must Read Today (${fiveStars.length} articles)\n\n`;
  fiveStars.forEach((article, idx) => {
    emailBody += `### ${idx + 1}. ${article.title}\n`;
    emailBody += `**⭐⭐⭐⭐⭐ | ${article.category.toUpperCase()}**\n\n`;
    emailBody += `**Why it matters:** ${article.reasoning}\n\n`;
    
    // Parse keywords
    let keywords = [];
    try {
      keywords = JSON.parse(article.keywords);
    } catch (e) {
      keywords = [];
    }
    if (keywords.length > 0) {
      emailBody += `**Keywords:** ${keywords.join(', ')}\n\n`;
    }
    
    emailBody += `[Read Full Article](${article.url})\n\n---\n\n`;
  });
}

if (fourStars.length > 0) {
  emailBody += `## ⭐ Important Updates (${fourStars.length} articles)\n\n`;
  fourStars.slice(0, 10).forEach((article, idx) => {
    emailBody += `### ${idx + 1}. ${article.title}\n`;
    emailBody += `**⭐⭐⭐⭐ | ${article.category.toUpperCase()}**\n\n`;
    emailBody += `${article.reasoning}\n\n`;
    emailBody += `[Read more](${article.url})\n\n`;
  });
}

const byCategory = {
  cybersecurity: articles.filter(a => a.category === 'cybersecurity').length,
  ai: articles.filter(a => a.category === 'ai').length,
  tech: articles.filter(a => a.category === 'tech').length,
  general: articles.filter(a => a.category === 'general').length
};

emailBody += `\n## 📊 Today's Summary\n\n`;
emailBody += `- **Cybersecurity:** ${byCategory.cybersecurity} high-priority articles\n`;
emailBody += `- **AI/ML:** ${byCategory.ai} high-priority articles\n`;
emailBody += `- **Tech:** ${byCategory.tech} high-priority articles\n`;
emailBody += `- **Total High Priority:** ${articles.length} articles\n\n`;

emailBody += `---\n*Automated by n8n News Aggregator*`;

return [{
  json: {
    subject: `📰 ${fiveStars.length} Must-Reads Today | ${today}`,
    body: emailBody,
    totalArticles: articles.length
  }
}];
```

#### Node 14: Send Email
1. Add **"Send Email"** node
2. Configure:
   - **From Email**: Your email
   - **To Email**: Your recipient email
   - **Subject**: `{{ $json.subject }}`
   - **Email Type**: Text
   - **Text**: `{{ $json.body }}`
3. **Add SMTP credentials** (you'll configure this separately)

### Save the Workflow
Click **"Save"** button in the top right

---

## Step 3: Test the Daily Workflow

1. Click **"Execute Workflow"** button
2. Check each node's output
3. Verify articles are saved to database
4. Check if email was sent (if configured)

---

## Step 4: Build Weekly Summary Workflow

### Create New Workflow
1. Click **"Add workflow"**
2. Name it: **"Weekly News Summary"**

### Add Nodes:

#### Node 1: Schedule Trigger
- **Cron Expression**: `0 18 * * 0` (Sunday at 6 PM)

#### Node 2: PostgreSQL - Get Top Articles
1. Add **"Postgres"** node
2. Configure:
   - **Credential**: Select your PostgreSQL credential
   - **Operation**: `Execute Query`
   - **Query**:
```sql
SELECT * FROM articles 
WHERE rating >= 4 
AND aggregated_date >= NOW() - INTERVAL '7 days' 
ORDER BY rating DESC, aggregated_date DESC
```

#### Node 3: Code - Analyze Trends
Paste this code:

```javascript
const articles = $input.all().map(item => item.json);

if (articles.length === 0) {
  return [{ json: { noArticles: true } }];
}

// Group by rating
const mustReads = articles.filter(a => a.rating === 5);
const important = articles.filter(a => a.rating === 4);

// Group by category
const byCategory = {
  cybersecurity: articles.filter(a => a.category === 'cybersecurity'),
  ai: articles.filter(a => a.category === 'ai'),
  tech: articles.filter(a => a.category === 'tech'),
  general: articles.filter(a => a.category === 'general')
};

// Extract all keywords
const allKeywords = [];
articles.forEach(a => {
  try {
    const keywords = typeof a.keywords === 'string' ? JSON.parse(a.keywords) : a.keywords;
    allKeywords.push(...keywords);
  } catch (e) {
    // Skip invalid JSON
  }
});

// Count keyword frequency
const keywordCount = {};
allKeywords.forEach(kw => {
  keywordCount[kw] = (keywordCount[kw] || 0) + 1;
});

const topKeywords = Object.entries(keywordCount)
  .sort((a, b) => b[1] - a[1])
  .slice(0, 10)
  .map(([keyword, count]) => ({ keyword, count }));

// Emerging trends
const emergingTrends = topKeywords.slice(0, 5).map(item => item.keyword);

// Top topics by category
const topicsByCategory = {};
Object.keys(byCategory).forEach(cat => {
  const catKeywords = {};
  byCategory[cat].forEach(article => {
    try {
      const keywords = typeof article.keywords === 'string' ? 
        JSON.parse(article.keywords) : article.keywords;
      keywords.forEach(kw => {
        catKeywords[kw] = (catKeywords[kw] || 0) + 1;
      });
    } catch (e) {}
  });
  topicsByCategory[cat] = Object.entries(catKeywords)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([keyword]) => keyword);
});

// Generate insights
const insights = [];

if (byCategory.cybersecurity.length > 0) {
  const hasVulnerability = byCategory.cybersecurity.some(a => {
    try {
      const kw = JSON.parse(a.keywords);
      return kw.includes('vulnerability') || kw.includes('zero-day') || kw.includes('breach');
    } catch { return false; }
  });
  if (hasVulnerability) {
    insights.push({
      category: 'Cybersecurity',
      insight: 'Critical vulnerabilities reported - review security patches',
      priority: 'high'
    });
  }
}

if (mustReads.length >= 3) {
  insights.push({
    category: 'Overall',
    insight: `${mustReads.length} critical articles this week - unusually high activity`,
    priority: 'high'
  });
}

// Week dates
const weekEnd = new Date();
const weekStart = new Date(weekEnd);
weekStart.setDate(weekStart.getDate() - 7);

return [{
  json: {
    mustReads,
    important,
    byCategory,
    topKeywords,
    emergingTrends,
    topicsByCategory,
    insights,
    weekStart: weekStart.toISOString(),
    weekEnd: weekEnd.toISOString(),
    totalArticles: articles.length,
    stats: {
      fiveStars: mustReads.length,
      fourStars: important.length,
      cybersecurity: byCategory.cybersecurity.length,
      ai: byCategory.ai.length,
      tech: byCategory.tech.length
    }
  }
}];
```

#### Node 4: Code - Format Weekly Email
Paste this code:

```javascript
const data = $input.first().json;

if (data.noArticles) {
  return [{
    json: {
      subject: 'Weekly Tech Digest - No High-Priority Articles',
      body: 'No high-priority articles were found this week.'
    }
  }];
}

const weekStart = new Date(data.weekStart).toLocaleDateString('en-US', { month: 'long', day: 'numeric' });
const weekEnd = new Date(data.weekEnd).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });

let emailBody = `# 📊 Weekly Tech Digest\n\n**${weekStart} - ${weekEnd}**\n\n---\n\n`;

// Must Reads
if (data.mustReads.length > 0) {
  emailBody += `## 🌟 Must Read This Week (${data.mustReads.length} articles)\n\n`;
  data.mustReads.forEach((article, idx) => {
    emailBody += `### ${idx + 1}. ${article.title}\n`;
    emailBody += `**⭐⭐⭐⭐⭐ | ${article.category.toUpperCase()}**\n\n`;
    emailBody += `${article.reasoning}\n\n`;
    emailBody += `[Read Article](${article.url})\n\n---\n\n`;
  });
}

// Strategic Insights
if (data.insights.length > 0) {
  emailBody += `## 💡 Strategic Insights\n\n`;
  data.insights.forEach(insight => {
    const icon = insight.priority === 'high' ? '🔴' : '🟡';
    emailBody += `${icon} **${insight.category}**: ${insight.insight}\n\n`;
  });
  emailBody += `\n`;
}

// Emerging Trends
if (data.emergingTrends.length > 0) {
  emailBody += `## 📈 Emerging Trends\n\n`;
  emailBody += `Key topics this week: **${data.emergingTrends.join(', ')}**\n\n`;
}

// Category Breakdown
emailBody += `## 📑 This Week by Category\n\n`;

['cybersecurity', 'ai', 'tech'].forEach(cat => {
  const articles = data.byCategory[cat];
  if (articles.length > 0) {
    const icon = cat === 'cybersecurity' ? '🔒' : cat === 'ai' ? '🤖' : '💻';
    const catName = cat === 'ai' ? 'AI/ML' : cat.charAt(0).toUpperCase() + cat.slice(1);
    
    emailBody += `### ${icon} ${catName} (${articles.length} articles)\n`;
    
    if (data.topicsByCategory[cat] && data.topicsByCategory[cat].length > 0) {
      emailBody += `Top topics: ${data.topicsByCategory[cat].join(', ')}\n\n`;
    }
    
    articles.slice(0, 5).forEach(article => {
      emailBody += `- **[${article.rating}⭐]** ${article.title}\n`;
    });
    emailBody += `\n`;
  }
});

// Statistics
emailBody += `## 📊 Weekly Statistics\n\n`;
emailBody += `- Total High-Priority Articles: **${data.totalArticles}**\n`;
emailBody += `- Must-Reads (5⭐): **${data.stats.fiveStars}**\n`;
emailBody += `- Important (4⭐): **${data.stats.fourStars}**\n`;
emailBody += `- Cybersecurity: **${data.stats.cybersecurity}**\n`;
emailBody += `- AI/ML: **${data.stats.ai}**\n`;
emailBody += `- Tech: **${data.stats.tech}**\n\n`;

// Top Keywords
if (data.topKeywords.length > 0) {
  emailBody += `## 🏷️ Most Discussed Keywords\n\n`;
  data.topKeywords.forEach((item, idx) => {
    emailBody += `${idx + 1}. **${item.keyword}** (${item.count} mentions)\n`;
  });
  emailBody += `\n`;
}

emailBody += `---\n\n*Automated by n8n News Aggregator*`;

return [{
  json: {
    subject: `📊 Weekly Tech Digest | ${data.stats.fiveStars} Must-Reads | ${weekStart}-${weekEnd}`,
    body: emailBody
  }
}];
```

#### Node 5: Send Email
Same configuration as daily workflow

### Save the Workflow

---

## Step 5: Configure Email Credentials

1. Go to **Settings** → **Credentials**
2. Click **"Add Credential"**
3. Search for **"SMTP"**
4. Configure:
   - **User**: Your Gmail address
   - **Password**: App-specific password (see below)
   - **Host**: `smtp.gmail.com`
   - **Port**: `587`
   - **SSL/TLS**: Enable

### Get Gmail App Password:
1. Go to https://myaccount.google.com/apppasswords
2. Generate new app password for "Mail"
3. Use this password in n8n

---

## Step 6: Activate Workflows

1. Open each workflow
2. Click the toggle switch at the top to **activate**
3. Workflows will now run on schedule

---

## Testing

### Test Daily Workflow:
1. Open the workflow
2. Click "Execute Workflow"
3. Check each node's output
4. Verify database entries
5. Check email inbox

### Test Weekly Workflow:
1. First run the daily workflow a few times
2. Then execute the weekly workflow
3. Verify the summary includes the articles

---

## Troubleshooting

- **RSS feeds not loading**: Check internet connection
- **Database errors**: Ensure database is created
- **Email not sending**: Verify SMTP credentials
- **No articles**: Check RSS feed URLs are valid

---

You're all set! The system will now:
- Run daily at 8 AM to aggregate news
- Send daily digest of 4-5 star articles
- Run weekly on Sunday at 6 PM
- Send weekly summary with trends

