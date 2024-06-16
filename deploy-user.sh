#!/usr/bin/env bash
set -euo pipefail

# `ssh`ed, e.g., `myl@host` without the port
URI=$1
echo "URI=$URI"
SSH_PORT=${SSH_PORT:-22}
echo "SSH_PORT=$SSH_PORT"

function ssh_cmd() {
  ssh -p "$SSH_PORT" "$URI" "$1"
}

# The **remote** host needs rsync installed
function rsync_push() {
  rsync -e "ssh -p $SSH_PORT" "$1" "$URI":./
}

ssh_cmd 'sudo rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key.pub'
rsync_push ca_user_key.pub
ssh_cmd 'sudo cp ca_user_key.pub /etc/ssh/'
ssh_cmd 'rm ca_user_key.pub'
rsync_push sshd_config.d/ca_user.conf
ssh_cmd 'sudo cp ca_user.conf /etc/ssh/sshd_config.d/'
ssh_cmd 'rm ca_user.conf'
ssh_cmd 'sudo systemctl restart ssh'
