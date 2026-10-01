FROM php:8.1-apache

# Install required PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    /usr/local/bin/install-php-extensions

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions \
    gd \
    pdo_mysql \
    mysqli \
    mbstring \
    zip \
    xml \
    intl \
    imap \
    opcache \
    curl \
    bcmath

# Enable Apache modules required by Perfex/CodeIgniter
RUN a2enmod rewrite headers expires

# Apache document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf

RUN sed -ri \
    -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html

# Copy the application
COPY . /var/www/html/

# Create app config
RUN cp /var/www/html/application/config/app-config-sample.php /var/www/html/application/config/app-config.php

# Permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 80