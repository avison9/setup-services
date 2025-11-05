variable "region" {
  description = "AWS region"
  type        = string
}

variable "identifier" {
  description = "RDS instance identifier (lowercase, hyphenated)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.identifier))
    error_message = "Identifier must be lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from VPC module"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (from VPC module)"
  type        = list(string)
  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnets required for Multi-AZ."
  }
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["mysql", "postgres", "aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "Supported engines: mysql, postgres, aurora-postgresql, aurora-mysql."
  }
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "15.5"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Storage in GB"
  type        = number
  default     = 100
}

variable "max_allocated_storage" {
  description = "Max storage autoscaling limit"
  type        = number
  default     = 1000
}

variable "database_name" {
  description = "Initial database name"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "create_random_password" {
  description = "Generate random password"
  type        = bool
  default     = true
}

variable "password" {
  description = "Master password (if not random)"
  type        = string
  default     = null
  sensitive   = true
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Days to retain automated backups"
  type        = number
  default     = 7
}

variable "maintenance_window" {
  description = "Preferred maintenance window (e.g., sun:03:00-sun:04:00)"
  type        = string
  default     = "sun:03:00-sun:04:00"
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "02:00-03:00"
}

variable "enable_enhanced_monitoring" {
  description = "Enable Enhanced Monitoring"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention" {
  description = "Performance Insights retention in days"
  type        = number
  default     = 7
}

variable "create_read_replica" {
  description = "Create read replica in different AZ"
  type        = bool
  default     = true
}

variable "enable_cross_region_snapshot_copy" {
  description = "Copy final snapshot to DR region"
  type        = bool
  default     = true
}

variable "dr_region" {
  description = "Disaster recovery region"
  type        = string
  default     = "eu-east-1"
}

variable "kms_key_id" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

variable "default_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "parameter_group_parameters" {
  description = "Custom DB parameters"
  type        = map(string)
  default     = {}
}

variable "bastion_security_group_ids" {
  description = "List of bastion SGs allowed to access RDS"
  type        = list(string)
  default     = []
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 to disable)"
  type        = number
  default     = 60
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Valid values: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "enable_dr_snapshot" {
  type    = bool
  default = true
}

variable "dr_kms_key_id" {
  type    = string
  default = null
}

variable "create_manual_snapshot" {
  description = "Create a manual snapshot of the primary DB"
  type        = bool
  default     = true
}

variable "rotate_password" {
  description = "Enable password rotation (requires create_random_password)"
  type        = bool
  default     = true
}
