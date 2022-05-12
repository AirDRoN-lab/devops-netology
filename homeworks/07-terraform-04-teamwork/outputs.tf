output "ec2_instance_public_ips" {
description = "Public IP addresses of EC2 instances"
value       = module.ec2_instance.public_ip
}

output "instance_id" {
description = "The private subnet id."
value       = module.ec2_instance.id
}

output "private_ip" {
description = "The private IP addresss"
value       = module.ec2_instance.private_ip
}
