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
RUN /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt
# RUN rm -rf /var/cache/pacman/pkg/*
# RUN rm -rf /var/lib/pacman/sync/*
# RUN rm -rf /etc/pacman.d/gnupg
COPY --from=tianon/gosu /gosu /usr/local/bin/
RUN useradd --shell /bin/bash -u 1001 -c "" -m user && usermod -a -G wheel user && echo 'user:user' | chpasswd
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
COPY dotfiles/.bashrc /home/user/.
COPY dotfiles/.vimrc /home/user/.
ENV VENV_PATH=/opt/venv
RUN echo "source /opt/venv/bin/activate" >> /home/user/.bashrc
RUN mkdir /workspace
WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
