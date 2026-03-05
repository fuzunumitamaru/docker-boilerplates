# Laravel + MySQL Docker Setup

Docker development environment for Laravel using Nginx + PHP-FPM, MySQL, Redis, Mailpit, and phpMyAdmin.

---

## 📦 Stack

| Service | Image | Port |
|---------|-------|------|
| Nginx | nginx:alpine | 8000 |
| PHP-FPM | php:8.4-fpm-alpine | — |
| MySQL | mysql:8.4-oracle | 3307 |
| Redis | redis:8-alpine | 6379 |
| Mailpit | axllent/mailpit | 8025, 1025 |
| phpMyAdmin | phpmyadmin:latest | 8080 |

---

## 🚀 Setup

### 1. Configure environment

Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

```env
MYSQL_DATABASE=laravel_mysql_system
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_USER=your_user
MYSQL_PASSWORD=your_password
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
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel_mysql_system
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
| phpMyAdmin | http://localhost:8080 | root / your_root_password |
| Mailpit | http://localhost:8025 | — |

---

## 📝 Common Commands

```bash
# Start / stop
docker compose up -d
docker compose down

# View logs
docker compose logs -f
docker compose logs -f app        # PHP-FPM only
docker compose logs -f nginx      # Nginx only
docker compose logs -f mysql      # MySQL only

# Enter containers
docker compose exec app sh        # PHP container
docker compose exec mysql sh      # MySQL container

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

- **MySQL** runs on port `3307` (to avoid conflicts with any local MySQL install)
- **PHP-FPM** is internal only — not exposed, only accessible via Nginx
- **Data** is stored in `.docker/data/` and persists between restarts
- **MySQL config** is loaded from `.docker/my_dev.cnf` — includes slow query logging, utf8mb4, and InnoDB tuning
- **To reset the database:** `sudo rm -rf .docker/data/mysql`
- **To reset Redis:** `sudo rm -rf .docker/data/redis`

---

## 🏭 Production

A production-ready MySQL config is available at `.docker/my_prod.cnf` for reference. Key differences from dev:

- Strict SQL mode enabled
- Binary logging for backups and replication
- Higher connection limits and buffer pool sized for dedicated DB server (8-16GB RAM)
- `log_queries_not_using_indexes` disabled (too verbose in production)
- Security hardening — `local-infile` disabled, SSL/TLS config stubs included

Before going to production, refer to the checklist at the bottom of `my_prod.cnf`.

---

## 📁 Directory Structure

```
.
├── .docker/
│   ├── data/
│   │   ├── mysql/          # MySQL data (gitignored)
│   │   └── redis/          # Redis data (gitignored)
│   ├── my_dev.cnf          # MySQL dev config
│   ├── my_prod.cnf         # MySQL prod config (reference)
│   ├── nginx.conf          # Nginx config
│   └── php.dockerfile      # PHP-FPM image
├── .env                    # Your local env (gitignored)
├── .env.example            # Env template (committed)
└── docker-compose.yml
```

---
