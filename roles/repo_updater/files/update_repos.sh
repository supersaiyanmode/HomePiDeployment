#!/bin/sh

for repo in "$@"; do
    cd $repo
    GIT_SSH_COMMAND="${SSH_PRE}$(basename $repo)" git pull
done

