#!/usr/bin/env bash
set -euo pipefail

# `ssh`ed, e.g., `myl@host` without the port
URI=$1
echo "URI=$URI"
SSH_PORT=${SSH_PORT:-22}
echo "SSH_PORT=$SSH_PORT"
HOSTNAME=$2
echo "HOSTNAME=$HOSTNAME"

function ssh_cmd() {
  ssh -p "$SSH_PORT" "$URI" "$1"
}

# The **remote** host needs rsync installed
function rsync_push() {
  rsync -e "ssh -p $SSH_PORT" "$1" "$URI":./
}
function rsync_pull() {
  rsync -e "ssh -p $SSH_PORT" "$URI":"$1" ./
}

rsync_pull /etc/ssh/ssh_host_rsa_key.pub
rsync_pull /etc/ssh/ssh_host_ecdsa_key.pub
rsync_pull /etc/ssh/ssh_host_ed25519_key.pub
ssh-keygen -s ../ssh-ca-keys/ca_host_key -I "$HOSTNAME" -h ssh_host_rsa_key.pub
ssh-keygen -s ../ssh-ca-keys/ca_host_key -I "$HOSTNAME" -h ssh_host_ecdsa_key.pub
ssh-keygen -s ../ssh-ca-keys/ca_host_key -I "$HOSTNAME" -h ssh_host_ed25519_key.pub
rsync_push ssh_host_rsa_key-cert.pub
ssh_cmd 'sudo cp ssh_host_rsa_key-cert.pub /etc/ssh/'
ssh_cmd 'rm ssh_host_rsa_key-cert.pub'
rsync_push ssh_host_ecdsa_key-cert.pub
ssh_cmd 'sudo cp ssh_host_ecdsa_key-cert.pub /etc/ssh/'
ssh_cmd 'rm ssh_host_ecdsa_key-cert.pub'
rsync_push ssh_host_ed25519_key-cert.pub
ssh_cmd 'sudo cp ssh_host_ed25519_key-cert.pub /etc/ssh/'
ssh_cmd 'rm ssh_host_ed25519_key-cert.pub'
rm ssh_host_rsa_key.pub ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub
rm ssh_host_rsa_key-cert.pub ssh_host_ecdsa_key-cert.pub ssh_host_ed25519_key-cert.pub
rsync_push sshd_config.d/ca_host.conf
ssh_cmd 'sudo cp ca_host.conf /etc/ssh/sshd_config.d/'
ssh_cmd 'rm ca_host.conf'
ssh_cmd 'sudo systemctl restart ssh'
