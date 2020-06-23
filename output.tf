output "instance_ip_addr" {
  value = aws_instance.instance_wordpress.public_ip
}

output "efs_dns_name" {
  value = aws_efs_file_system.efs-wordpress.dns_name
}