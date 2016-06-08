#!/usr/bin/env bash

# create the environment file for Docker
env -i environment | sort > .environment.env

# rebuild docker containers
export COMPOSE_OPTIONS="--env-file=.environment.env"
docker-compose build

# cleanup
rm .environment.env