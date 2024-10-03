FROM archlinux:latest
ENV TERM=xterm-256color
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel cmake man man-db man-pages sudo
RUN pacman -S --noconfirm git graphviz doxygen python python-pip
RUN pacman -S --noconfirm texlive-core texlive-latexextra texlive-fontsextra
RUN pacman -S --noconfirm vim tmux clang openmp less valgrind boost wget gnuplot openssh
RUN wget https://archive.archlinux.org/packages/c/cuda/cuda-12.4.1-4-x86_64.pkg.tar.zst
RUN pacman -U --noconfirm cuda-12.4.1-4-x86_64.pkg.tar.zst
RUN rm cuda-12.4.1-4-x86_64.pkg.tar.zst
# RUN pacman -S --noconfirm cuda cuda-tools
RUN python -m venv /opt/venv
COPY requirements.txt /tmp/requirements.txt
RUN /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt
ARG AUR_USER=user
# can be paru or yay
ARG HELPER=paru
# install helper and add a user for it
ADD add-aur.sh /root
RUN bash /root/add-aur.sh "${AUR_USER}" "${HELPER}"
RUN aur-install paru vim-youcompleteme-git

# RUN rm -rf /var/cache/pacman/pkg/*
# RUN rm -rf /var/lib/pacman/sync/*
# RUN rm -rf /etc/pacman.d/gnupg
COPY --from=tianon/gosu /gosu /usr/local/bin/
COPY user.tar.xz /root/.
RUN tar -xf /root/user.tar.xz -C /root
RUN mkdir /workspace
WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
