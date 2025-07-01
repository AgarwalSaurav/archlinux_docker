#!/usr/bin/env bash
set -euo pipefail

# Set defaults for environment variables
USER="${USER:-developer}"
LOCAL_USER_ID="${LOCAL_USER_ID:-1000}"

if ! id -u "${USER}" &>/dev/null; then
  useradd --shell /bin/bash -u ${LOCAL_USER_ID} -o -c "" -m ${USER}
  echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  usermod -aG wheel ${USER}
  chown -R ${USER} /opt/venv
  gosu ${USER} /bin/bash -c "git config --global init.defaultBranch main"
fi

exec gosu "${USER}" "$@"
