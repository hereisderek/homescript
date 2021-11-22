#!/usr/bin/bash
cd "$(dirname "$0")"

dockers() {
    DEFAULT_PROFILE=profiles/ubuntu
    PROFILE_LOCATION=${PROFILE_LOCATION:-${DEFAULT_PROFILE}}
    
    PROFILE_ENV_FILE=${PROFILE_LOCATION}/.env
    DOCKER_COMPOSE_OVERRIDE_FILE=${PROFILE_LOCATION}/docker-compose.override.yml

    compose_override_params=;[ -f $DOCKER_COMPOSE_OVERRIDE_FILE ]&&compose_override_params=" -f docker-compose.yml -f ${DOCKER_COMPOSE_OVERRIDE_FILE}"

    merge_env_files() {
        # echo "merging ${@:2} into ${1}..."
        local env_override_file=${1}
        mkdir -p $(dirname ${1})
        # awk -F= '{a[$1]=$2}END{for(i in a) print i "=" a[i]}' "${@:2}">${1}
        sort -u -t '=' -k 1,1 $(echo "${@:2}"|tr ' ' '\n'|tac|tr '\n' ' ')>${1}
    }

    env_params=
    if [ -f .env ] && [ -f $PROFILE_ENV_FILE ]; then
        echo "both .env and $PROFILE_ENV_FILE exist, merging together..."
        env_override_file=${PROFILE_LOCATION}/env.import
        merge_env_files $env_override_file .env $PROFILE_ENV_FILE
        eval docker-compose ${compose_override_params} --env-file $env_override_file $@
    elif [ -f $PROFILE_ENV_FILE ]; then
        echo "use $PROFILE_ENV_FILE"
        eval docker-compose "$compose_override_params --env-file $PROFILE_ENV_FILE $@"
    else 
        echo ".env not speicified"
        eval docker-compose $@
    fi
}