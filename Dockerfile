FROM archlinux:latest
ENV TERM=xterm-256color
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel cmake
RUN pacman -S --noconfirm git graphviz doxygen python python-pip
RUN pacman -S --noconfirm texlive-core texlive-latexextra texlive-fontsextra
RUN pacman -S --noconfirm vim tmux clang valgrind boost
RUN pacman -S --noconfirm cuda cuda-tools
RUN python -m venv /opt/venv
COPY requirements.txt /tmp/requirements.txt
RUN /opt/venv/bin/pip install -r /tmp/requirements.txt
# RUN rm -rf /var/cache/pacman/pkg/*
# RUN rm -rf /var/lib/pacman/sync/*
# RUN rm -rf /etc/pacman.d/gnupg
COPY dotfiles/.bashrc /root/.
COPY dotfiles/.vimrc /root/.
RUN mkdir -p /root/.vim/undodir
RUN mkdir -p /root/.vim/backup
ENV VENV_PATH=/opt/venv
RUN echo "source /opt/venv/bin/activate" >> /root/.bashrc
RUN mkdir /workspace
WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
