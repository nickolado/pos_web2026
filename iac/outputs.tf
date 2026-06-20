output "ec2_public_ip" {
  description = "Cole este valor no Secret HOST do GitHub"
  value       = aws_instance.web.public_ip
}

output "rds_endpoint" {
  description = "Cole este valor no Secret DB_HOST do GitHub"
  value       = aws_db_instance.myapp_db.address
}