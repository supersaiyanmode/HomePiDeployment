#!/bin/sh

for repo in "$@"; do
    cd ~rpi/Code/$repo
    git pull
done
