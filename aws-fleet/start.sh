#!/bin/sh
set -e
set -o nounset

eval `ssh-agent -s` > /dev/null
ssh-add /keys/private_key.pem  > /dev/null

exec "./fleet.rb" "$@"
