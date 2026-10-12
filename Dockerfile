FROM php:8.2-apache-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libicu-dev \
    libc-client-dev \
    libkrb5-dev \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mysqli \
        gd \
        zip \
        xml \
        mbstring \
        intl \
        imap \
        opcache \
        exif \
        bcmath

# Enable required Apache modules
RUN a2enmod rewrite headers expires

# Replace default Apache vhost with Perfex-specific config
COPY docker/apache/perfex.conf /etc/apache2/sites-available/000-default.conf
COPY docker/php/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

WORKDIR /var/www/html

# Copy application files
COPY . .

# Ensure app-config.php is initialized from sample if not present
RUN if [ ! -f /var/www/html/application/config/app-config.php ]; then \
        cp /var/www/html/application/config/app-config-sample.php /var/www/html/application/config/app-config.php; \
    fi

# Set ownership and permissions
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && chmod -R 775 /var/www/html/uploads \
    && chmod -R 775 /var/www/html/temp \
    && chmod -R 775 /var/www/html/application/cache \
    && chmod -R 775 /var/www/html/application/logs

EXPOSE 80