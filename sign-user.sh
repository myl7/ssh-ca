#!/usr/bin/env bash
set -euo pipefail

USERNAME=$1
echo "USERNAME=$USERNAME"
SIGNED_PUB_PATH=$2
echo "SIGNED_PUB_PATH=$SIGNED_PUB_PATH"
# The output public cert key is located next to the signed public key with the `-cert` suffix
# Principals are mandatory for authentication. It is a comma-separated list of UNIX usernames
PRINCIPALS=${PRINCIPALS:-$USERNAME,root,ubuntu}
echo "PRINCIPALS=$PRINCIPALS"

ssh-keygen -s ../ssh-ca-keys/ca_user_key -I "$USERNAME" -n "$PRINCIPALS" "$SIGNED_PUB_PATH"
