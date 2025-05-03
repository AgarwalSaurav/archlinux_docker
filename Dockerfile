FROM archlinux:latest AS base
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]

# --- build arguments ---------------------------------------------------------
ARG AUR_USER=builder
ARG AUR_HELPER=paru
ARG MAKEFLAGS=-j$(nproc)

ENV TERM=xterm-256color \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=UTF-8 \
    MAKEFLAGS="${MAKEFLAGS}"

# --- system update & core toolchain -----------------------------------------
RUN pacman -Syu --noconfirm --needed \
      base-devel git sudo curl gnupg vim tmux less wget which man-db man-pages \
      gcc clang cmake \
      python python-pip \
      boost eigen gnuplot graphviz doxygen valgrind \
      pipewire-jack openssh ffmpeg python python-pip\
      texlive-core texlive-latexextra texlive-fontsextra \
      cuda cuda-tools openmp opencl-nvidia\
      && pacman -Scc --noconfirm

# --- non-root build user (used for AUR compilation) --------------------------
RUN useradd -m -s /bin/bash ${AUR_USER} && \
    echo "${AUR_USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/99_${AUR_USER}

USER ${AUR_USER}
WORKDIR /home/${AUR_USER}

# --- AUR helper --------------------------------------------------------------
RUN git clone --depth=1 https://aur.archlinux.org/${AUR_HELPER}.git && \
    cd ${AUR_HELPER} && \
    makepkg -si --noconfirm && \
    cd .. && rm -rf ${AUR_HELPER}

# ───────────────────────────────────────── DEV ──────────────────────────────────────────
FROM base AS dev
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]
USER ${AUR_USER}

# --- AUR packages (edit list as needed) --------------------------------------
RUN ${AUR_HELPER} -S --noconfirm --needed \
       gcc13 vim-youcompleteme-git gosu && \
    ${AUR_HELPER} -Sc --noconfirm

# --- virtualenv --------------------------------------------------------------
COPY --chown=${AUR_USER}:${AUR_USER} requirements.txt /tmp/requirements.txt
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt
ENV PATH="/opt/venv/bin:${PATH}"

# --- PyTorch Geometric build script (optional) -------------------------------
COPY --chown=${AUR_USER}:${AUR_USER} install_pyg.sh /tmp/install_pyg.sh
RUN /tmp/install_pyg.sh /tmp/pyg_build /opt/venv && rm -rf /tmp/pyg_build /tmp/install_pyg.sh

# --- skeleton dotfiles (only once) ------------------------------------------
COPY dotfiles/.inputrc dotfiles/.bashrc dotfiles/.vimrc /etc/skel/
COPY vim.tar.xz /etc/skel/vim.tar.xz
RUN tar -C /etc/skel -xf /etc/skel/vim.tar.xz && rm /etc/skel/vim.tar.xz

# ──────────────────────────────────────── FINAL ─────────────────────────────────────────
FROM dev AS final
SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]

USER root
WORKDIR /workspace
RUN mkdir -p /workspace

# entrypoint
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["/bin/bash"]
