FROM ubuntu:20.10
ENV TZ=Europe/Warsaw
LABEL pl.salamonrafal.version="0.0.3" pl.salamonrafal.author="Rafal\ Salamon\ <rasa@salamonrafal.pl>"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -yqq update && apt-get -yqq install nginx \
    php \
    php-cli \
    php-fpm \
    php-json \
    php-pdo \
    php-mysql \
    php-mongodb \
    php-curl \
    php-zip \
    php-gd \
    php-mbstring \
    php-curl \
    php-xml \
    php-pear \
    php-bcmath \
    php-xmlrpc \
    php-pgsql \
    mc \
    && rm -rf /var/lib/apt/lists/*
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'c31c1e292ad7be5f49291169c0ac8f683499edddcfd4e42232982d0fd193004208a58ff6f353fde0012d35fdd72bc394') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

COPY docker/nginx/welcome-html /var/www/welcome/
COPY . /var/www/web-server
COPY docker/php-fpm/www.conf /etc/php/7.4/fpm/pool.d/
COPY docker/nginx/sites-available /etc/nginx/sites-available/
COPY docker/nginx/sites-available /etc/nginx/sites-enabled/
COPY docker/nginx/snippets /etc/nginx/snippets/
COPY docker/entrypoint.sh /etc/entrypoint.sh

RUN chmod -R 777 /var/www/web-server/
RUN chmod -R 777 /var/www/welcome/
RUN chown -R www-data:www-data /var/www/web-server/
RUN chown -R www-data:www-data /var/www/welcome/

EXPOSE 80 8080

ENTRYPOINT service php7.4-fpm restart && \
    service nginx start && \
    (cd /var/www/web-server/ && \
    composer install) && \
    /bin/bash
