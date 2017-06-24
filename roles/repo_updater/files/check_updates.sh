#!/bin/sh

BASE=$1

SSH_PRE="ssh -i ~/.ssh/id_rsa-"

for repo in $BASE/*; do
    cd $repo

    local e=${SSH_PRE}$(basename $repo)

    GIT_SSH_COMMAND="$e" git fetch

    local head=$(GIT_SSH_COMMAND="$e" git rev-parse HEAD)
    local remote=$(GIT_SSH_COMMAND="$e" git rev-parse @{u})
    if [ $head != $remote ]; then
	echo $repo
    fi
done
