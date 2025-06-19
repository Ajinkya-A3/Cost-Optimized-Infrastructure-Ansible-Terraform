#!/bin/bash
sudo apt update -y
sudo apt install -y python3

sudo useradd -m ansible

# Set password for ansible user
echo "ansible:Ansible" | sudo chpasswd

sudo mkdir -p /home/ansible/.ssh

sudo cat <<EOF > /home/ansible/.ssh/authorized_keys
${control_pubkey}
EOF

sudo chmod 600 /home/ansible/.ssh/authorized_keys
sudo chown -R ansible:ansible /home/ansible/.ssh

# Grant passwordless sudo access to ansible user
echo 'ansible ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ansible
sudo chmod 0440 /etc/sudoers.d/ansible