#!/bin/env bash

echo "Starting with UID : $LOCAL_USER_ID"
# modify existing user's id
usermod -u $LOCAL_USER_ID user
# run as user
mkdir -p /home/user/.vim/undodir
mkdir -p /home/user/.vim/backup
git clone https://github.com/VundleVim/Vundle.vim.git /home/user/.vim/bundle/Vundle.vim
chown -R user:user /home/user/.vim
gosu user bash -c 'vim -E -s -u /home/user/.vimrc +PluginInstall +qall'
exec gosu user "$@"

# exec gosu user vim -E -s -u "${HOME}/.vimrc" +PluginInstall +qall
# /bin/bash
