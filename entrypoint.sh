#!/bin/env bash

useradd --shell /bin/bash -u $LOCAL_USER_ID -o -c "" -m ${USER}
usermod -aG wheel ${USER}
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

tar -xf /root/user.tar.xz -C /home/${USER}
chown -R ${USER} /opt/venv
chown -R ${USER} /home/${USER}
gosu ${USER} /bin/bash -c "git config --global init.defaultBranch main"
exec gosu ${USER} "$@"
