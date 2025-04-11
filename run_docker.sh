#!/bin/bash

# Exit immediately if a command exits with a non-zero status,
# treat unset variables as errors, and ensure pipelines fail correctly.
set -euo pipefail

# ----------------------------
# Color Definitions
# ----------------------------
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
YELLOW='\033[0;33m' # Yellow
NC='\033[0m'        # No Color

# ----------------------------
# Function Definitions
# ----------------------------

# Function to display usage information
print_usage() {
  echo "Usage: bash $(basename "$0") <mount_host_dir>"
  exit 1
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to handle errors with colored output
error_exit() {
  echo -e "${RED}Error: $1${NC}" >&2
  exit 1
}

# Function to display informational messages
info_message() {
  echo -e "${GREEN}$1${NC}"
}

# Function to display warnings
warning_message() {
  echo -e "${YELLOW}Warning: $1${NC}"
}

CONTAINER_NAME="${USER}-archlinux"
IMAGE_NAME="agarwalsaurav/archlinux:cu126"

if ! docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
  if docker ps -aq -f status=exited -f name="${CONTAINER_NAME}" | grep -q .; then
    warning_message "Container '${CONTAINER_NAME}' exists but is exited."
    read -p "Do you want to start the exited container? [y/N]: " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      docker start "${CONTAINER_NAME}" || error_exit "Failed to start container."
      docker exec -it "${CONTAINER_NAME}" gosu "${USER}" bash
      exit 0
    fi
    read -p "Do you want to remove the exited container? [y/N]: " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      docker rm "${CONTAINER_NAME}" || error_exit "Failed to remove container."
    fi
  fi

  if [[ $# -ne 1 ]]; then
    print_usage
  fi

  MOUNT_HOST_DIR="$1"

  if [[ ! -d "$MOUNT_HOST_DIR" ]]; then
    error_exit "Mount directory '$MOUNT_HOST_DIR' does not exist."
  fi

  info_message "Starting a new container '${CONTAINER_NAME}'."
  docker run -it \
    --name="${CONTAINER_NAME}" \
    --env=USER="$USER" \
    --env=LOCAL_USER_ID="$(id -u)" \
    --gpus=all \
    --net=host \
    --privileged \
    --ipc=host \
    -v "${MOUNT_HOST_DIR}:/workspace:rw" \
    "${IMAGE_NAME}" \
    bash
else
  info_message "Attaching to running container '${CONTAINER_NAME}'."
  docker exec -it "${CONTAINER_NAME}" gosu "${USER}" bash
fi
