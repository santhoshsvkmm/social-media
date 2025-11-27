FROM php:8.3-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies including Redis, FFmpeg, and image processing tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    zip \
    unzip \
    mysql-client \
    libmysqlclient-dev \
    redis-server \
    redis-tools \
    ffmpeg \
    imagemagick \
    libmagickwand-dev \
    ghostscript \
    poppler-utils \
    librsvg2-bin \
    libssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxpm-dev \
    libmemcached-dev \
    zlib1g-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install \
    mysqli \
    pdo \
    pdo_mysql \
    gd \
    zip \
    curl \
    mbstring \
    bcmath \
    intl \
    opcache \
    sockets \
    && pecl install redis memcached imagick \
    && docker-php-ext-enable redis memcached imagick \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite and proxy modules
RUN a2enmod rewrite proxy proxy_http ssl headers

# Copy application files
COPY . /var/www/html/

# Copy Apache configuration
COPY docker/apache-config.conf /etc/apache2/sites-available/000-default.conf

# Copy Redis configuration
COPY docker/redis.conf /etc/redis/redis.conf

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 777 /var/www/html/upload && \
    mkdir -p /var/log/redis && \
    chown redis:redis /var/log/redis

# Copy entrypoint script
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 80 443 6379

# Start services
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
