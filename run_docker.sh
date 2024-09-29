if [ "$#" -ne 2  ]; then
  echo "bash run_docker.sh <container_name> <mount_host_dir>"
  exit 1
fi
CONTAINER_NAME=$1
MOUNT_HOST_DIR=$2
if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
  if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
    docker rm saurav-archlinux-ws
    echo "rm disabled"
  fi
    docker run -it --name=${CONTAINER_NAME}  --env=LOCAL_USER_ID="$(id -u)" --gpus=all --net=host --privileged --ipc=host -v ${MOUNT_HOST_DIR}:/workspace:rw agarwalsaurav/archlinux:cu124 bash
else
    docker exec -it ${CONTAINER_NAME} bash
fi
