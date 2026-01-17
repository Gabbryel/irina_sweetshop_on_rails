# Audit Logging & Analytics System

## Overview

A comprehensive audit logging and analytics system has been implemented for the Irina Sweetshop Rails application. This system tracks all CRUD operations, authentication events (login/logout/failed attempts), and provides detailed analytics with visualizations.

## Features

### 1. Audit Logging System

#### What is tracked:
- **CRUD Operations**: All create, update, and destroy actions on resources
- **Authentication Events**: Login, logout, and failed login attempts
- **User Information**: Associated user for each action
- **Technical Details**: IP address, user agent, request ID
- **Resource Information**: Type and ID of affected resources
- **Changes**: JSON representation of changes made

#### Key Components:

**Models:**
- `AuditLog` - Main model for tracking all audit events
- Located at: `app/models/audit_log.rb`

**Controllers:**
- `Dashboard::AuditLogsController` - Main dashboard for viewing audit logs
- Located at: `app/controllers/dashboard/audit_logs_controller.rb`

**Concerns:**
- `AuditTrackable` - Automatically tracks CRUD operations
- Located at: `app/controllers/concerns/audit_trackable.rb`

**Initializers:**
- `audit_tracking.rb` - Configures Devise authentication tracking
- Located at: `config/initializers/audit_tracking.rb`

**Policies:**
- `AuditLogPolicy` - Restricts access to admin users only
- Located at: `app/policies/audit_log_policy.rb`

### 2. Ahoy Analytics System

#### What is tracked:
- **Visits**: All page visits with user association
- **Events**: Custom events throughout the application
- **Browser Information**: Browser type and version
- **Operating System**: OS type
- **Device Type**: Desktop, mobile, tablet
- **Visitor Tokens**: For tracking unique visitors

#### Key Components:

**Models:**
- `Ahoy::Visit` - Tracks visits
- `Ahoy::Event` - Tracks custom events

**Controllers:**
- `Dashboard::AnalyticsController` - Analytics dashboard
- Located at: `app/controllers/dashboard/analytics_controller.rb`

**Configuration:**
- `ahoy.rb` - Ahoy configuration with user association
- Located at: `config/initializers/ahoy.rb`

### 3. Dashboards & Visualizations

#### Audit Logs Dashboard
**URL:** `/dashboard/audit_logs`

**Features:**
- Paginated list of all audit logs (25 per page)
- Advanced filters:
  - Filter by user
  - Filter by action type (create, update, destroy, login, logout, failed_login)
  - Filter by resource type
  - Date range filter (start and end date)
  - Search by IP address, user agent, or email
- Export to CSV functionality
- Color-coded action badges
- Detailed view for each log entry

#### Audit Statistics Dashboard
**URL:** `/dashboard/audit_logs/statistics`

**Features:**
- Summary cards showing:
  - Total events
  - Today's events
  - This week's events
  - This month's events
- Authentication statistics (login/logout/failed attempts)
- CRUD operations breakdown
- Charts and visualizations:
  - Daily activity (line chart - last 30 days)
  - Activity by action type (pie chart - last 30 days)
  - Hourly activity (column chart - today)
  - Activity by resource type (bar chart - current month)
- Top 10 most active users table

#### Analytics Dashboard
**URL:** `/dashboard/analytics`

**Features:**
- Visit statistics (total, today, week, month)
- Unique visitor counts
- User type breakdown (authenticated vs. guest)
- Charts and visualizations:
  - Visits by day (line chart - last 30 days)
  - Visits by hour (column chart - today)
  - Browser distribution (pie chart)
  - Operating system distribution (pie chart)
  - Device type distribution (bar chart)
  - Top 10 events table
- Event statistics

## Installation & Setup

The system is already installed and configured. Here's what was done:

### 1. Gems Added:
```ruby
gem 'ahoy_matey'  # Analytics and visit tracking
gem 'chartkick'   # Charts for visualizations
gem 'groupdate'   # Group by date for statistics
```

### 2. Database Migrations:
```bash
rails db:migrate
```

Three tables were created:
- `ahoy_visits` - Stores visit information
- `ahoy_events` - Stores event information
- `audit_logs` - Stores audit log entries

### 3. JavaScript Dependencies:
```bash
yarn add chartkick chart.js
```

## Usage

### Accessing the Dashboards

**Admin users** can access all dashboards through the user dropdown menu:
- "Jurnal Activitate" → Audit Logs
- "Analiză Trafic" → Analytics

Or via direct URLs:
- Audit Logs: `/dashboard/audit_logs`
- Audit Statistics: `/dashboard/audit_logs/statistics`
- Analytics: `/dashboard/analytics`

### Exporting Data

**CSV Export:**
Navigate to the Audit Logs dashboard and click "Export CSV". The export will include all currently applied filters.

**Format:**
```csv
ID,User,Action,Auditable Type,Auditable ID,IP Address,Created At
```

### Filtering Audit Logs

Use the filter form to narrow down results:
1. **User Filter**: Select a specific user
2. **Action Filter**: Choose an action type
3. **Resource Type Filter**: Filter by resource type (Recipe, Cakemodel, etc.)
4. **Date Range**: Set start and end dates
5. **Search**: Search by IP, email, or user agent

Click "Filtrează" to apply filters or "Resetează" to clear them.

## How It Works

### CRUD Tracking

The `AuditTrackable` concern is included in `ApplicationController` and automatically tracks:
- **After create**: Logs the new record with all attributes
- **After update**: Logs the changed attributes with before/after values
- **After destroy**: Logs the deleted record's final state

**Example:**
```ruby
# When a Recipe is created
AuditLog.create(
  user: current_user,
  action: 'create',
  auditable: @recipe,
  changes: { "name" => [nil, "New Recipe"], "price_cents" => [nil, 5000] },
  ip_address: "192.168.1.1",
  user_agent: "Mozilla/5.0...",
  request_id: "abc123..."
)
```

### Authentication Tracking

Warden callbacks (configured in `config/initializers/audit_tracking.rb`) track:
- **Successful login**: When user logs in
- **Logout**: When user logs out
- **Failed login**: When authentication fails

**Example:**
```ruby
# When user logs in
AuditLog.create(
  user: user,
  action: 'login',
  changes: { email: user.email },
  ip_address: request.remote_ip,
  ...
)
```

### Visit & Event Tracking

Ahoy automatically tracks:
- **Visits**: Each unique visit to the site
- **Events**: Custom events defined throughout the app

The `ApplicationController` includes an `after_action :track_action` that logs every controller action as an Ahoy event.

## Security

- **Admin-only access**: All dashboards are restricted to admin users via Pundit policies
- **No sensitive data exposure**: Password fields and sensitive data are never logged
- **Request tracking**: Each audit log includes request_id for correlation
- **IP logging**: IP addresses are logged for security auditing

## Database Schema

### AuditLog Table
```ruby
create_table :audit_logs do |t|
  t.references :user, foreign_key: true
  t.string :action, null: false
  t.string :auditable_type
  t.integer :auditable_id
  t.jsonb :changes, default: {}
  t.string :ip_address
  t.string :user_agent
  t.string :request_id
  t.timestamps
end

# Indexes
add_index :audit_logs, [:auditable_type, :auditable_id]
add_index :audit_logs, :action
add_index :audit_logs, :created_at
```

### Ahoy Tables
```ruby
create_table :ahoy_visits do |t|
  t.string :visit_token
  t.string :visitor_token
  t.references :user, foreign_key: true
  t.string :ip
  t.text :user_agent
  t.text :referrer
  t.string :landing_page
  t.string :browser
  t.string :os
  t.string :device_type
  t.datetime :started_at
end

create_table :ahoy_events do |t|
  t.references :visit
  t.references :user
  t.string :name
  t.jsonb :properties
  t.datetime :time
end
```

## Customization

### Adding Custom Events

To track custom events, use Ahoy in your controllers:

```ruby
# In any controller action
ahoy.track "Order Placed", { order_id: @order.id, total: @order.total }
```

### Excluding Controllers from Tracking

To exclude a controller from audit tracking, override the concern method:

```ruby
class PublicController < ApplicationController
  private
  
  def should_track_audit?
    false
  end
end
```

### Adding New Audit Actions

To add a new action type, update `AuditLog::ACTIONS`:

```ruby
ACTIONS = {
  create: 'create',
  update: 'update',
  destroy: 'destroy',
  login: 'login',
  logout: 'logout',
  failed_login: 'failed_login',
  your_new_action: 'your_new_action'  # Add here
}.freeze
```

## Troubleshooting

### Audit logs not appearing
1. Check that the user is authenticated
2. Verify the action is in the trackable actions list (create, update, destroy)
3. Check Rails logs for any errors

### Charts not rendering
1. Ensure JavaScript is loaded: check browser console
2. Verify chartkick and chart.js are installed: `yarn list chartkick`
3. Rebuild assets: `yarn build`

### Performance Issues
1. Add date range filters to limit results
2. Consider archiving old logs (> 1 year)
3. Add pagination (already implemented with Pagy)

## Routes

```ruby
namespace :dashboard do
  resources :audit_logs, only: [:index, :show] do
    collection do
      get :statistics
      get :export
    end
  end
  
  resource :analytics, only: [:index]
end
```

## Files Created/Modified

### New Files:
- `app/models/audit_log.rb`
- `app/models/ahoy/visit.rb`
- `app/models/ahoy/event.rb`
- `app/controllers/dashboard/audit_logs_controller.rb`
- `app/controllers/dashboard/analytics_controller.rb`
- `app/controllers/concerns/audit_trackable.rb`
- `app/policies/audit_log_policy.rb`
- `app/policies/analytics_policy.rb`
- `app/views/dashboard/audit_logs/index.html.erb`
- `app/views/dashboard/audit_logs/show.html.erb`
- `app/views/dashboard/audit_logs/statistics.html.erb`
- `app/views/dashboard/analytics/index.html.erb`
- `config/initializers/ahoy.rb`
- `config/initializers/audit_tracking.rb`
- `db/migrate/XXXXXX_create_ahoy_visits_and_events.rb`
- `db/migrate/XXXXXX_create_audit_logs.rb`

### Modified Files:
- `Gemfile`
- `app/javascript/application.js`
- `app/controllers/application_controller.rb`
- `app/models/user.rb`
- `app/views/shared/_navbar.html.erb`
- `config/routes.rb`

## Maintenance

### Regular Tasks:
1. **Review logs weekly**: Check for unusual patterns or failed login attempts
2. **Archive old logs**: Consider moving logs older than 1 year to cold storage
3. **Monitor disk space**: Audit logs can grow large over time
4. **Check statistics**: Review statistics dashboard monthly for insights

### Recommended Cleanup Query (run in Rails console):
```ruby
# Delete audit logs older than 1 year
AuditLog.where('created_at < ?', 1.year.ago).delete_all

# Delete ahoy visits older than 6 months
Ahoy::Visit.where('started_at < ?', 6.months.ago).delete_all
```

## Support

For issues or questions, refer to the gem documentation:
- [Ahoy Matey](https://github.com/ankane/ahoy)
- [Chartkick](https://chartkick.com/)
- [Groupdate](https://github.com/ankane/groupdate)
