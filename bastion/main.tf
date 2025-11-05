
# ========= Shared Security Group =========
resource "aws_security_group" "bastion" {
  name   = "${local.name_prefix}-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-sg" }
}

# ========= IAM for SSM =========
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.name_prefix}-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role" "bastion" {
  name = "${local.name_prefix}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ------------------------------------------------------------------
# 1. SSH key pair per bastion (auto-generated)
# ------------------------------------------------------------------
resource "tls_private_key" "bastion" {
  for_each  = var.bastions
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  for_each   = var.bastions
  key_name   = "${local.name_prefix}-${each.key}-key"
  public_key = tls_private_key.bastion[each.key].public_key_openssh
  tags       = { Name = "${local.name_prefix}-${each.key}-key" }
}

resource "aws_ssm_parameter" "bastion_private_key" {
  for_each    = var.bastions
  name        = "/bastion/${var.environment}/${each.key}/private-key"
  type        = "SecureString"
  value       = tls_private_key.bastion[each.key].private_key_pem
  description = "Private key for ${each.key} bastion"
  tags        = { Bastion = each.key }
}

# ------------------------------------------------------------------
# 2. GitHub runner user-data – **count**, NOT for_each on token
# ------------------------------------------------------------------
data "template_file" "github_runner" {
  count = anytrue([
    for k, v in var.bastions : v.enable_github_runner && var.github_token != ""
  ]) ? 1 : 0

  template = file("${path.module}/scripts/github_runner.sh")

  vars = {
    ORGANIZATION = var.github_organization_name
    TOKEN        = var.github_token
    RUNNER_NAME = "${local.name_prefix}-${element([
      for k, v in var.bastions : k if v.enable_github_runner
    ], 0)}"
  }
}

# ------------------------------------------------------------------
# 3. Bastion instances
# ------------------------------------------------------------------
resource "aws_instance" "bastion" {
  for_each = var.bastions

  ami           = local.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[index(keys(var.bastions), each.key) % length(var.public_subnet_ids)]
  key_name      = aws_key_pair.bastion[each.key].key_name

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  user_data_base64 = (
    # 1. GitHub Runner
    each.value.enable_github_runner && var.github_token != "" ?
    base64encode(data.template_file.github_runner[0].rendered) :

    # 2. DB Admin
    each.value.enable_rds_access ?
    base64encode(data.template_file.db_admin[0].rendered) :

    # 3. Custom user_data
    (each.value.user_data != null ? base64encode(each.value.user_data) : null)
  )

  tags = {
    Name    = "${local.name_prefix}-${each.key}"
    Purpose = each.value.purpose
    Role    = each.key
  }

  lifecycle { create_before_destroy = true }
}

# ------------------------------------------------------------------
# 2. DB Admin user-data template
# ------------------------------------------------------------------
data "template_file" "db_admin" {
  count = anytrue([
    for k, v in var.bastions : v.enable_rds_access
  ]) ? 1 : 0

  template = file("${path.module}/scripts/db_admin.sh")

  vars = {
    RDS_ENDPOINT = var.rds_endpoint
    SECRET_ARN   = var.rds_secret_arn
  }
}