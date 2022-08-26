ARG TIME_ZONE=Europe/Warsaw

FROM ubuntu:22.10 as base_build
ENV TZ="$TIME_ZONE"
LABEL pl.salamonrafal.version="0.0.3" pl.salamonrafal.author="Rafal\ Salamon\ <rasa@salamonrafal.pl>"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -yqq update && apt-get --no-install-recommends -yqq install nginx curl \
    php8.1 php8.1-cli php8.1-fpm \
    php8.1-pdo php8.1-mysql php8.1-mongodb php8.1-pgsql \
    php8.1-curl php8.1-zip php8.1-curl php8.1-xml php8.1-bcmath php8.1-xmlrpc php8.1-gd php8.1-mbstring\
    mc nano wget sudo\
    && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2.4 /usr/bin/composer /usr/bin/composer

FROM base_build as setup_service
COPY ./docker/nginx/welcome-html /var/www/welcome/
COPY . /var/www/web-server
COPY ./docker/php-fpm/www.conf /etc/php/7.4/fpm/pool.d/
COPY ./docker/nginx/sites-available /etc/nginx/sites-available/
COPY ./docker/nginx/sites-available /etc/nginx/sites-enabled/
COPY ./docker/nginx/snippets /etc/nginx/snippets/
COPY ./docker/entrypoint.sh /etc/entrypoint.sh

FROM setup_service as setup_sudo_access

RUN sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Customized the sudoers file for passwordless access to the foo user!";

FROM setup_sudo_access as service_build
ARG APP_ENV=prod
ENV APP_ENV=$APP_ENV
ARG APP_SECRET=secret
ENV APP_SECRET=$APP_SECRET

RUN chmod -R 777 /var/www/web-server/
RUN chmod -R 777 /var/www/welcome/
RUN chown -R www-data:www-data /var/www/web-server/
RUN chown -R www-data:www-data /var/www/welcome/

USER www-data
WORKDIR /var/www/web-server/

EXPOSE 80 8080
ENTRYPOINT /etc/entrypoint.sh