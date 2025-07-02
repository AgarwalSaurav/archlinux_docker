ARG AUR_USER=builder
ARG AUR_HELPER=paru
ARG MAKEFLAGS=-j$(nproc)
FROM archlinux:latest AS base
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]
ENV TERM=xterm-256color \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=UTF-8 \
    LANGUAGE=en_US:en \
    CC=/usr/bin/gcc-13 \
    CXX=/usr/bin/g++-13 \
    NVCC_CCBIN=/usr/bin/gcc-13 \
    CUDACXX=/opt/cuda/bin/nvcc \
    CUDA_HOME=/opt/cuda \
    CUDA_PATH=/opt/cuda \
    VISUAL=vim \
    EDITOR=vim \
    VIRTUAL_ENV=/opt/venv

RUN sed -Ei \
        -e 's/^#\s*(en_US\.UTF-8 UTF-8)/\1/' \
        /etc/locale.gen && \
    locale-gen && \
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# --- system update & core toolchain -----------------------------------------
RUN pacman -Syu --noconfirm --needed \
      base-devel git sudo curl gnupg vim tmux less wget which man-db man-pages \
      unzip clang cmake btop bash-completion tree \
      python python-pip \
      boost eigen gnuplot graphviz doxygen valgrind \
      pipewire-jack openssh ffmpeg python python-pip \
      texlive-core texlive-latexextra texlive-fontsextra \
      openmp opencl-nvidia

FROM base AS dev
ARG AUR_USER
ARG AUR_HELPER
ARG MAKEFLAGS
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]

COPY add-aur.sh /root/tmp/
RUN AUR_SCRIPT=/root/tmp/add-aur.sh; chmod +x ${AUR_SCRIPT} && \
    bash ${AUR_SCRIPT} "${AUR_USER}" "${AUR_HELPER}" && \
    rm ${AUR_SCRIPT}

RUN aur-install paru vim-youcompleteme-git gcc13

COPY --chmod=+x --from=tianon/gosu /gosu /usr/local/bin/

FROM dev AS cudabuilder
RUN useradd -m cudabuilder && echo "cudabuilder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER cudabuilder
WORKDIR /home/cudabuilder
RUN git clone --depth 1 --branch 12.6.3-2 https://gitlab.archlinux.org/saurav/cuda.git

WORKDIR /home/cudabuilder/cuda
RUN makepkg -s --noconfirm && \
    mkdir -p /home/cudabuilder/build && \
    cp *.pkg.tar.zst /home/cudabuilder/build

FROM dev AS cuda
COPY --from=cudabuilder /home/cudabuilder/build/*.pkg.tar.zst /tmp/
RUN pacman -U --noconfirm /tmp/*.pkg.tar.zst && rm /tmp/*.pkg.tar.zst && pacman -Scc --noconfirm

FROM cuda AS pipenv
COPY requirements.txt install_pyg.sh /root/tmp/
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]
# --- virtualenv --------------------------------------------------------------
RUN python -m venv ${VIRTUAL_ENV} && \
    source ${VIRTUAL_ENV}/bin/activate && \
    ${VIRTUAL_ENV}/bin/pip install pip setuptools wheel && \
    ${VIRTUAL_ENV}/bin/pip install --no-cache-dir -r /root/tmp/requirements.txt && \
    rm /root/tmp/requirements.txt
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}" \
    Torch_DIR="/opt/libtorch/share/cmake/"

RUN mkdir download; \
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 3 \
         https://download.pytorch.org/libtorch/cu126/libtorch-cxx11-abi-shared-with-deps-2.7.1%2Bcu126.zip \
         -O download/libtorch.zip; \
    unzip download/libtorch.zip -d /opt/; \
    rm -r download

# --- PyTorch Geometric build script -------------------------------
RUN /root/tmp/install_pyg.sh /root/tmp/pyg_build ${VIRTUAL_ENV} && rm -rf /root/tmp/pyg_build /root/tmp/install_pyg.sh

FROM cuda AS final
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]

COPY --from=pipenv /opt/venv /opt/venv
COPY --from=pipenv /opt/libtorch /opt/libtorch
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}" \
    Torch_DIR="/opt/libtorch/share/cmake/"

# --- skeleton dotfiles (only once) ------------------------------------------
COPY dotfiles/.inputrc dotfiles/.bashrc dotfiles/.vimrc dotfiles/tmux.conf vim.tar.xz /etc/skel/
RUN tar -C /etc/skel -xf /etc/skel/vim.tar.xz && rm -r /root/tmp/ && rm /etc/skel/vim.tar.xz

WORKDIR /workspace

# entrypoint
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
