#!/bin/sh

BASE=$1

SSH_PRE="ssh -i ~/.ssh/id_rsa-"

for repo in $BASE/*; do
    cd $repo

    e=${SSH_PRE}$(basename $repo)

    GIT_SSH_COMMAND="$e" git fetch

    head=$(GIT_SSH_COMMAND="$e" git rev-parse HEAD)
    remote=$(GIT_SSH_COMMAND="$e" git rev-parse @{u})
    if [ $head != $remote ]; then
	echo $repo
    fi
done
