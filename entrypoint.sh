#!/usr/bin/env bash
set -euo pipefail

# ─────────── parameters ───────────
: "${LOCAL_USER_ID:=1000}"
: "${LOCAL_USER_NAME:=user}"
: "${LOCAL_GROUP_ID:=1000}"

# ─────────── idempotent user creation ───────────
if ! id -u "${LOCAL_USER_NAME}" &>/dev/null; then
    groupadd -g "${LOCAL_GROUP_ID}" "${LOCAL_USER_NAME}"
    useradd  -m -u "${LOCAL_USER_ID}" -g "${LOCAL_GROUP_ID}" -s /bin/bash "${LOCAL_USER_NAME}"
fi

# ─────────── sudo (wheel) ───────────
if ! grep -q '^%wheel' /etc/sudoers; then
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/10-wheel
fi
usermod -aG wheel "${LOCAL_USER_NAME}"

# ─────────── one-time git default branch ───────────
sudo -u "${LOCAL_USER_NAME}" git config --global init.defaultBranch main

# ─────────── exec ───────────
exec gosu "${LOCAL_USER_NAME}" "$@"

