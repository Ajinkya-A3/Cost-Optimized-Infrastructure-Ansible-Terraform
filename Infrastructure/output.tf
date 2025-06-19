output "control_node_ip" {
  description = "The ID of the Ansible control node instance."
  value       = aws_instance.control_node.public_ip

}
output "control_node_id" {
  description = "Ansible control node instance ID."
  value       = aws_instance.control_node.id

}

output "worker_node_info" {
  description = "Information about the worker nodes."
  value = {
    instance_ids = aws_instance.worker_node[*].id
    public_ips   = aws_instance.worker_node[*].public_ip
  }

}

output "key_pair_info" {
  description = "path to private key file for Ansible control node."
  value       = local_file.private_key.filename
}