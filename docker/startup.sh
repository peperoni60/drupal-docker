#!/usr/bin/env bash

# create the environment file for Docker
env -i environment | sort > .environment.env

# load the environment variables
. environment > /dev/null

# start docker containers
export COMPOSE_OPTIONS="--env-file=.environment.env"
docker-compose --project-name "$PROJECT_NAME" up

# cleanup
rm .environment.env 2> /dev/null
