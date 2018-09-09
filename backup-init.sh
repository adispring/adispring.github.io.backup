#!/bin/bash

GIT_ROOT_DIR="$(git rev-parse --show-toplevel)"
HEXO_DIR="$GIT_ROOT_DIR/adispring.github.io"
HOOK_DIR="$GIT_ROOT_DIR/git-hook"

hexo_git=(.git .deploy_git)

cd "$HEXO_DIR"
for dir_name in ${hexo_git[@]}
do
    rm -rf "$HEXO_DIR/$dir_name"
done
hexo clean

cd "$HOOK_DIR"
source git-hook-install.sh

cd "$GIT_ROOT_DIR"
