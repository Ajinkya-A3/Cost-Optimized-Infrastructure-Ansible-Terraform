resource "tls_private_key" "ansible" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "local_file" "private_key" {
  content         = tls_private_key.ansible.private_key_pem
  filename        = "${path.module}/key-pair/ansible_private_key.pem"
  file_permission = 0400
}

resource "aws_key_pair" "name" {
  key_name   = "ansible_key"
  public_key = tls_private_key.ansible.public_key_openssh

  tags = {
    Name = "ansible_key"
  }

}

resource "aws_security_group" "ansible_sg" {
  name        = "ansible_sg"
  description = "Security group for Ansible control node"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "control_node" {
  ami = var.ami_id

  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ansible_sg.id]

  subnet_id = var.subnet_id

  key_name = aws_key_pair.name.key_name

  user_data = templatefile("${path.module}/scripts/control_node.sh", {
    private_key = tls_private_key.ansible.private_key_pem
    public_key  = tls_private_key.ansible.public_key_openssh
  })

  tags = {
    Name        = "Ansible Control Node"
    role        = "control_node"
    Environment = "Dev"
  }
}

resource "aws_instance" "worker_node" {
  count = var.worker_node_count

  ami = var.ami_id

  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ansible_sg.id]

  subnet_id = var.subnet_id

  key_name = aws_key_pair.name.key_name

  tags = {
    Name        = "Ansible Worker Node ${count.index}"
    role        = "worker_node"
    Environment = "Dev"
  }

  user_data = templatefile("${path.module}/scripts/worker_node.sh", {
    control_pubkey = tls_private_key.ansible.public_key_openssh
  })

}

module "start_ec2" {
  source = "git::https://github.com/Ajinkya-A3/Aws-Lambda-Terraform.git//module?ref=main"

  lambda_function_name           = "start_ec2"
  lambda_handler                 = "start.lambda_handler"
  lambda_source_file             = "${path.module}/python/start.py"
  policy_template_path           = "${path.module}/policies/lambda_policy.json"
  cloudwatch_schedule_expression = "cron(30 2 * * ? *)" # Every day at 2:30 AM UTC or 8:00 AM IST
  cloudwatch_rule_name           = "start-at-morning"
  cloudwatch_rule_description    = "Trigger Lambda every morning to start EC2 instances"


}

module "stop_ec2" {
  source = "git::https://github.com/Ajinkya-A3/Aws-Lambda-Terraform.git//module?ref=main"

  lambda_function_name           = "stop_ec2"
  lambda_handler                 = "stop.lambda_handler"
  lambda_source_file             = "${path.module}/python/stop.py"
  policy_template_path           = "${path.module}/policies/lambda_policy.json"
  cloudwatch_schedule_expression = "cron(30 14 * * ? *)" # Every day at 2:30 PM UTC or 8:00 PM IST
  cloudwatch_rule_name           = "stop-at-evening"
  cloudwatch_rule_description    = "Trigger Lambda every evening to stop EC2 instances"

}
