#!/bin/bash

declare DEFAULT_PROFILE=profiles/ubuntu
declare ENV_FILE=$(pwd)/../dockers/.env;[[ ! -z $DEFAULT_PROFILE ]]&&ENV_FILE=$(realpath "$(pwd)/../dockers/${DEFAULT_PROFILE}/.env")
declare CONFIG_DIR="$(grep BASE_DATA_DIR ${ENV_FILE}|xargs -d '\n')";CONFIG_DIR="${CONFIG_DIR#*=}/rclone"
declare CONFIG_FILE_NAME=rclone.conf; declare CONFIG_FILE="${CONFIG_DIR}/${CONFIG_FILE_NAME}"
declare EXCLUSION_FILE_NAME=exclude.txt; declare EXCLUSION_FILE="${CONFIG_DIR}/${EXCLUSION_FILE_NAME}"

declare TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
# LOG_DIR=/var/log/rclone/upload
declare LOG_DIR="$(pwd)/logs"
declare LOG_FILE="${LOG_DIR}/${TIMESTAMP}.log"
declare LOG_FILE=/dev/null
echo "ENV_FILE:$ENV_FILE CONFIG_DIR:${CONFIG_DIR}"|tee -a $LOG_FILE


declare config_param;[[ -f CONFIG_FILE ]]&&config_param="--config /config/rclone/${CONFIG_FILE_NAME}"
declare exclusion_param;[[ -f EXCLUSION_FILE ]]&&exclusion_param="--exclude-from /config/rclone/${EXCLUSION_FILE_NAME}"

rclone_launch_option="-vv -P --transfers 8 --checkers 8 --fast-list --drive-stop-on-upload-limit \
 --delete-during --use-mmap  --drive-chunk-size=128M --max-transfer 700G --min-age 0h\
 "

declare -a REMOTES_LIST=(share_01 share_02 share_03 share_04)
declare -a SYNC_LIST=(\
    "/media/data2/storage|Shared/Media"\
    # "/local|remote"\
)

mkdir -p ${LOG_DIR}


echo -e "**** params"|tee -a $LOG_FILE
echo -e "config file: $CONFIG_FILE"
echo -e "execlude file:$EXCLUSION_FILE"
echo -e "param:$config_param $exclusion_param"|tee -a $LOG_FILE
echo -e "rclone_launch_option:$rclone_launch_option"|tee -a $LOG_FILE
echo -e "syncing list:${SYNC_LIST[*]}"|tee -a $LOG_FILE
echo -e "===="|tee -a $LOG_FILE
echo -e "sync starting..."|tee -a $LOG_FILE

sync_to_remote() {
    local local_path=$1
    local remote_path=$2
    [[ -z $local_path ]]&&{
        echo -e "local_path is empty, skipping..."
        return 1
    }
    [[ -z $remote_path ]]&&{
        echo -e "remote_path is empty, skipping..."
        return 1
    }
    
    # local local_parent=$(dirname $local_path)
    # local local_name=$(basename -a $(realpath $local_path))
    # echo "local_path:$local_path local_parent:$local_parent local_name:$local_name"

    echo -e "syncing $local_path -> $remote_path"|tee -a $LOG_FILE
    local command_line="docker run --rm --volume ${CONFIG_FILE}:/config/rclone/rclong.conf \
${config_param} ${exclusion_param} --user $(id -u):$(id -g) \
--volume $local_path:/data \
rclone/rclone:beta \
move /data/ ${remote_path} ${rclone_launch_option} "

    echo "executing command: $command_line"|tee -a $LOG_FILE
    eval ${command_line}|tee -a $LOG_FILE
    # docker run --rm --volume ${CONFIG_FILE}:/config/rclone/rclong.conf \
    #     --volume ${EXCLUSION_FILE}:/config/rclone/exclude.txt \
    #     --volume $local_parent:/data \
    #     --user $(id -u):$(id -g) rclone/rclone:beta \
    #     move /data/ ${remote_path} ${rclone_launch_option} 
        
    return $?
}


current_index=0

for remote in "${REMOTES_LIST[@]}"; do
    for ((i=$current_index;$i<${#SYNC_LIST[@]};i++)); do
        
        declare item="${SYNC_LIST[i]}"
        declare items=(${item//|/ })
        declare local_path=${items[0]}
        declare remote_path="${remote}:${items[1]}"
        echo -e "index:$i local_path:[$local_path] remote_path:[$remote_path]"
        sync_to_remote $local_path $remote_path
        declare error_code=$?

        case $error_code in
            7|8)
                echo "fatal error $error_code retrying with different end point"
                continue
                ;;
            0|9)
                :
                # echo "finished"
                # exit 0
                ;;
            *)
                echo "error $error_code encountered, exiting..."
                exit $error_code
                ;;
        esac
        current_index=($i+1)
        
    done
done



