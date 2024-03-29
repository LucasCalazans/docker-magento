FROM php:7.2-fpm

# Updating and installing some dependences
# TODO remove suggested packages.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libmcrypt-dev \
    libxslt-dev \
    libicu-dev \
    libmemcached-dev \
    zlib1g-dev \
    libmagickwand-dev \
    libmagickcore-dev \
    msmtp \
    git \
    nano \
    gnupg \
    sudo \
    cron && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) \
    bcmath \
    pdo_mysql \
    xsl \
    intl \
    zip \
    soap \
    sockets \
    gd \
    opcache && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    apt-get purge -y --auto-remove

# Installing pecl PHP modules
RUN pecl install \
    xdebug-2.6.0 \
    imagick-3.4.3 \
    mcrypt-1.0.1 && \
    docker-php-ext-enable \
    xdebug \
    imagick \
    sockets \
    mcrypt

# Installing extra components
RUN npm install -g grunt-cli && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    mkdir -p /var/www/.composer && \
    usermod -u 1000 www-data && \
    groupmod -g 1000 www-data && \
    adduser www-data sudo && \
    echo 'www-data ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    chown -R www-data:www-data /var/www/ && \
    chmod -R g+w /var/www/