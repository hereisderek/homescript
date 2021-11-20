#!/usr/bin/bash
export PROFILE_LOCATION=profiles/ubuntu
ENV_FILE=${PROFILE_LOCATION}/.env
DOCKER_COMPOSE_OVERRIDE_FILE=${PROFILE_LOCATION}/docker-compose.override.yml

_env_=; [[ -f $ENV_FILE ]]&&_env_="--env-file ${ENV_FILE}"
_docker_compose_override_=; [[ -f $DOCKER_COMPOSE_OVERRIDE_FILE ]]&&_docker_compose_override_="-f docker-compose.yml -f ${DOCKER_COMPOSE_OVERRIDE_FILE}"

echo "_env_:${_env_} "
echo "_docker_compose_override_:${_docker_compose_override_}"

alias dockers="docker-compose ${_docker_compose_override_} ${_env_}"



return 0