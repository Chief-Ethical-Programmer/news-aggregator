# Quick Import Guide - Just 3 Steps!

## Step 1: Import Workflows (2 minutes)

1. **Open n8n**: http://localhost:5678
2. **Import Daily Workflow**:
   - Click **"Workflows"** in sidebar
   - Click **"Import from File"** button
   - Select `workflows/daily-news-aggregation-complete.json`
   - Click **"Import"**
3. **Import Weekly Workflow**:
   - Click **"Import from File"** again
   - Select `workflows/weekly-summary-complete.json`
   - Click **"Import"**

## Step 2: Add PostgreSQL Credential (1 minute)

1. Go to **Settings** → **Credentials**
2. Click **"Add Credential"**
3. Search **"Postgres"**
4. Fill in:
   - **Name**: `PostgreSQL - News Aggregator`
   - **Host**: `postgres`
   - **Database**: `news_aggregator`
   - **User**: `n8n_user`
   - **Password**: `SecurePassword123!ChangeMe`
   - **Port**: `5432`
   - **SSL**: Disable
5. Click **"Test"** → **"Save"**

## Step 3: Update Workflows with Credential (1 minute)

1. **Open "Daily News Aggregation" workflow**
2. Click on the **"PostgreSQL - Save Articles"** node
3. Select the credential you just created
4. Click **"Save"** (top right)

5. **Open "Weekly News Summary" workflow**
6. Click on **"PostgreSQL - Get Articles"** node
7. Select the same credential
8. Click **"Save"**

## Done! 🎉

**Test it:**
1. Open "Daily News Aggregation"
2. Click **"Execute Workflow"**
3. Watch it fetch, score, and save articles!

**Activate for automation:**
1. Toggle the switch to **"Active"** on both workflows
2. Daily runs at 8 AM, Weekly runs Sunday 6 PM

**Optional - Add Email:**
- Add SMTP credentials if you want email notifications
- Both workflows have email nodes ready to configure
