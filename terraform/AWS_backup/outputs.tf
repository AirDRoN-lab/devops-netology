output "image_id" {
  value = data.aws_ami.ubuntu_latest.id
}

output "instance_ip_addr" {
  value       = aws_instance.netolo.private_ip
  description = "The private IP address of the main server instance."
}

output "instance_core" {
  value       = aws_instance.netolo.cpu_core_count
  description = "The instances COREs"
}

output "instance_ip_public_addr" {
  value       = aws_instance.netolo.public_ip
  description = "Public IP"
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "regions_id" {
  value = data.aws_regions.current.id
}

output "regions_names" {
  value = data.aws_regions.current.names
}

output "AZ_names" {
  value = data.aws_availability_zones.current.names
}

output "subnet_id" {
  value       = aws_instance.netolo.subnet_id
}

