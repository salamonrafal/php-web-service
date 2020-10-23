FROM ubuntu:20.10
ENV TZ=Europe/Warsaw
LABEL pl.salamonrafal.version="0.0.1" pl.salamonrafal.author="Rafal\ Salamon\ <rasa@salamonrafal.pl>"

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
    && rm -rf /var/lib/apt/lists/*
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'c31c1e292ad7be5f49291169c0ac8f683499edddcfd4e42232982d0fd193004208a58ff6f353fde0012d35fdd72bc394') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer



COPY ./nginx/welcome-html/*.* /var/www/welcome/
COPY ../src/*.* /var/www/web-server/src/
COPY ./php-fpm/www.conf /etc/php/7.4/fpm/pool.d/
COPY ./nginx/sites-available/*.* /etc/nginx/sites-enabled/

EXPOSE 80

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]