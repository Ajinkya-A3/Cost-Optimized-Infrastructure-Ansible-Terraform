variable "ami_id" {
  description = "The AMI ID to use for the Ansible control node."
  type        = string

}

variable "instance_type" {
  description = "The instance type for the Ansible control node."
  type        = string

}

variable "vpc_id" {
  description = "The VPC ID where the Ansible control node will be deployed."
  type        = string

}

variable "subnet_id" {
  description = "The subnet ID where the Ansible control node will be deployed."
  type        = string

}

variable "worker_node_count" {
  description = "The number of worker nodes to create."
  type        = number

}