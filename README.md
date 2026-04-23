# RWF Hall of Fame

A Rails application that displays World of Warcraft raid "world first" winners by syncing data from the Raider.io Hall of Fame API.

## Overview

- Built with Ruby `4.0.1` and Rails `8.1.2`
- Uses PostgreSQL for persistence
- Includes modern Rails tooling: Propshaft, Importmap, Tailwind CSS, Turbo, Stimulus
- Fetches raid winner data through `RaiderIoClient` and stores it in the `winners` table
- Root page is `winners#index`, with support for manual sync via a POST to `winners/sync`

## Features

- List raid world-first winners
- Sync raid records from Raider.io via `lib/tasks/fetch_all_raids.rake`
- Pre-seeded historical raid data in `db/seeds.rb`
- Health check endpoint at `/up`

## Requirements

- Ruby `4.0.1`
- PostgreSQL 17+ (or compatible PostgreSQL version)
- Node is not required because the app uses importmap and Tailwind via Rails
- `bundle` and `rails` installed in the project

## Setup

1. Install dependencies:

```bash
bundle install
```

2. Start PostgreSQL if needed:

```bash
brew services start postgresql@17
```

3. Create and migrate the database:

```bash
bin/rails db:create db:migrate
```

4. Seed initial historical data:

```bash
bin/rails db:seed
```

## Running the app locally

Start the app and CSS watcher together with:

```bash
bin/dev
```

Then open:

- `http://localhost:3000` for the app
- `http://localhost:3000/up` for the health check

If you prefer a single Rails server only:

```bash
bin/rails server
```

## Data sync

This project can load raid winners from the Raider.io API using the task in `lib/tasks/fetch_all_raids.rake`.

To sync raid data from `db/raids_manifest.yml`:

```bash
bin/rails fetch_all_raids:sync
```

If a record already exists for a raid slug, the task skips it. It will persist new results into the `winners` table.

### Sync endpoint

The route `POST /winners/sync` is defined in `config/routes.rb` and triggers manual sync behavior from the front-end.

## Database schema

The `winners` table contains:

- `raid_slug` - unique identifier for each raid
- `raid_name` - raid display name
- `expansion_name` - expansion category
- `guild_name` - guild that secured the world first
- `region` - guild region short code
- `kill_date` - world-first kill date
- `created_at`, `updated_at`

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

The repo currently includes service and task specs under `spec/services` and `spec/tasks`.

## Configuration

Database settings are managed in `config/database.yml`.

For production, supply `RWF_HALL_OF_FAME_DATABASE_PASSWORD` as the database password environment variable.

## Deployment notes

- The repository includes `Dockerfile` and `Procfile.dev` for containerized or local development.
- `kamal` is available in the Gemfile for deployment automation if desired.

## Notes

- External data is fetched from the Raider.io Hall of Fame API via `app/client/raider_io_client.rb`.
- `db/raids_manifest.yml` contains raid slugs and expansion metadata used by the sync task.
- Historic raid winners can be populated from `db/seeds.rb` when starting a new database.
