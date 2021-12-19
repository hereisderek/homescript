#!/bin/bash

# Exit if running
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then
echo "Already running, exiting..."; exit 1; fi


export RCLONE_CONFIG_DIR=/media/data1/home_service/data/rclone
DOCKER_CONFIG_DIR=/config/rclone

EXCLUDE_FILE_NAME=exclude.txt
CONFIG_FILE_NAME=rclone.conf
LOCAL=/media/data2/storage

SYNC_LIST=" /
    /media/data/storage:Shared/Media

"


# REMOTES="share_04 share_03 share_02 share_01"
REMOTES="share_01 share_04 share_03 share_02"
REMOTE_MEDIA_PATH_RELATTIVE="/Shared/Media"


# is $LOCAL exist
[[ ! -d $LOCAL ]] && {
    echo "unable to find local folder:${LOCAL}, exiting..."; exit 1;
}

# Is $LOCAL actually a local disk?
if /bin/findmnt $LOCAL -o FSTYPE -n | grep fuse; then
echo "FUSE file system found, exiting..."; exit 1; fi




# Check for excludes file
if [[ ! -f ${RCLONE_CONFIG_DIR}/${EXCLUDE_FILE_NAME} ]]; then
echo "excludes file not found, aborting..."; exit 1; fi

docker_exclude="--exclude-from ${DOCKER_CONFIG_DIR}/${EXCLUDE_FILE_NAME}"


for remote in ${REMOTES}; do
    remote_location="${remote}:${REMOTE_MEDIA_PATH_RELATTIVE}"
    echo "using remote: $remote, ${LOCAL} -> ${remote_location}"

    docker_name="rclone_sync_${remote}"
    docker rm $docker_name
    # copy /data/ ${remote_location}  \
    # move /data/ ${remote_location}  --delete-empty-src-dirs
    docker run --name ${docker_name} --rm -ti \
        --volume ${RCLONE_CONFIG_DIR}:${DOCKER_CONFIG_DIR} \
        --volume ${LOCAL}:/data \
        --user $(id -u):$(id -g) \
        rclone/rclone:beta \
     	move /data/ ${remote_location}  --delete-empty-src-dirs \
        -v -P ${docker_exclude}  --transfers 8 --checkers 8 \
        --fast-list --drive-stop-on-upload-limit --delete-during \
	--min-age 0h  --drive-chunk-size=128M --max-transfer 700G 


    error_code=$?

    # try different remote if hit upload limit
    case $error_code in
        7|8)
            echo "fatal error $error_code retrying with different end point"
            continue
            ;;
        0|9)
            echo "finished"
            exit 0
            ;;
        *)
            echo "error $error_code encountered, exiting..."
            exit $error_code
            ;;
    esac
done


# Move older local files to the cloud...
# I added in 3 days to let the files sit a few days so Plex intro anaylsis can happen locally
# /usr/bin/rclone move $LOCAL gcrypt: --log-file /opt/rclone/logs/upload.log -v --exclude-from /opt/rclone/scripts/excludes --delete-empty-src-dirs --fast-list --drive-stop-on-upload-limit --min-age 3d



