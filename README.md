# AdminResources

A mountable Rails engine that automatically generates a full admin dashboard for your models. Register the models you want to manage, mount the engine, and you get a complete CRUD interface with zero boilerplate controllers or views in your app.

**Features:**
- Auto-generated index, show, new, edit, and delete for every registered model
- Dashboard with record counts for all registered models
- Built-in admin authentication via Devise (own `AdminUser` model, own table)
- Smart field rendering: JSON/JSONB pretty-printed, foreign keys linked to related admin pages, booleans as Yes/No, datetimes formatted
- Smart form generation: checkboxes for booleans, dropdowns for foreign keys, textareas for JSON, etc.
- `has_one` and `has_many` associations shown inline on show pages
- Your own styling — dark sidebar, clean table layout, no external CSS dependencies

---

## Requirements

- Rails 7.0+
- Ruby 3.0+
- Devise 4.0+
- PostgreSQL (for array column support) — other databases work but array columns won't be handled

---

## Installation

Add to your `Gemfile`:

```ruby
gem "admin_resources", github: "doeswork/admin_resources"
```

Or for local development:

```ruby
gem "admin_resources", path: "../admin_resources"
```

Then run:

```bash
bundle install
```

---

## Setup

### 1. Run the migration

Copy and run the engine's migration to create the `admin_resources_admin_users` table:

```bash
rails admin_resources:install:migrations
rails db:migrate
```

### 2. Mount the engine

In `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount AdminResources::Engine, at: "/admin"

  # ... rest of your routes
end
```

### 3. Configure your models

Create `config/initializers/admin_resources.rb`:

```ruby
AdminResources.configure do |config|
  # Register with specific index columns:
  config.register "User",     columns: %w[id email created_at]
  config.register "Post",     columns: %w[id title user_id published_at]

  # Register without columns — defaults to first 6 columns:
  config.register "Comment"
  config.register "Tag"
end
```

### 4. Create your first admin user

Open a Rails console and create an `AdminResources::AdminUser`:

```ruby
AdminResources::AdminUser.create!(
  email: "admin@example.com",
  password: "yourpassword",
  password_confirmation: "yourpassword"
)
```

Then visit `/admin` and sign in.

---

## Configuration reference

`config.register` accepts:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `columns` | `Array<String>` | first 6 columns | Column names to display in the index table |

```ruby
AdminResources.configure do |config|
  config.register "ModelName", columns: %w[col1 col2 col3]
end
```

Model names must be strings matching the exact class name (e.g. `"WorkflowStep"`, not `"workflow_step"`).

---

## What gets generated automatically

For each registered model, the engine provides:

| Route | Description |
|-------|-------------|
| `GET /admin/users` | Index — paginated table of all records |
| `GET /admin/users/new` | New form |
| `POST /admin/users` | Create |
| `GET /admin/users/:id` | Show — all columns + associations |
| `GET /admin/users/:id/edit` | Edit form |
| `PATCH /admin/users/:id` | Update |
| `DELETE /admin/users/:id` | Destroy |

Route helpers follow the pattern `admin_resources_<plural>_path` and `admin_resources_<singular>_path`.

---

## How field rendering works

### Index + show pages

| Value type | Rendered as |
|------------|-------------|
| `nil` | *nil* (italic, grey) |
| JSON / JSONB column | `<pre>` with pretty-printed JSON |
| Column named `params` or `data` | Same as JSON |
| Foreign key (`*_id`) pointing to a registered model | Clickable link to that record's admin show page |
| `Boolean` | Yes / No |
| `Time` / `DateTime` | `YYYY-MM-DD HH:MM:SS` |
| Everything else | Plain text (truncated to 50 chars on index) |

### Forms

| Column type | Field rendered |
|-------------|----------------|
| `:boolean` | Checkbox |
| `:text` | Textarea (4 rows) |
| `:integer`, `:decimal`, `:float` | Number input |
| `:date` | Date picker |
| `:datetime` | Datetime-local picker |
| `:json`, `:jsonb` | Textarea (serialized to JSON) |
| `*_id` foreign key | Dropdown (`collection_select`) populated with all records of the associated model |
| Column name contains `password` | Password input |
| Column name contains `email` | Email input |
| Everything else | Text input |

### Show page associations

The show page automatically renders:

- **`has_one`** associations: shown as a detail card below the main record, with View/Edit links if the associated model is also registered
- **`has_many`** associations: shown as a table (limited to 20 rows) with a count and "New" link if the associated model is registered

---

## Authentication

The engine bundles its own `AdminResources::AdminUser` model with Devise. It lives in a separate table (`admin_resources_admin_users`) and is completely independent from any `User` model in your app.

Devise modules included: `database_authenticatable`, `recoverable`, `rememberable`, `validatable`.

All admin routes require a signed-in `AdminResources::AdminUser`. Unauthenticated requests are redirected to the admin login page.

---

## Development

Clone the repo and install dependencies:

```bash
git clone https://github.com/doeswork/admin_resources
cd admin_resources
bundle install
```

To install onto a local Rails app for testing, add `gem "admin_resources", path: "/path/to/admin_resources"` to that app's Gemfile.

To release a new version, update `lib/admin_resources/version.rb` and run:

```bash
bundle exec rake release
```

---

## Contributing

Bug reports and pull requests are welcome at https://github.com/doeswork/admin_resources.
