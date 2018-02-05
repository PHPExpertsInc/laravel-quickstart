#!/bin/bash

clear
printf "Welcome to the Laravel QuickStart installation!\n"
printf "    A PHP Experts, Inc., Project.\n\n"

if [ "$1" == "--help" ] || [ "$1" == "help" ];
then
    echo "Usage: "
    echo "   - Interactive mode: ./install.sh"
    echo "   - Automatic mode: ./install.sh 'APP_NAME' 'APP_URL' 'DB_USERNAME' 'DB_PASSWORD' 'DB_DATABASE' 'REDIS_PASSWORD'"
    echo ""
    exit
fi

if [ "$#" == 6 ]; then
    APP_NAME=$1
    APP_URL=$2
    DB_USERNAME=$3
    DB_PASSWORD=$4
    DB_DATABASE=$5
    REDIS_PASSWORD=$6
else
    echo -n "What is your APP_NAME [CamelCase]? "
    read APP_NAME

    echo -n "What is your APP_URL? "
    read APP_URL

    printf "What do you want your access credential to be?\n\n"

    echo -n "-> Database Username: "
    read DB_USERNAME

    echo -n "-> Database Password: "
    read DB_PASSWORD

    echo -n "-> Database Name: "
    read DB_DATABASE

    echo -n "-> Redis password: "
    read REDIS_PASSWORD

    printf "\n\n"
fi

cp .env.example .env

for setting in APP_NAME APP_URL DB_USERNAME DB_PASSWORD DB_DATABASE REDIS_PASSWORD; do
    COMMAND=$(printf $'sed -i \'s|%s=.\+|%s="%s"|\' .env' "${setting}" "${setting}" "${!setting}")
    # echo ${COMMAND}
    eval ${COMMAND}
done

# Docker setup...
if [ -e docker/lib/env.sh ]
then
    COMMAND=$(printf $'sed -i \'s|REDIS_PASSWORD=.\+|REDIS_PASSWORD="%s"|\' docker/lib/env.sh' "${REDIS_PASSWORD}")
    eval ${COMMAND}
fi

if [ -e docker/docker-compose.base.yml ]
then
    COMMAND=$(printf $'sed -i \'s|POSTGRES_USER:.\+|POSTGRES_USER: %s|\' docker/docker-compose.base.yml' "${DB_USERNAME}")
    eval ${COMMAND}

    COMMAND=$(printf $'sed -i \'s|POSTGRES_PASSWORD:.\+|POSTGRES_PASSWORD: %s|\' docker/docker-compose.base.yml' "${DB_PASSWORD}")
    eval ${COMMAND}

    COMMAND=$(printf $'sed -i \'s|POSTGRES_DB:.\+|POSTGRES_DB: %s|\' docker/docker-compose.base.yml' "${DB_DATABASE}")
    eval ${COMMAND}
fi

echo "Launching the docker containers..."
containers down
containers up -d

printf "\n\n"
echo "Making bootstrap/cache/ and storage/ writeable..."
chmod -v 0777 bootstrap/cache storage storage/*

printf "\n\n"
echo "Generating a new Laravel site key..."
php artisan key:generate

printf "\n\n"
echo "Installing composer dependencies..."
composer install

printf "\n\n"
echo "Running database migrations..."
php artisan migrate

printf "\n\n"
echo "Inserting database seeds..."
php artisan db:seed

printf "\n"
echo "All done!"
echo ""