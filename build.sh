# ./build.sh --host=test.localhost --mailhog=test --magento-verion=2.3.1

MAGENTO_VERSION=2.3.1

for ARGUMENT in "$@"
do
  KEY=$(echo $ARGUMENT | cut -f1 -d=)
  VALUE=$(echo $ARGUMENT | cut -f2 -d=)

  case "$KEY" in
    --host) HOST=${VALUE} ;;
    --mailhog-host) MAILHOG_HOST=${VALUE} ;;
    --magento-version) MAGENTO_VERSION=${VALUE} ;;
    *) # param not used
  esac
done

sed -i -e "s/HOST_NAME/$HOST/g" ./.env

if [ ${MAILHOG_HOST+x} ]
then
  sed -i -e "s/MAILHOG_CONTAINER/$MAILHOG_HOST/g" ./docker-compose.yml
fi

docker-compose up -d --build

rm ./src/project/.gitkeep

docker-compose exec php composer create-project --repository=https://repo.magento.com/ magento/project-community-edition:$MAGENTO_VERSION .
