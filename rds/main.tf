data "aws_caller_identity" "current" {}

# ========= Random Password =========
resource "random_password" "rds_master" {
  count   = var.create_random_password ? 1 : 0
  length  = 20
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# ========= KMS Key (if not provided) =========
resource "aws_kms_key" "this" {
  count                   = var.kms_key_id == null ? 1 : 0
  description             = "KMS key for RDS ${local.name_prefix}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# ========= DB Subnet Group =========
resource "aws_db_subnet_group" "this" {
  name       = local.name_prefix
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${local.name_prefix}-subnet-group"
  }
}

# ========= Parameter Group =========
resource "aws_db_parameter_group" "this" {
  name = "${local.name_prefix}-pg"
  family = local.is_aurora ? null : (
    var.engine == "mysql" ? "mysql8.0" : "postgres17"
  )
  description = "Auto-generated PG for ${local.name_prefix}"

  dynamic "parameter" {
    for_each = merge({
      log_connections            = "1"
      log_disconnections         = "1"
      log_min_duration_statement = "1000"
    }, var.parameter_group_parameters)

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "${local.name_prefix}-pg" }
}

# ========= Security Group =========
resource "aws_security_group" "rds" {
  name   = "${local.name_prefix}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "App to RDS"
    from_port   = local.is_aurora ? 5432 : (var.engine == "mysql" ? 3306 : 5432)
    to_port     = local.is_aurora ? 5432 : (var.engine == "mysql" ? 3306 : 5432)
    protocol    = "tcp"
    cidr_blocks = [] # Use cidr here if you prefer to use cidr
    # security_groups = var.app_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-rds-sg"
  }
}

# ========= Primary RDS Instance =========
resource "aws_db_instance" "primary" {
  identifier = "${local.name_prefix}-primary"

  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  db_name  = var.database_name
  username = var.master_username
  password = jsondecode(aws_secretsmanager_secret_version.current[0].secret_string)["password"]
  parameter_group_name = aws_db_parameter_group.this.name

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  multi_az          = var.multi_az
  storage_encrypted = true
  kms_key_id        = var.kms_key_id != null ? var.kms_key_id : aws_kms_key.this[0].arn

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  skip_final_snapshot       = true
  final_snapshot_identifier = "${local.name_prefix}-final-snapshot-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention

  # enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  enabled_cloudwatch_logs_exports = []

  copy_tags_to_snapshot = true
  # deletion_protection   = var.environment == "prod"
  deletion_protection = false


  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  apply_immediately = true

  tags = {
    Name = "${local.name_prefix}-primary"
    Role = "primary"
  }

  lifecycle {
    ignore_changes       = [final_snapshot_identifier]
    replace_triggered_by = [aws_secretsmanager_secret_version.current[0]]
  }

}

# ========= Read Replica =========
resource "aws_db_instance" "replica" {
  count = var.create_read_replica ? 1 : 0

  identifier          = "${local.name_prefix}-replica"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = var.instance_class
  publicly_accessible = false
  multi_az            = false
  storage_encrypted   = true
  kms_key_id          = var.kms_key_id != null ? var.kms_key_id : aws_kms_key.this[0].arn

  skip_final_snapshot     = true
  backup_retention_period = 0

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    Name = "${local.name_prefix}-replica"
    Role = "replica"
  }
}

# === MANUAL SNAPSHOT ===
resource "aws_db_snapshot" "manual" {
  count                  = var.create_manual_snapshot ? 1 : 0
  db_instance_identifier = aws_db_instance.primary.identifier
  db_snapshot_identifier = "${local.name_prefix}-manual-snapshot"

  depends_on = [aws_db_instance.primary]

  tags = { Name = "${local.name_prefix}-manual-snapshot" }
}

# === COPY TO DR ===
resource "aws_db_snapshot_copy" "dr" {
  count                         = var.enable_dr_snapshot && var.create_manual_snapshot ? 1 : 0
  source_db_snapshot_identifier = aws_db_snapshot.manual[count.index].id
  target_db_snapshot_identifier = "${local.name_prefix}-dr-snapshot"
  destination_region            = var.dr_region
  kms_key_id                    = var.dr_kms_key_id

  tags = { Name = "${local.name_prefix}-dr-snapshot" }
}



resource "aws_security_group_rule" "from_bastion" {
  count = length(var.bastion_security_group_ids)

  type                     = "ingress"
  from_port                = 5432 # or 3306
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.bastion_security_group_ids[count.index]
  description              = "Bastion to RDS"
}

# === ENHANCED MONITORING ===
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${local.name_prefix}-rds-monitoring-roles"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ========= Secrets Manager Secret =========
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = "${local.name_prefix}-rds-password"
  description             = "Master password for RDS instance ${local.name_prefix}-primary. Auto-rotated every 30 days."
  kms_key_id              = var.kms_key_id != null ? var.kms_key_id : aws_kms_key.this[0].arn
  recovery_window_in_days = 0

  tags = {
    Name        = "${local.name_prefix}-rds-password"
    Environment = var.environment
    Purpose     = "RDS Master User Password"
  }
}

resource "aws_secretsmanager_secret_version" "current" {
  count     = var.create_random_password ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.rds_master[0].result
  })
  
}


resource "aws_secretsmanager_secret" "rds_connection" {
  name = "${local.name_prefix}-rds-connection"
  description             = "Connection details for RDS instance ${local.name_prefix}-primary."
}

resource "aws_secretsmanager_secret_version" "connection" {
  secret_id = aws_secretsmanager_secret.rds_connection.id
  secret_string = jsonencode({
    username    = var.master_username
    password_ref    = aws_secretsmanager_secret.rds_password.arn
    port        = local.is_aurora ? 5432 : (var.engine == "mysql" ? 3306 : 5432)
    write_host  = aws_db_instance.primary.address
    read_host   = var.create_read_replica ? aws_db_instance.replica[0].address : null
  })
}

# -------------------------------------------------
# Lambda that rotates the password
# -------------------------------------------------
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rotate_lambda" {
  count              = var.create_random_password ? 1 : 0
  name               = "${local.name_prefix}-rotate-pwd-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "rotate_lambda" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage"
    ]
    resources = [aws_secretsmanager_secret.rds_password.arn]
  }

  statement {
    actions = ["rds:ModifyDBInstance"]
    resources = [
      "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:db:${aws_db_instance.primary.identifier}",
      "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:db:${aws_db_instance.primary.identifier}-replica"
    ]
  }

  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "rotate_lambda" {
  count  = var.create_random_password ? 1 : 0
  name   = "${local.name_prefix}-rotate-pwd-policy"
  policy = data.aws_iam_policy_document.rotate_lambda.json
}

resource "aws_iam_role_policy_attachment" "rotate_lambda" {
  count      = var.create_random_password ? 1 : 0
  role       = aws_iam_role.rotate_lambda[0].name
  policy_arn = aws_iam_policy.rotate_lambda[0].arn
}

data "archive_file" "rotate_lambda_zip" {
  count       = var.create_random_password ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/rotate_lambda.zip"

  source {
    content  = file("${path.module}/rotate_lambda.py")
    filename = "rotate_lambda.py"
  }
}

resource "aws_lambda_function" "rotate_rds_password" {
  count            = var.create_random_password ? 1 : 0
  function_name    = "${local.name_prefix}-rotate-rds-pwd"
  role             = aws_iam_role.rotate_lambda[0].arn
  handler          = "rotate_lambda.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.rotate_lambda_zip[0].output_path
  source_code_hash = data.archive_file.rotate_lambda_zip[0].output_base64sha256

  environment {
    variables = {
      SECRET_ARN    = aws_secretsmanager_secret.rds_password.arn
      DB_IDENTIFIER = aws_db_instance.primary.identifier
      REGION        = var.region
    }
  }

  timeout = 30
}

# -------------------------------------------------
# Allow Secrets Manager to invoke YOUR Lambda
# -------------------------------------------------
resource "aws_lambda_permission" "allow_sm" {
  count         = var.create_random_password ? 1 : 0
  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotate_rds_password[0].function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.rds_password.arn
}

# -------------------------------------------------
# Rotation schedule (every 30 days)
# -------------------------------------------------
resource "aws_secretsmanager_secret_rotation" "rds_password" {
  count               = var.create_random_password ? 1 : 0
  secret_id           = aws_secretsmanager_secret.rds_password.id
  rotation_lambda_arn = aws_lambda_function.rotate_rds_password[0].arn

  rotation_rules {
    automatically_after_days = 30
  }
}

