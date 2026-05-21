output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_ip" {
  description = "Public IP of EC2 instance"
  value       = module.compute.public_ip
}