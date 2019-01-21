#!/bin/bash

yum -y update
yum -y install epel-release
yum -y install vim

cat <<EOF > /home/centos/.vimrc
autocmd FileType yaml setlocal ai ts=2 sw=2 et
filetype plugin indent on
set nocompatible
set relativenumber
set cursorline
set showmatch
set incsearch
set hlsearch
set expandtab
EOF

cat <<EOF > /root/.vimrc
autocmd FileType yaml setlocal ai ts=2 sw=2 et
filetype plugin indent on
set nocompatible
set relativenumber
set cursorline
set showmatch
set incsearch
set hlsearch
set expandtab
EOF