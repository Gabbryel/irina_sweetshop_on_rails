# Quick Start Guide - Audit Logging System

## 🚀 Getting Started

The audit logging system is already installed and configured. Follow these steps to start using it.

## 1️⃣ Access the Dashboards

### As an Admin User:

**Method 1 - Via Navigation Menu:**
1. Log in as an admin user
2. Click the user icon in the top navigation
3. Select one of:
   - **"Jurnal Activitate"** → View audit logs
   - **"Analiză Trafic"** → View analytics

**Method 2 - Direct URLs:**
- Audit Logs: `http://localhost:3006/dashboard/audit_logs`
- Audit Statistics: `http://localhost:3006/dashboard/audit_logs/statistics`
- Analytics: `http://localhost:3006/dashboard/analytics`

## 2️⃣ Understanding the Dashboards

### 📝 Audit Logs Dashboard

**What you'll see:**
- A table of all logged actions with:
  - Date/time
  - User who performed the action
  - Action type (Create, Update, Delete, Login, Logout)
  - Resource affected
  - IP address
  - Details button

**Available Actions:**
- **Filter** by user, action, resource type, date range, or search term
- **Export** to CSV
- **View Details** of any log entry
- **View Statistics** for charts and analytics

**Color Coding:**
- 🟢 Green = Create or Login
- 🔵 Blue = Update
- 🔴 Red = Delete
- 🟡 Yellow = Failed Login
- ⚫ Gray = Logout

### 📊 Audit Statistics Dashboard

**What you'll see:**
- **Summary Cards**: Total events, today, this week, this month
- **Authentication Stats**: Successful logins, logouts, failed attempts
- **CRUD Stats**: Create, update, delete counts
- **Charts**:
  - Daily activity trends
  - Action type distribution
  - Hourly patterns
  - Resource activity
- **Top Users**: Most active users ranked

### 📈 Analytics Dashboard

**What you'll see:**
- **Visit Stats**: Total visits, unique visitors
- **User Types**: Authenticated vs guest visitors
- **Charts**:
  - Visit trends over time
  - Browser distribution
  - Operating systems
  - Device types
  - Event tracking
- **Top Events**: Most tracked events

## 3️⃣ Common Tasks

### Filter Audit Logs

1. Go to **Audit Logs** dashboard
2. Use the filter form:
   - **Utilizator**: Select a specific user
   - **Acțiune**: Choose action type
   - **Tip resursă**: Select resource type
   - **Data început/sfârșit**: Set date range
   - **Căutare**: Search by IP, email, or user agent
3. Click **"Filtrează"** to apply
4. Click **"Resetează"** to clear all filters

### Export Audit Logs

1. Go to **Audit Logs** dashboard
2. (Optional) Apply filters to narrow results
3. Click **"Export CSV"** button
4. CSV file will download automatically
5. Open in Excel or Google Sheets

### View Log Details

1. Go to **Audit Logs** dashboard
2. Find the log entry you want to inspect
3. Click **"Detalii"** button
4. View complete information including:
   - User details
   - Resource information
   - Technical details (IP, user agent, request ID)
   - Full change log (JSON format)

### Monitor Security Events

1. Go to **Audit Logs** dashboard
2. In **Acțiune** filter, select "Failed login"
3. Review failed login attempts
4. Check IP addresses for suspicious patterns
5. Export if needed for security analysis

## 4️⃣ What Gets Tracked

### Automatically Tracked:

✅ **CRUD Operations:**
- Creating recipes, cakemodels, categories, orders, etc.
- Updating any record
- Deleting any record

✅ **Authentication:**
- User login (successful)
- User logout
- Failed login attempts

✅ **Visits:**
- Every page view
- Browser information
- Device information
- Unique visitor tracking

✅ **Events:**
- Controller actions
- Custom events (if added)

### What's NOT Tracked:

❌ Password fields (for security)
❌ Session data
❌ Temporary data
❌ Public page views by non-logged-in users (for CRUD, but visits are tracked)

## 5️⃣ Reading the Data

### Understanding Audit Log Entries

**Example Entry:**
```
Date/Time: 17 ianuarie 2026, 10:30
User: admin@example.com
Action: Update (Blue badge)
Resource: Recipe #42
IP Address: 192.168.1.100
```

**What it means:**
- On January 17, 2026 at 10:30 AM
- The admin user updated Recipe #42
- From IP address 192.168.1.100

Click **"Detalii"** to see exactly what changed.

### Understanding Changes JSON

In the detail view, you'll see changes in JSON format:

```json
{
  "name": ["Old Name", "New Name"],
  "price_cents": [5000, 6000]
}
```

**Reading it:**
- Format: `"field": [old_value, new_value]`
- Recipe name changed from "Old Name" to "New Name"
- Price changed from 50.00 RON to 60.00 RON (cents)

## 6️⃣ Best Practices

### Daily Checks (Recommended):
1. ✅ Review failed login attempts
2. ✅ Check for unusual IP addresses
3. ✅ Monitor delete operations

### Weekly Reviews:
1. ✅ Check audit statistics
2. ✅ Review top active users
3. ✅ Analyze visitor trends

### Monthly Tasks:
1. ✅ Export full audit log
2. ✅ Review all authentication events
3. ✅ Analyze peak usage times
4. ✅ Check browser/device distribution

## 7️⃣ Troubleshooting

### "Nu ai permisiunea necesară"
- **Cause**: You're not an admin user
- **Solution**: Ask an admin to grant you admin privileges

### Audit logs not appearing
- **Cause**: CRUD actions need authenticated user
- **Solution**: Ensure you're logged in when performing actions

### Charts not showing
- **Cause**: JavaScript not loaded
- **Solution**: Hard refresh the page (Cmd+Shift+R on Mac, Ctrl+Shift+R on Windows)

### Too many results
- **Solution**: Use filters to narrow down:
  - Add date range
  - Filter by specific user
  - Filter by action type

## 8️⃣ Security Notes

🔒 **Important:**
- Only admin users can access these dashboards
- IP addresses are logged for security
- Failed login attempts are tracked
- No sensitive data (passwords, etc.) is ever logged
- All data is stored securely in the database

🚨 **Red Flags to Watch For:**
- Multiple failed login attempts from same IP
- Unusual hours of activity
- Unexpected delete operations
- Unknown IP addresses

## 9️⃣ Sample Scenarios

### Scenario 1: "Who deleted that recipe?"

1. Go to **Audit Logs**
2. Filter: **Acțiune** → "Destroy"
3. Filter: **Tip resursă** → "Recipe"
4. Find the recipe ID in results
5. Click **"Detalii"** to see full info
6. Note: User, timestamp, IP address

### Scenario 2: "Are users visiting our site?"

1. Go to **Analytics** dashboard
2. Check **"Vizite astăzi"** card
3. Review **"Vizite pe zile"** chart for trends
4. Check **"Vizitatori unici"** stats
5. Review browser/device distribution

### Scenario 3: "Export all admin actions this month"

1. Go to **Audit Logs**
2. Set **Data început**: First day of month
3. Set **Data sfârșit**: Today
4. Filter by admin user email
5. Click **"Export CSV"**
6. Open in Excel/Google Sheets

### Scenario 4: "Check security threats"

1. Go to **Audit Logs**
2. Filter: **Acțiune** → "Failed login"
3. Sort by date (most recent first)
4. Look for patterns:
   - Same IP with multiple attempts
   - Attempts outside business hours
   - Unknown emails
5. Export if suspicious

## 🎓 Learn More

For detailed technical information, see:
- **AUDIT_LOGGING_README.md** - Complete technical documentation
- **AUDIT_SUMMARY.md** - Implementation summary

## 📞 Support

If you encounter issues:
1. Check this guide first
2. Review the detailed README
3. Check Rails logs: `tail -f log/development.log`
4. Verify you're an admin user

---

**Happy Auditing! 🎉**
