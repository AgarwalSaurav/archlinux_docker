# --- build arguments ---------------------------------------------------------
ARG AUR_USER=builder
ARG AUR_HELPER=paru
ARG MAKEFLAGS=-j$(nproc)

FROM archlinux:latest AS base
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]
ENV TERM=xterm-256color \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=UTF-8 \
    LANGUAGE=en_US:en \
    CC=/usr/bin/gcc-14 \
    CXX=/usr/bin/g++-14 \
    NVCC_CCBIN=/usr/bin/gcc-14 \
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
      unzip gcc14 clang cmake btop bash-completion \
      python python-pip \
      boost eigen gnuplot graphviz doxygen valgrind \
      pipewire-jack openssh ffmpeg python python-pip \
      texlive-core texlive-latexextra texlive-fontsextra \
      openmp opencl-nvidia \
      && wget https://archive.archlinux.org/packages/c/cuda/cuda-12.8.1-3-x86_64.pkg.tar.zst \
      && pacman -U --noconfirm cuda-12.8.1-3-x86_64.pkg.tar.zst \
      && rm cuda-12.8.1-3-x86_64.pkg.tar.zst \
      && pacman -Scc --noconfirm

COPY add-aur.sh requirements.txt install_pyg.sh /root/tmp/

FROM base AS dev
ARG AUR_USER
ARG AUR_HELPER
ARG MAKEFLAGS
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]

RUN AUR_SCRIPT=/root/tmp/add-aur.sh; chmod +x ${AUR_SCRIPT} && \
    bash ${AUR_SCRIPT} "${AUR_USER}" "${AUR_HELPER}" && \
    rm ${AUR_SCRIPT}

RUN aur-install paru vim-youcompleteme-git

COPY --chmod=+x --from=tianon/gosu /gosu /usr/local/bin/

FROM base AS pipenv
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
         https://download.pytorch.org/libtorch/cu128/libtorch-cxx11-abi-shared-with-deps-2.7.1%2Bcu128.zip \
         -O download/libtorch.zip; \
    unzip download/libtorch.zip -d /opt/; \
    rm -r download

# --- PyTorch Geometric build script -------------------------------
RUN /root/tmp/install_pyg.sh /root/tmp/pyg_build ${VIRTUAL_ENV} && rm -rf /root/tmp/pyg_build /root/tmp/install_pyg.sh

FROM dev AS final
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
