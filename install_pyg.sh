#!/usr/bin/env bash
set -euo pipefail

# PyG Component Versions (latest commits from main branches)
PYTORCH_SCATTER_COMMIT="38289bfa4dfd58961ef3cdb3c69ee70ce2bc8890"
PYTORCH_SPARSE_COMMIT="91feaa5e28a2eb4ba983a9007d046112dbc92d97"
PYTORCH_CLUSTER_COMMIT="3d1d9e3967c77c757a68d8aad37d0171e93018e2"
PYTORCH_SPLINE_CONV_COMMIT="050f58a430e41f6beda90fe9ea5a348c0b8831a7"
PYG_LIB_COMMIT="f9212296291a53f28e227f9f79df1e2df93b42f2"
PYTORCH_GEOMETRIC_COMMIT="b8c0d82d3e8a66063a9fe33ec31c8bb654c1fdc3"

# Usage: ./install_pyg.sh <workdir> <venv_path>
# Example: ./install_pyg.sh /tmp/build /opt/venv

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <workdir> <venv_path>"
  exit 1
fi

WORKDIR="$1"
VENV="$2"

# Ensure WORKDIR exists
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Ensure the virtualenv exists
if [ ! -x "${VENV}/bin/pip" ]; then
  echo "Error: virtual environment not found at ${VENV}"
  exit 1
fi

# Helper to run pip inside the venv
PIP="${VENV}/bin/pip"

# Upgrade pip, setuptools, wheel
"${PIP}" install pip setuptools wheel

# List of repositories with their commit hashes (in installation order)
declare -A REPOS_COMMITS=(
  ["pytorch_scatter"]="$PYTORCH_SCATTER_COMMIT"
  ["pytorch_sparse"]="$PYTORCH_SPARSE_COMMIT"
  ["pytorch_cluster"]="$PYTORCH_CLUSTER_COMMIT"
  ["pytorch_spline_conv"]="$PYTORCH_SPLINE_CONV_COMMIT"
  ["pyg_lib"]="$PYG_LIB_COMMIT"
  ["pytorch_geometric"]="$PYTORCH_GEOMETRIC_COMMIT"
)

REPOS=(
  "https://github.com/rusty1s/pytorch_scatter.git"
  "https://github.com/rusty1s/pytorch_sparse.git"
  "https://github.com/rusty1s/pytorch_cluster.git"
  "https://github.com/rusty1s/pytorch_spline_conv.git"
  "https://github.com/pyg-team/pyg-lib.git"
  "https://github.com/pyg-team/pytorch_geometric.git"
)

for repo in "${REPOS[@]}"; do
  name=$(basename "${repo}" .git)
  echo "------------------------------------------------------------"
  echo "Cloning ${name}..."
  git clone "${repo}"
  cd "${name}"

  # Convert pyg-lib to pyg_lib for associative array key lookup
  commit_key="${name//-/_}"
  if [[ -n "${REPOS_COMMITS[$commit_key]:-}" ]]; then
    echo "Checking out commit ${REPOS_COMMITS[$commit_key]}..."
    git checkout "${REPOS_COMMITS[$commit_key]}"
  fi

  echo "Initializing/updating submodules..."
  git submodule update --init --recursive

  if [ "${name}" == "pyg-lib" ]; then
    "${PIP}" install --no-cache-dir --no-build-isolation .
  else
    "${PIP}" install --no-cache-dir .
  fi

  # Return to workdir for next repo
  cd "${WORKDIR}"
done

echo "All PyG dependencies installed successfully."

