##############################
# Stage 1: Builder Stage
# ---------------------------
# This stage prepares the environment for building the CUDA package. Because
# makepkg must run as a non-root user, we create a dedicated user ("builder")
# and switch to it. We install the minimal build dependencies (like base-devel,
# git, sudo) and then clone and build the package. Finally, we copy the built
# package (*.pkg.tar.zst) to a dedicated folder for later use.
##############################
FROM archlinux:latest AS builder

# Update system and install minimal packages for building
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git sudo

# Create a non-root user "builder" and grant passwordless sudo privileges.
RUN useradd -m builder && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to builder user
USER builder
WORKDIR /home/builder

# Clone the CUDA repo (using a shallow clone) and build the package.
RUN git clone --depth 1 --branch 12.6.3-2 https://gitlab.archlinux.org/saurav/cuda.git

WORKDIR /home/builder/cuda
# Build the package; note we use "makepkg -s" so it builds dependencies without trying to install,
# since installation as the non-root user would fail.
RUN makepkg -s --noconfirm && \
    # Prepare a folder to store the built package artifact(s)
    mkdir -p /home/builder/build && \
    cp *.pkg.tar.zst /home/builder/build

##############################
# Stage 2: Final Stage
# ---------------------------
# This is your final runtime image. All the standard tools, environment variables,
# AUR helper setups, and additional configuration files are installed here.
# We copy the built CUDA package from the builder stage and install it.
##############################
FROM archlinux:latest

# Set up environment variables common to your image
ENV TERM=xterm-256color
ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LANG=en_US.UTF-8

# Build arguments for AUR helper setup (can be customized at build time)
ARG AUR_USER=user
ARG HELPER=paru

# Update system and install the required packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
        base-devel \
        cmake \
        man man-db man-pages \
        sudo \
        pipewire-jack \
        git \
        graphviz \
        doxygen \
        python python-pip \
        eigen \
        texlive-core \
        texlive-latexextra \
        texlive-fontsextra \
        vim \
        tmux \
        clang \
        openmp \
        less \
        valgrind \
        boost \
        wget \
        gnuplot \
        openssh \
        ffmpeg \
        opencl-nvidia \
        gcc13 \
        which \
        gnupg

# Copy CUDA package built in the builder stage into a temporary directory
COPY --from=builder /home/builder/build/*.pkg.tar.zst /tmp/
# Install the CUDA package and then clean up the temporary package files
RUN pacman -U --noconfirm /tmp/*.pkg.tar.zst && rm /tmp/*.pkg.tar.zst && pacman -Scc --noconfirm

# Set up AUR helper and user via an external script
COPY add-aur.sh /root/add-aur.sh
RUN chmod +x /root/add-aur.sh && \
    bash /root/add-aur.sh "${AUR_USER}" "${HELPER}" && \
    rm /root/add-aur.sh

# Install AUR packages using the helper (e.g., paru)
RUN aur-install paru vim-youcompleteme-git

# Set up a Python virtual environment and install dependencies
COPY requirements.txt /tmp/requirements.txt
COPY requirements1.txt /tmp/requirements1.txt
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
    /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements1.txt && \
    rm /tmp/requirements*.txt

# Add the venv's binaries to the PATH for subsequent commands
ENV PATH="/opt/venv/bin:$PATH"

# Copy gosu (for privilege dropping) from a separate image
COPY --from=tianon/gosu /gosu /usr/local/bin/
RUN chmod +x /usr/local/bin/gosu

# Copy configuration files and application code
COPY dotfiles/.inputrc /root/.
COPY dotfiles/.bashrc /root/.
COPY dotfiles/.vimrc /root/.
COPY vim.tar.xz /root/vim.tar.xz

# Extract vim and perform cleanup in one layer
RUN tar -xf /root/vim.tar.xz -C /root

# Set up workspace
RUN mkdir /workspace
WORKDIR /workspace

# Copy the entrypoint script and ensure it is executable (using BuildKit's --chmod option)
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Specify the entrypoint (add CMD if you desire a default command)
ENTRYPOINT ["/entrypoint.sh"]

