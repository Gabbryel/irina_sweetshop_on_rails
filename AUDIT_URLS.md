# Audit Logging System - URLs & Access Points

## 🔗 Dashboard URLs

### Production URLs (replace with your domain)
```
https://your-domain.com/dashboard/audit_logs
https://your-domain.com/dashboard/audit_logs/statistics
https://your-domain.com/dashboard/analytics
```

### Development URLs (Local)
```
http://localhost:3006/dashboard/audit_logs
http://localhost:3006/dashboard/audit_logs/statistics
http://localhost:3006/dashboard/analytics
```

## 📋 Complete Route List

### Audit Logs Routes

| Purpose | Method | Path | Controller#Action |
|---------|--------|------|-------------------|
| List all audit logs | GET | `/dashboard/audit_logs` | `dashboard/audit_logs#index` |
| View single audit log | GET | `/dashboard/audit_logs/:id` | `dashboard/audit_logs#show` |
| View statistics | GET | `/dashboard/audit_logs/statistics` | `dashboard/audit_logs#statistics` |
| Export to CSV | GET | `/dashboard/audit_logs/export` | `dashboard/audit_logs#export` |

### Analytics Routes

| Purpose | Method | Path | Controller#Action |
|---------|--------|------|-------------------|
| Analytics dashboard | GET | `/dashboard/analytics` | `dashboard/analytics#index` |

## 🔑 Access Requirements

**All routes require:**
1. ✅ User must be authenticated (logged in)
2. ✅ User must have admin privileges (`user.admin? == true`)

**Authorization is enforced by:**
- Pundit policies (`AuditLogPolicy`, `AnalyticsPolicy`)
- Controller before_action callbacks

## 🧭 Navigation Paths

### Via Admin Menu (in Application):

1. **Log in** as admin user
2. Click **user icon** (👤) in top navigation
3. Select from dropdown:
   - **"Jurnal Activitate"** → Audit Logs
   - **"Analiză Trafic"** → Analytics

### From Audit Logs Page:

- **"Statistici"** button → Statistics Dashboard
- **"Export CSV"** button → Download CSV
- **"Detalii"** button (per row) → Individual Log Details

### From Statistics Page:

- **"← Înapoi la jurnal"** link → Back to Audit Logs

## 📊 Query Parameters

### Audit Logs Index

Filter parameters (all optional):

```
?user_id=1                    # Filter by user ID
?action_filter=login          # Filter by action type
?auditable_type=Recipe        # Filter by resource type
?start_date=2026-01-01       # Filter from date
?end_date=2026-01-31         # Filter to date
?search=192.168              # Search term (IP/email/user agent)
```

**Example URLs:**
```
# All logins this month
/dashboard/audit_logs?action_filter=login&start_date=2026-01-01

# All Recipe changes by user #5
/dashboard/audit_logs?user_id=5&auditable_type=Recipe

# Failed logins from specific IP
/dashboard/audit_logs?action_filter=failed_login&search=192.168.1.100

# All actions today
/dashboard/audit_logs?start_date=2026-01-17&end_date=2026-01-17
```

### Export CSV

Same parameters as index, format:

```
/dashboard/audit_logs/export.csv?[same_filters]
```

**Example:**
```
/dashboard/audit_logs/export.csv?action_filter=login&start_date=2026-01-01
```

## 🔍 API-Style Access (Optional)

While the system is designed for web UI access, you can fetch data programmatically:

### Get Audit Logs as JSON

Add `.json` format to any URL:

```
/dashboard/audit_logs.json
/dashboard/audit_logs/123.json
```

**Response Format:**
```json
{
  "id": 123,
  "user_id": 1,
  "action": "create",
  "auditable_type": "Recipe",
  "auditable_id": 42,
  "changes": {...},
  "ip_address": "192.168.1.1",
  "created_at": "2026-01-17T10:30:00Z"
}
```

## 🚀 Quick Access Links

### For Testing (Development):

Bookmark these for quick access during development:

```bash
# Audit Logs
open http://localhost:3006/dashboard/audit_logs

# Statistics
open http://localhost:3006/dashboard/audit_logs/statistics

# Analytics
open http://localhost:3006/dashboard/analytics

# Today's logs
open "http://localhost:3006/dashboard/audit_logs?start_date=$(date +%Y-%m-%d)&end_date=$(date +%Y-%m-%d)"

# Failed logins
open "http://localhost:3006/dashboard/audit_logs?action_filter=failed_login"
```

### For Production:

Replace `localhost:3006` with your production domain.

## 📱 Mobile Access

All dashboards are responsive and work on mobile devices:

- ✅ iPhone/iPad (iOS Safari, Chrome)
- ✅ Android (Chrome, Firefox)
- ✅ Tablets (all browsers)

**Optimized views:**
- Tables scroll horizontally on small screens
- Charts resize automatically
- Filters collapse into mobile-friendly layout
- Touch-friendly buttons and links

## 🔐 Security Notes

### Protected Routes:

All audit log and analytics routes are protected by:

1. **Authentication**: Devise `authenticate_user!`
2. **Authorization**: Pundit policies checking `user.admin?`
3. **CSRF Protection**: Rails standard CSRF tokens

### What Happens Without Access:

**Not logged in:**
- Redirected to login page: `/users/sign_in`

**Logged in but not admin:**
- Shown error: "Nu ai permisiunea necesară"
- Redirected to root path

## 🧪 Testing Access

### Check if routes are accessible:

```bash
# In Rails console
rails routes | grep audit
rails routes | grep analytics
```

### Test authentication in browser:

1. Open browser in incognito/private mode
2. Try to access: `http://localhost:3006/dashboard/audit_logs`
3. Should redirect to login
4. After login as non-admin: should show permission error
5. After login as admin: should show dashboard

### Test in Rails console:

```ruby
# Check user permissions
user = User.find_by(email: 'admin@example.com')
user.admin?  # Should return true

# Check policy
Pundit.policy!(user, AuditLog).index?  # Should return true

# Check routes
Rails.application.routes.url_helpers.dashboard_audit_logs_path
# => "/dashboard/audit_logs"
```

## 📖 Related Documentation

- **AUDIT_LOGGING_README.md** - Full technical documentation
- **AUDIT_SUMMARY.md** - Implementation summary
- **AUDIT_QUICKSTART.md** - User guide

## 💡 Pro Tips

### Bookmark These URLs:

1. **Today's Activity**: Add today's date to filters
2. **My Recent Actions**: Filter by your user ID
3. **Security Dashboard**: Failed logins filter
4. **Weekly Report**: Date range for current week

### Browser Extensions:

Consider using:
- **Link Clicker** - Quick access to bookmarked audit URLs
- **Tab Groups** - Organize audit tabs separately
- **Auto Refresh** - Monitor real-time activity

### Keyboard Shortcuts:

**macOS:**
- `Cmd + L` → Focus address bar
- `Cmd + T` → New tab for audit logs
- `Cmd + Shift + R` → Hard refresh

**Windows:**
- `Ctrl + L` → Focus address bar
- `Ctrl + T` → New tab for audit logs
- `Ctrl + Shift + R` → Hard refresh

---

**Last Updated**: January 17, 2026
**System Version**: 1.0.0
