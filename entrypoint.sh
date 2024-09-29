#!/bin/env bash

source /opt/venv/bin/activate
git clone https://github.com/VundleVim/Vundle.vim.git /root/.vim/bundle/Vundle.vim
vim -E -s -u "${HOME}/.vimrc" +PluginInstall +qall
if [ -n "${LOCAL_USER_ID}" ]; then
	echo "Starting with UID : $LOCAL_USER_ID"
	# modify existing user's id
	usermod -u $LOCAL_USER_ID user
	# run as user
	exec gosu user "$@"
else
	exec "$@"
fi
/bin/bash
