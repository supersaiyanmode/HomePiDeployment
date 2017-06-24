#!/bin/sh

BASE=$1

for repo in $BASE/*; do
    cd $repo
    git fetch
    if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
	echo $(basename $repo)
    fi
done
