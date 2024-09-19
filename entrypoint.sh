#!/bin/env bash

source /opt/venv/bin/activate
git clone https://github.com/VundleVim/Vundle.vim.git /root/.vim/bundle/Vundle.vim
vim -E -s -u "${HOME}/.vimrc" +PluginInstall +qall
/bin/bash
