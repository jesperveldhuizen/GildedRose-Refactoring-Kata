# src: https://github.com/qlico/project-examples/blob/main/Dockerfile.php80-minimal
FROM harbor.webstores.nl/docker-hub-cache/library/php:8.1.13-fpm-alpine3.17 as base
LABEL maintainer="Qlico <hello@qlico.dev>"

ARG LOCAL_USER_ID=1000
ARG LOCAL_GROUP_ID=1000

# persistent / runtime depsfmusl
ENV PHPIZE_DEPS \
    autoconf \
    cmake \
    file \
    freetype-dev \
    g++ \
    gcc \
    gettext-dev \
    git \
    icu-dev \
    imagemagick-dev \
    libc-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    make \
    pcre-dev \
    pkgconf \
    postgresql-dev \
    rabbitmq-c-dev \
    re2c

RUN apk add --no-cache --virtual .persistent-deps \
    fcgi \
    freetype \
    gettext \
    git \
    gnu-libiconv \
    icu \
    imagemagick \
    libintl \
    libpq \
    libpng \
    libzip \
    rabbitmq-c \
    && apk add --no-cache --virtual .build-deps \
       $PHPIZE_DEPS \
    && docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-install -j "$(nproc)" \
       bcmath \
       exif \
       gd \
       gettext \
       intl \
       opcache \
       pcntl \
       pdo_mysql \
       pdo_pgsql \
       shmop \
       soap \
       sockets \
       sysvmsg \
       sysvsem \
       sysvshm \
       zip \
    && pecl install \
       APCu \
       ds \
       imagick \
       redis \
       amqp \
    && docker-php-ext-enable \
       apcu \
       ds \
       imagick \
       redis \
       amqp \
    && apk del .build-deps \
    && docker-php-source delete \
    && apk --no-cache -U upgrade \
    && rm -rf /tmp/* \
    && addgroup -g $LOCAL_GROUP_ID -S qlico \
    && adduser -u $LOCAL_USER_ID -S qlico -G qlico

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer.phar

# Necessary for iconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Add composer and php scripts for aliases.
COPY qlico/services/php/scripts /usr/local/sbin
RUN chmod +x /usr/local/sbin/composer \
             /usr/local/sbin/php

# Disabled access logs for php-fpm
RUN sed -i 's/access.log = \/proc\/self\/fd\/2/access.log = \/proc\/self\/fd\/1/g' /usr/local/etc/php-fpm.d/docker.conf

# php.ini
COPY qlico/services/php/prod/php.ini $PHP_INI_DIR

# www.cnf
COPY qlico/services/php/www.conf /usr/local/etc/php-fpm.d/www.conf

# @TODO: Dit moet op een later moment weer worden verwijdert!
COPY qlico/services/php/prod/zzz-instana-extras.ini /usr/local/etc/php/conf.d/zzz-instana-extras.ini

# Don't run as the default (root) user.
USER qlico

CMD ["php-fpm"]

FROM base as dev
USER root

RUN apk add --no-cache --virtual . \
    # Local mail handling
    msmtp

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
       $PHPIZE_DEPS \
    && pecl install \
       xdebug-3.1.6 \
    && docker-php-ext-enable \
       xdebug \
    && apk del .build-deps

# MSMTP config.
COPY qlico/services/php/dev/msmtprc /etc/msmtprc

# Xdebug config.
COPY qlico/services/php/dev/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# php.ini
COPY qlico/services/php/dev/php.ini /usr/local/etc/php

# Don't run as the default (root) user.
USER qlico

CMD ["php-fpm"]

FROM base as prod
USER root

RUN set -xe \
    # Remove packages we don't want in production
    && rm -rf /usr/local/sbin/composer \
    && rm -rf /usr/local/bin/composer.phar \
    && apk del git \
    && rm -rf /usr/bin/git \
    # create app folder
    && mkdir /app \
    && chown qlico: /app

USER qlico

# Copy the application to the Docker image.
COPY . /app

USER root

# Remove qlico folder.
RUN rm -rf /app/qlico

# Don't run as the default (root) user.
USER qlico

CMD ["php-fpm"]
