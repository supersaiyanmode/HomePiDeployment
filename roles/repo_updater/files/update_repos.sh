#!/bin/sh

for repo in "$@"; do
    cd $(dirname $repo)
    GIT_SSH_COMMAND="${SSH_PRE}$(basename $repo)" git pull
done

