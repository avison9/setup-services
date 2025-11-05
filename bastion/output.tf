output "bastion_ips" {
  description = "Map of bastion name → public IP"
  value = {
    for k, v in aws_instance.bastion : k => v.public_ip
  }
}

output "bastion_key_names" {
  value = { for k, v in aws_key_pair.bastion : k => v.key_name }
}

output "bastion_private_key_ssm_paths" {
  value = { for k, v in aws_ssm_parameter.bastion_private_key : k => v.name }
}

output "how_to_get_private_key" {
  value = <<EOT
To get private key for a bastion:

# For db-admin
aws ssm get-parameter --name "/bastion/prod/db-admin/private-key" --with-decryption --query "Parameter.Value" --output text > db-admin-bastion-key.pem
chmod 400 db-admin-bastion-key.pem

# For ci-runner
aws ssm get-parameter --name "/bastion/prod/ci-runner/private-key" --with-decryption --query "Parameter.Value" --output text > ci-runner-bastion-key.pem
chmod 400 ci-runner-bastion-key.pem
EOT
}

output "security_group_id" {
  description = "Security group ID of the bastion hosts"
  value       = aws_security_group.bastion.id
}