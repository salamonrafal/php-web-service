#!/bin/bash

sudo chmod -R 777 /var/www/

if [ "$APP_ENV" == "local" ]
then
  mkdir -p var/
  mkdir -p var/cache
  mkdir -p var/log
  sudo chmod -R 777 /var/www/web-server/
  composer install

  echo "Environment: $APP_ENV"
else
  composer install --optimize-autoloader

  echo "Environment: $APP_ENV"
fi

composer dump-env $APP_ENV

sudo service php8.1-fpm start && sudo nginx -g 'daemon off;'