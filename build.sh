#!/usr/bin/env bash

## COLORS ##
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

## CONFIGS ##
DEFAULT_MAGENTO_VERSION=2.3.2
FOLDER_NAME=${PWD##*/}
HOST=${FOLDER_NAME}.localhost
MAGENTO_VERSION=${DEFAULT_MAGENTO_VERSION}
MAILHOG_HOST=${FOLDER_NAME}
RM_GIT=true
NO_HOST=false
MAGENTO_EDITION_LABEL=community
HOST_FILE=/etc/hosts

show_help() {
echo "
This script will configure, completely, a docker-compose project and
generate a new Magento 2 project with a specified version.

These are the commands that this script will execute:

1) Add the provided HOST to ${HOST_FILE}
2) Update ./.env file with the provided HOST
3) Start the containers (And download if it is the first time executing this script)
4) Execute \"composer create-project\" to download the Magento 2 project into the ./src/project folder

Usage: ./build.sh [options]

Options:
    --host                              Set your host to use on NGINX config
                                        (Default: ${FOLDER_NAME}.localhost)

    -v, --version, --magento-version    Magento 2 version (Default: ${DEFAULT_MAGENTO_VERSION})

    -e, --enterprise                    Use Magento 2 Commerce (Enterprise Edition)

    --keep-git                          Keep .git and .gitignore of this repository
                                        (Default: Will remove these resources)

    --no-host                           Skip updating the ${HOST_FILE} with the specified
                                        host

    -h, --help                          Show this message
";
}

for ARGUMENT in "$@"
do
  KEY=$(echo $ARGUMENT | cut -f1 -d=)
  VALUE=$(echo $ARGUMENT | cut -f2 -d=)

  case "$KEY" in
    --host) HOST=${VALUE} ;;
    -v) MAGENTO_VERSION=${VALUE} ;;
    --version) MAGENTO_VERSION=${VALUE} ;;
    --magento-version) MAGENTO_VERSION=${VALUE} ;;
    -e) MAGENTO_EDITION_LABEL=enterprise ;;
    --enterprise) MAGENTO_EDITION_LABEL=enterprise ;;
    --keep-git) RM_GIT=false;;
    --no-host) NO_HOST=true;;
    -h) show_help; exit ;;
    --help) show_help; exit ;;
    *) # param not used
  esac
done

echo -e " - HOST: ${YELLOW}${HOST}${NONE}"
echo -e " - MAGENTO VERSION: ${YELLOW}${MAGENTO_VERSION}${NONE}"
echo -e " - EDITION: ${YELLOW}${MAGENTO_EDITION_LABEL^^}${NONE}"

#### ADD $HOST TO $HOST_FILE ####
if [[ ${NO_HOST+x} && $(sudo grep -c $HOST $HOST_FILE) -eq 0 ]]
then
    sudo bash -c "echo \"127.0.0.1       ${HOST}\" >> ${HOST_FILE}"
    echo -e " - \"${YELLOW}${HOST}${NONE}\" ADDED INTO \"${YELLOW}${HOST_FILE}${NONE}\" FILE"
fi
#################################

########## CLEARING FOLDER ##########
[[ $RM_GIT = true ]] && rm ./.git;
rm -rf ./src/project/*
[[ $RM_GIT = false ]] && git checkout src/project/.gitkeep
#####################################

#### UPDATING .env ####
sed -i -e "s/HOST_NAME/$HOST/g" ./.env
#######################

#### UPDATING docker-compose.yml WITH CORRECT MAILHOG NAME ####
if [ ${MAILHOG_HOST+x} ]
then
  sed -i -e "s/MAILHOG_CONTAINER/$MAILHOG_HOST/g" ./docker-compose.yml
fi
###############################################################

docker-compose up -d --build

docker-compose exec php composer create-project --repository=https://repo.magento.com/ magento/project-${MAGENTO_EDITION_LABEL}-edition:$MAGENTO_VERSION .
