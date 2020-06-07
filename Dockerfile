FROM debian:buster

LABEL maintainer="Jônatan Gouveia jonatan@linuxsolutions.xyz"

LABEL version="1.0.0"

LABEL company="Linux Solutions."

ENV COMPOSER_VERSION 1.10.7
ARG NODE_SETUP="setup_14.x"

#Prepare Image
RUN apt-get update \
    && apt-get install --no-install-recommends $buildDeps --no-install-suggests -q -y gnupg2 dirmngr wget apt-transport-https lsb-release ca-certificates

#Install Util
RUN apt-get install --no-install-recommends --no-install-suggests -q -y \
    curl \
    vim \
    git \
    sudo \
    rsync \
    zip \
    unzip \
    python-pip \
    python-setuptools \
    mariadb-client \
    ssh \
    openssh-client

# Prepare install PHP
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update

# Install PHP
RUN apt-get install --no-install-recommends --no-install-suggests -q -y \
    php7.4-fpm \
    php7.4-cli \
    php7.4-bcmath \
    php7.4-dev \
    php7.4-common \
    php7.4-json \
    php7.4-opcache \
    php7.4-readline \
    php7.4-mbstring \
    php7.4-curl \
    php7.4-gd \
    php7.4-mysql \
    php7.4-zip \
    php7.4-pgsql \
    php7.4-intl \
    php7.4-xml \
    php-pear \
    php-ast \
    php7.4-ctype \
    php7.4-xml \
    php7.4-xmlreader \
    php7.4-xmlwriter \
    php7.4-phar

# Install Composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} && rm -rf /tmp/composer-setup.php

# Install WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install NODE and NPM
RUN curl -sL https://deb.nodesource.com/${NODE_SETUP} | bash - \
    && apt-get install -y nodejs

# Add Yarn repository
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Install Yarn
RUN apt-get update -y \
    && apt-get install -y yarn

# Clean up
RUN rm -rf /tmp/pear \
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*