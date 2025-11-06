
output "RDS_PRIMARY_ENDPOINT" {
  value = module.rds_database.primary_endpoint
}

output "RDS_REPLICA_ENDPOINT" {
  value = module.rds_database.replica_endpoint
}

output "BASTION_IP_ADDRESSES" {
  value = module.bastions.bastion_ips
}

output "SECRET_ARN" {
  value = module.rds_database.secret_arn
}

output "SECRET_NAME" {
  value = module.rds_database.secret_name
}

output "GET_PEM_KEYS" {
  value = module.bastions.how_to_get_private_key
}