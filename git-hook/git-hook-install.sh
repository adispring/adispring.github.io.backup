#!/bin/bash

INSTALL_PATH="$(cd "$(dirname "$0")" && pwd -P)"
GIT_ROOT_DIR="$(git rev-parse --show-toplevel)"
PROJECT_ROOT=${PROJECT_ROOT:-$(cd "$GIT_ROOT_DIR"; pwd -P)}
FROM_HOOK_PATH="$INSTALL_PATH/hooks"
TO_HOOK_PATH="$PROJECT_ROOT/.git/hooks"

echo -e "GIT CLIENT HOOK installing...! ⚙ \n"
for hook_file in ${FROM_HOOK_PATH}/*
do
  echo "install ${hook_file}"
  file_name=`basename $hook_file`
  cp "$FROM_HOOK_PATH/$file_name" "$TO_HOOK_PATH/$file_name"
done
echo "GIT CLIENT HOOK install done!  🍻"

