output "image_id" {
  value = data.aws_ami.ubuntu_latest.id
}

output "instance1_ip_addr" {
  value       = aws_instance.netolo[*].private_ip
  description = "The private IP address of the main server instance."
}

#output "instance2_ip_addr" {
#  value       = aws_instance.netolo_node2[*].private_ip
#  description = "The private IP address of the main server instance."
#}

output "instance1_ip_public_addr" {
  value       = aws_instance.netolo[*].public_ip
  description = "Public IP"
}

output "instance2_ip_public_addr" {
  value       = aws_instance.netolo_node2[0].public_ip
  description = "Public IP"
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "regions_id" {
  value = data.aws_region.current.name
}

#output "instance1_subnet_id" {
#  value       = aws_instance.netolo[*].subnet_id
#}

#output "instance2_id" {
#  value       = aws_instance.netolo_node2[*].subnet_id
#}

