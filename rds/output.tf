# rds/outputs.tf
output "primary_endpoint" {
  description = "Primary RDS endpoint (writer)"
  value       = aws_db_instance.primary.endpoint
}

output "replica_endpoint" {
  description = "Replica RDS endpoint (reader)"
  value       = var.create_read_replica ? aws_db_instance.replica[0].endpoint : "N/A"
}

output "secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.rds_password.arn
}

output "secret_name" {
  description = "Secrets Manager secret name"
  value       = aws_secretsmanager_secret.rds_password.name
}

output "security_group_id" {
  value = aws_security_group.rds.id
}

output "subnet_group_name" {
  value = aws_db_subnet_group.this.name
}

output "arn" {
  value = aws_db_instance.primary.arn
}


