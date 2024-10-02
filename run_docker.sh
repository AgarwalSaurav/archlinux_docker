CONTAINER_NAME=${USER}-archlinux
if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
  if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
    echo "rm disabled"
  fi
  if [ "$#" -ne 1  ]; then
    echo "bash run_docker.sh <mount_host_dir>"
    exit 1
  fi
  MOUNT_HOST_DIR=$1
  docker run -it --name=${CONTAINER_NAME} --env=USER="$USER" --env=LOCAL_USER_ID="$(id -u)" --gpus=all --net=host --privileged --ipc=host -v ${MOUNT_HOST_DIR}:/workspace:rw agarwalsaurav/archlinux:cu124 bash
else
  docker exec -it ${CONTAINER_NAME} gosu ${USER} bash
fi
