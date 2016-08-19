#!/usr/bin/env bash

# check wether the docker dir has been prepared or not
if [ ! -e environment ]; then
    cp -n ../examples/docker/* .
    echo "The necessary files of the examples directory have been copied. Customize the file \"environment\" to your needs and execute ${0} again."
    exit
fi

# load functions and environment variables
. functions

# give a name to the container of docker-compose (if run as Docker container)
export DOCKER_RUN_OPTIONS="--name=${PROJECT_NAME_PLAIN}_startup"
# start docker containers
docker-compose --project-name "$PROJECT_NAME_PLAIN" up

