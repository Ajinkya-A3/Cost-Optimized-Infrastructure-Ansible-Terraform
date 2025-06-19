#!/bin/bash
sudo apt update -y
sudo apt install -y python3 python3-pip  ansible unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sudo useradd -m ansible

# Set password for ansible user
echo "ansible:Ansible" | sudo chpasswd

sudo mkdir -p /home/ansible/.ssh

sudo cat <<EOF > /home/ansible/.ssh/id_rsa
${private_key}
EOF

sudo cat <<EOF > /home/ansible/.ssh/id_rsa.pub
${public_key}
EOF

sudo chmod 600 /home/ansible/.ssh/id_rsa
sudo chmod 644 /home/ansible/.ssh/id_rsa.pub
sudo chown -R ansible:ansible /home/ansible/.ssh