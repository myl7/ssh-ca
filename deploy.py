#!/usr/bin/env python3
import argparse
import subprocess

parser = argparse.ArgumentParser(prog='deploy_user')
parser.add_argument('-p', '--port', type=int, default=22)
parser.add_argument('-n', '--hostname')
parser.add_argument('ssh_uri')
args = parser.parse_args()

hostname = args.hostname
if not hostname:
    hostname = args.ssh_uri.split('@', 1)[1]

ssh_cmd = ['ssh', '-p', str(args.port), args.ssh_uri]
infra_ssh_boot_cmd = ['../infra/boot/ssh.py', '-p', str(args.port)]

subprocess.check_call(ssh_cmd + ['sudo', 'rm', '-f',  '/etc/ssh/ssh_host_dsa_key', '/etc/ssh/ssh_host_dsa_key.pub'])
subprocess.check_call(infra_ssh_boot_cmd + ['-s', 'sshd_config', f'{args.ssh_uri}:/etc/ssh/sshd_config'])
subprocess.check_call(infra_ssh_boot_cmd + ['-rs', 'sshd_config.d/', f'{args.ssh_uri}:/etc/ssh/sshd_config.d/'])
for key_type in ['rsa', 'ecdsa', 'ed25519']:
    subprocess.check_call(infra_ssh_boot_cmd +
                          [f'{args.ssh_uri}:/etc/ssh/ssh_host_{key_type}_key.pub', f'ssh_host_{key_type}_key.pub'])
    subprocess.check_call(['ssh-keygen', '-s', '../ssh-ca-keys/ca_host_key',
                          '-I', hostname, '-h', f'ssh_host_{key_type}_key.pub'])
    subprocess.check_call(infra_ssh_boot_cmd + ['-s', f'ssh_host_{key_type}_key-cert.pub',
                          f'{args.ssh_uri}:/etc/ssh/ssh_host_{key_type}_key-cert.pub'])
    subprocess.check_call(['rm', f'ssh_host_{key_type}_key.pub', f'ssh_host_{key_type}_key-cert.pub'])
subprocess.check_call(ssh_cmd + ['sudo', 'systemctl', 'restart', 'ssh'])
