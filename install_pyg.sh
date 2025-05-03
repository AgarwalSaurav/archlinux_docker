#!/usr/bin/env bash
set -euo pipefail

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
if [ ! -x "${VENV}/bin/activate" ]; then
  echo "Error: virtual environment not found at ${VENV}"
  exit 1
fi

# Helper to run pip inside the venv
PIP="${VENV}/bin/pip"

# Upgrade pip, setuptools, wheel
"${PIP}" install --upgrade pip setuptools wheel

# List of repositories (in installation order)
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

  echo "Initializing/updating submodules..."
  git submodule update --init --recursive

  echo "Installing ${name} via pip..."
  "${PIP}" install --no-cache-dir .

  # Return to workdir for next repo
  cd "${WORKDIR}"
done

echo "All PyG dependencies installed successfully."

