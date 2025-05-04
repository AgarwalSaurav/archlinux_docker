# --- build arguments ---------------------------------------------------------
ARG AUR_USER=builder
ARG AUR_HELPER=paru
ARG MAKEFLAGS=-j$(nproc)

FROM archlinux:latest AS base
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]
ENV TERM=xterm-256color \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=UTF-8 \
    LANGUAGE=en_US:en
RUN sed -Ei \
        -e 's/^#\s*(en_US\.UTF-8 UTF-8)/\1/' \
        /etc/locale.gen && \
    locale-gen && \
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# --- system update & core toolchain -----------------------------------------
RUN pacman -Syu --noconfirm --needed \
      base-devel git sudo curl gnupg vim tmux less wget which man-db man-pages \
      gcc clang cmake btop bash-completion \
      python python-pip \
      boost eigen gnuplot graphviz doxygen valgrind \
      pipewire-jack openssh ffmpeg python python-pip \
      texlive-core texlive-latexextra texlive-fontsextra \
      gcc14 cuda cuda-tools openmp opencl-nvidia \
      && pacman -Scc --noconfirm

FROM base AS dev
ARG AUR_USER
ARG AUR_HELPER
ARG MAKEFLAGS
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]

COPY add-aur.sh /root/add-aur.sh
RUN chmod +x /root/add-aur.sh && \
    bash /root/add-aur.sh "${AUR_USER}" "${AUR_HELPER}" && \
    rm /root/add-aur.sh

RUN aur-install paru vim-youcompleteme-git

COPY --from=tianon/gosu /gosu /usr/local/bin/
RUN chmod +x /usr/local/bin/gosu

FROM dev AS pipenv
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]
ENV VIRTUAL_ENV=/opt/venv
# --- virtualenv --------------------------------------------------------------
COPY requirements.txt /tmp/requirements.txt
RUN python -m venv ${VIRTUAL_ENV} && \
    source ${VIRTUAL_ENV}/bin/activate && \
    ${VIRTUAL_ENV}/bin/pip install pip setuptools wheel && \
    ${VIRTUAL_ENV}/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# --- PyTorch Geometric build script -------------------------------
# COPY install_pyg.sh /tmp/install_pyg.sh
# RUN /tmp/install_pyg.sh /tmp/pyg_build ${VIRTUAL_ENV} && rm -rf /tmp/pyg_build /tmp/install_pyg.sh

FROM pipenv AS final
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]
# --- skeleton dotfiles (only once) ------------------------------------------
COPY dotfiles/.inputrc dotfiles/.bashrc dotfiles/.vimrc dotfiles/tmux.conf vim.tar.xz /etc/skel/
RUN tar -C /etc/skel -xf /etc/skel/vim.tar.xz && rm /etc/skel/vim.tar.xz

WORKDIR /workspace

# entrypoint
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
