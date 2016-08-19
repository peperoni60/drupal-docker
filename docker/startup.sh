#!/usr/bin/env bash

# load functions and environment variables
. functions

# give a name to the container of docker-compose (if run as Docker container)
export DOCKER_RUN_OPTIONS="--name=${PROJECT_NAME_PLAIN}_startup"
# start docker containers
docker-compose --project-name "$PROJECT_NAME_PLAIN" up

