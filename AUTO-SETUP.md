# Auto-Setup Script

Import the workflows into n8n, then run this script to automatically configure them.

## PowerShell Script

Save this as `setup-workflows.ps1` and run it:

```powershell
# Configuration
$N8N_URL = "http://localhost:5678"
$N8N_API_KEY = "YOUR_API_KEY_HERE"  # Get from Settings > API in n8n

Write-Host "🚀 Setting up n8n workflows..." -ForegroundColor Green

# Check if n8n is running
try {
    $response = Invoke-WebRequest -Uri $N8N_URL -Method GET -ErrorAction Stop
    Write-Host "✅ n8n is accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Cannot connect to n8n at $N8N_URL" -ForegroundColor Red
    Write-Host "Make sure n8n is running: docker-compose ps" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n📋 Manual steps required:" -ForegroundColor Cyan
Write-Host "1. Open n8n: $N8N_URL"
Write-Host "2. Go to Settings > API"
Write-Host "3. Create an API key"
Write-Host "4. Add PostgreSQL credential named 'PostgreSQL - News Aggregator'"
Write-Host "5. Import workflows from ./workflows/ folder"
Write-Host "6. Activate both workflows"

Write-Host "`n✨ After completing these steps, your news aggregator will be ready!" -ForegroundColor Green
```

## Easier Way: Manual Import (Recommended)

Since n8n workflows are best imported through the UI:

### 1. Create PostgreSQL Credential First
```
Settings → Credentials → Add → Postgres
Name: PostgreSQL - News Aggregator
Host: postgres
Database: news_aggregator
User: n8n_user
Password: SecurePassword123!ChangeMe
Port: 5432
SSL: disable
```

### 2. Copy Workflow Templates

I'll create simplified workflow templates that you can paste directly into n8n's workflow import.

**Option A**: Use the UI (easiest)
- Follow **QUICK-IMPORT.md** - just 3 steps, takes 4 minutes

**Option B**: Use n8n CLI (if installed)
```bash
n8n import:workflow --input=./workflows/
```

**Option C**: Use API (advanced)
```powershell
$apiKey = "YOUR_KEY"
$workflows = Get-ChildItem -Path "./workflows/*.json"

foreach ($workflow in $workflows) {
    $content = Get-Content $workflow.FullName -Raw
    Invoke-RestMethod -Uri "$N8N_URL/api/v1/workflows" `
        -Method POST `
        -Headers @{"X-N8N-API-KEY"=$apiKey; "Content-Type"="application/json"} `
        -Body $content
}
```

## The Reality

Unfortunately, n8n workflows require:
1. Valid credential IDs (unique to your instance)
2. Proper node connections
3. Correct node type versions

**Best approach**: Follow the **QUICK-IMPORT.md** guide - it's actually the fastest way (4 minutes total).

Or I can create a video/GIF showing the exact clicks needed. Would that help?
