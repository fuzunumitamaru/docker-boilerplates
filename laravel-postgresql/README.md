# Laravel + PostgreSQL Docker Setup

Docker development environment for Laravel using Nginx + PHP-FPM, PostgreSQL, Redis, Mailpit, and Adminer.

---

## 📦 Stack

| Service | Image | Port |
|---------|-------|------|
| Nginx | nginx:alpine | 8000 |
| PHP-FPM | php:8.4-fpm-alpine | — |
| PostgreSQL | postgres:18-alpine | 5432 |
| Redis | redis:8-alpine | 6379 |
| Mailpit | axllent/mailpit | 8025, 1025 |
| Adminer | adminer:latest | 8080 |

---

## 🚀 Setup

### 1. Configure environment

Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

```env
POSTGRES_DB=laravel_postgres_system
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_password
```

---

### 2. Fix permissions (Linux/WSL only)

```bash
sudo chown -R 999:999 .docker/data
```

---

### 3. Start services

```bash
docker compose up -d
```

---

### 4. Create Laravel project

```bash
docker compose exec app sh
composer create-project laravel/laravel . --ignore-platform-reqs
exit
```

---

### 5. Configure Laravel `.env`

```env
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=laravel_postgres_system
DB_USERNAME=your_user
DB_PASSWORD=your_password

REDIS_HOST=redis
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
```

---

### 6. Run migrations

```bash
docker compose exec app php artisan migrate
```

Done! ✅

---

## 🌐 URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Laravel | http://localhost:8000 | — |
| Adminer | http://localhost:8080 | your_user / your_password |
| Mailpit | http://localhost:8025 | — |

### Adminer Login Details
When prompted by Adminer use these values:

| Field | Value |
|-------|-------|
| System | PostgreSQL |
| Server | postgres |
| Username | your_user |
| Password | your_password |
| Database | laravel_postgres_system |

---

## 📝 Common Commands

```bash
# Start / stop
docker compose up -d
docker compose down

# View logs
docker compose logs -f
docker compose logs -f app           # PHP-FPM only
docker compose logs -f nginx         # Nginx only
docker compose logs -f postgres      # PostgreSQL only

# Enter containers
docker compose exec app sh           # PHP container
docker compose exec postgres sh      # PostgreSQL container

# PostgreSQL CLI inside container
docker compose exec postgres psql -U your_user -d laravel_postgres_system

# Laravel artisan
docker compose exec app php artisan migrate
docker compose exec app php artisan cache:clear
docker compose exec app php artisan queue:work

# Composer
docker compose exec app composer install
docker compose exec app composer require package/name

# Rebuild containers after dockerfile changes
docker compose up -d --build
```

---

## 🔧 Notes

- **PostgreSQL** runs on port `5432` — default port, no conflict risk unlike MySQL
- **PHP-FPM** is internal only — not exposed, only accessible via Nginx
- **Data** is stored in `.docker/data/` and persists between restarts
- **PostgreSQL config** is loaded from `.docker/postgresql_dev.conf` — includes slow query logging, SSD-optimized settings, and autovacuum tuning
- **To reset the database:** `sudo rm -rf .docker/data/postgres`
- **To reset Redis:** `sudo rm -rf .docker/data/redis`

---

## 🏭 Production

A production-ready PostgreSQL config is available at `.docker/postgresql_prod.conf` for reference. Key differences from dev:

- Higher memory settings sized for a dedicated DB server (8-16GB RAM)
- WAL archiving enabled for point-in-time recovery
- Replication ready (`wal_level = replica`, `max_wal_senders = 10`)
- SSL/TLS config stubs included
- `auto_explain` for automatic slow query analysis
- Aggressive autovacuum tuning to prevent table bloat
- `statement_timeout` to kill runaway queries
- PgBouncer recommended for connection pooling at scale

Before going to production, refer to the checklist at the bottom of `postgresql_prod.conf`.

---

## 📁 Directory Structure

```
.
├── .docker/
│   ├── data/
│   │   ├── postgres/           # PostgreSQL data (gitignored)
│   │   └── redis/              # Redis data (gitignored)
│   ├── postgresql_dev.conf     # PostgreSQL dev config
│   ├── postgresql_prod.conf    # PostgreSQL prod config (reference)
│   ├── nginx.conf              # Nginx config
│   └── php.dockerfile          # PHP-FPM image
├── .env                        # Your local env (gitignored)
├── .env.example                # Env template (committed)
└── docker-compose.yml
```

---
