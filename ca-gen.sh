exit 1

ssh-keygen -t ed25519 -f ../ssh-ca-keys/ca_user_key
mv ../ssh-ca-keys/ca_user_key.pub .
ssh-keygen -t ed25519 -f ../ssh-ca-keys/ca_host_key
mv ../ssh-ca-keys/ca_host_key.pub .
