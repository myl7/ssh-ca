exit 1

# RSA uses the default 3072-bit key size, which is comparable to 128-bit AES and 256-bit ECC.
sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
sudo ssh-keygen -t ecdsa -b 256 -f /etc/ssh/ssh_host_ecdsa_key
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# Expected to see the prompt "/etc/ssh/ssh_host_*_key already exists. Overwrite (y/n)?"
