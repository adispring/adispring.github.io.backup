#!/bin/bash

GIT_ROOT_DIR="$(git rev-parse --show-toplevel)"
HEXO_DIR="$GIT_ROOT_DIR/adispring.github.io"
HOOK_DIR="$GIT_ROOT_DIR/git-hook"

hexo_git=(.git .deploy_git)

cd "$HEXO_DIR"

npm i hexo-cli -g

yarn

rm -rf ./themes/next
git clone https://github.com/theme-next/hexo-theme-next themes/next

# 修复锚点不生效问题
cp ./init_source/hexo-renderer-markdown-it/lib/renderer.js ./node_modules/hexo-renderer-markdown-it/lib/renderer.js

# 自动配置 favicon
cp ./init_source/next/_config.yml ./themes/next/_config.yml

for dir_name in ${hexo_git[@]}
do
    rm -rf "$HEXO_DIR/$dir_name"
done
hexo clean

cd "$HOOK_DIR"
source git-hook-install.sh

cd "$GIT_ROOT_DIR"
