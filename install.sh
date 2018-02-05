#!/bin/bash
################################################################
#   The Laravel QuickStart Project                             #
#   https://github.com/phpexpertsinc/laravel_quickstart        #
#   License: MIT                                               #
#                                                              #
#   Copyright © 2018 PHP Experts, Inc. <sales@phpexperts.pro>  #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>    #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690       #
################################################################

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

printf "${GREEN}"
echo "################################################################"
echo '#   The Laravel QuickStart Project                             #'
echo '#   https://github.com/phpexpertsinc/laravel_quickstart        #'
echo '#   License: MIT                                               #'
echo '#                                                              #'
echo '#   Copyright © 2018 PHP Experts, Inc. <sales@phpexperts.pro>  #'
echo '#       Author: Theodore R. Smith <theodore@phpexperts.pro>    #'
echo '#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690       #'
echo '################################################################'
printf "${NC}\n"


if [ "$1" == "--help" ] || [ "$1" == "help" ];
then
    echo "Usage: "
    echo "   - Interactive mode: ./install.sh"
    echo "   - Automatic mode: ./install.sh 'APP_NAME' 'APP_URL' 'DB_USERNAME' 'DB_PASSWORD' 'DB_DATABASE' 'REDIS_PASSWORD'"
    echo ""
    exit
fi

path_check() {

    # Ensure that the ./bin is in the path.
    RAND_BIN=rand448844.sh
    touch ./bin/${RAND_BIN}
    chmod 0755 ./bin/${RAND_BIN}

    if ! [ -x "$(command -v ${RAND_BIN})" ]; then
        echo "Error: You must add ${PWD}/bin to your PATH..."
        echo ""
        echo "       We recommend running the following commands:"
        echo ""
        echo "           echo 'export PATH=${PWD}/bin:\$PATH' >> ~/.bashrc"
        echo "           source ~/.bashrc"
        echo "           hash -r"
        echo ""
        echo "       Then re-run this installation utility."
        echo ""

        exit
    fi

    rm -f ./bin/${RAND_BIN}
}

path_check

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
