#!/bin/bash

ROOT_PASSWORD="root"

# kill running docker containers
docker container kill $(docker ps -q)
# prune all dead containers
echo y | docker container prune

# pull latest mysql docker image
docker pull mysql
# create and run a mysql docker container
docker run --name test-container -e MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD -d mysql

# wait until mysql service is running to proceed
while true
do
    log=$(docker exec -it test-container mysql --user=root --password=$ROOT_PASSWORD --execute="USE sys;")
    error=$(echo $log | grep ERROR)
    if [[ -z $error ]]
    then
        break
    fi
    sleep 1
done

# get the ip address of the mysql container
E_DATABASE_HOST=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" test-container)

# new versions of the mysql database (> v8) require an RSA certificate for authentication, but we will force using the old authentication by the user/password credentials
docker exec -it test-container mysql --user=root --password=$ROOT_PASSWORD --execute="CREATE DATABASE productsdb;"
docker exec -it test-container mysql --user=root --password=$ROOT_PASSWORD --execute="ALTER USER root IDENTIFIED WITH mysql_native_password BY '$ROOT_PASSWORD';"

# build and run our service
docker build -t products-service .
docker run -e DATABASE_HOST=$E_DATABASE_HOST \
           -e DATABASE_USERNAME=root \
           -e DATABASE_PASSWORD=$ROOT_PASSWORD \
           -d products-service