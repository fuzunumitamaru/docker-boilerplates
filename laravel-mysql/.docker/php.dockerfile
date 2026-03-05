FROM php:8.4-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    libzip-dev \
    zip \
    unzip \
    git \
    oniguruma-dev

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    zip \
    mbstring

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www
