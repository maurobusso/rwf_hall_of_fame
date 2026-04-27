visit the app: https://world-first-chronicles-681973011667.europe-west2.run.app/

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

World First Chronicles
A Hall of Fame for World of Warcraft World First raid clears.

🛠 Tech Stack
Framework: Ruby on Rails 8.1 (Production Mode)

Database: PostgreSQL (Hosted via Supabase)

Infrastructure: Google Cloud Platform (GCP)

Deployment: Cloud Run (Serverless)

Containerization: Docker & Google Artifact Registry

CI/CD: Google Cloud Build

Background Services: Solid Queue & Solid Cable (Rails 8 Defaults)

🚀 Useful Commands (The "Cheat Sheet")

1. Database Maintenance
   Since the app runs on Cloud Run, we use Cloud Run Jobs to interact with the database.

Run Migrations:
gcloud run jobs execute migrate-db --region europe-west2 --wait

Seed Historical Data:
gcloud run jobs execute seed-historical --region europe-west2 --wait

Sync Raider.io Data:
gcloud run jobs execute sync-raids --region europe-west2 --wait

2. Troubleshooting & Logs
   If the app fails to start or throws a 500 error, use these to see the "Ruby" side of the story:

View Web Service Logs:
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=world-first-chronicles" --limit 50 --format="value(textPayload)"

Check Job Logs (Migrations/Seeds):
gcloud logging read "resource.type=cloud_run_job" --limit 20 --format="value(textPayload)"

3. Manual Deployment
   To manually push a new version without waiting for a Git trigger:

Build: gcloud builds submit --tag [IMAGE_URL] .

Deploy: gcloud run deploy world-first-chronicles --image [IMAGE_URL] --region europe-west2

🔑 Key Learnings for Troubleshooting
Master Key: Ensure RAILS_MASTER_KEY in Secret Manager has no trailing newlines.

Database Connections: Rails 8 requires cable, cache, and queue configurations in database.yml to point to the primary DB URL in production.

Trusted Hosts: config.hosts.clear must be set in production.rb to allow Google's health checks and load balancers to reach the app.

Port Mapping: The container must listen on port 8080 (mapped via Thruster or Puma).

Mauro Assistant
Custom Gem
This project was a great example of how "standard" deployments can get tricky when you move into the latest framework versions (Rails 8) and containerized orchestration (GCP Cloud Run).

Here is the technical post-mortem of our session.

1. The Core Problem during deployment
   The application was failing to boot in the cloud, resulting in a silent exit(1) error. While the code worked locally, the Cloud Run service would crash immediately upon starting, even though the deployment itself was marked as "Successful" by Google.

2. Why it happened (The "Silent Killers")
   We identified three specific reasons why the app was panicking during the boot sequence:

Database Infrastructure Mismatch: Rails 8 introduces Solid Cable, Solid Cache, and Solid Queue. By default, these look for separate databases (e.g., a cable database). Because your database.yml only defined a primary database, the app crashed looking for the missing configurations.

The Trusted Hosts Gate: Rails has a security feature that blocks requests from unknown URLs. Since Google Cloud Run uses dynamic URLs for health checks, Rails was rejecting the connection before the app could even "check in" as healthy.

The Secret "Newline" Trap: We discovered that a common point of failure is how secrets (like the DATABASE_URL) are stored in Google Secret Manager. A single hidden space or newline can make a database connection string invalid.

3. The Solutions
   We moved through a tiered troubleshooting strategy to solve these:

Database Consolidation: We updated database.yml to point the cable, cache, and queue roles to the same DATABASE_URL as the primary app.

YAML
cable:
<<: \*primary_production
migrations_paths: db/cable_migrate
Connectivity Debugging: We used Cloud Run Jobs to run bin/rails runner commands. This allowed us to test if the app could talk to Supabase outside of the web server environment.

Web Server Configuration: We added config.hosts.clear to production.rb and ensured the container was listening on Port 8080, which is the Google Cloud standard.

4. What We Learnt
   Jobs vs. Services: You learned that a Service is for users (always listening), while a Job is for tasks (migrations, scripts, seeds). If a Job works but a Service fails, the problem is likely the web-server handshake (Ports/Hosts).

Rails 8 Defaults: You saw firsthand how Rails 8's new "Solid" suite (Queue/Cable) changes the requirements for database.yml.

Docker Multi-stage Builds: We used a Dockerfile that separates the "Build" environment (where we compile gems) from the "Base" environment (where the app runs). This keeps the final image small and secure.

The Power of Logs: You learned how to use gcloud logging read to peer inside a crashing container. Instead of guessing, we found the exact line: ActiveRecord::AdapterNotSpecified: The cable database is not configured.
