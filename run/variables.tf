variable "region" {
  description = "AWS region for the VPC"
  type        = string
}
variable "vpc_name" {
  description = "Name of the VPC (used in tags and naming)"
  type        = string
}
variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
}
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "Must be a valid CIDR block."
  }
}
variable "availability_zones" {
  description = "List of AZs to use (e.g., ['us-east-1a', 'us-east-1b'])"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 AZs are required for HA."
  }
}
variable "public_subnets" {
  description = "List of public subnet CIDRs (one per AZ)"
  type        = list(string)
  validation {
    condition     = length(var.public_subnets) >= 3
    error_message = "One public subnet CIDR per AZ is required."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDRs (one per AZ)"
  type        = list(string)
  validation {
    condition     = length(var.private_subnets) >= 3
    error_message = "One private subnet CIDR per AZ is required."
  }
}



variable "identifier" {
  description = "RDS instance identifier (lowercase, hyphenated)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.identifier))
    error_message = "Identifier must be lowercase letters, numbers, and hyphens only."
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

variable "monitoring_interval" {
  description = "Monitoring interval in seconds"
  type        = number
  default     = 60
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
  default     = "us-west-2"
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




variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub org-level runner registration token"
}

variable "github_org_name" {
  type    = string
  default = "Oraion"
}

variable "bastions" {
  description = "Map of bastion hosts to create"
  type = map(object({
    purpose              = string
    enable_rds_access    = optional(bool, false)
    enable_github_runner = optional(bool, false)
    github_repo_url      = optional(string, "")
    user_data            = optional(string, "")
  }))
  default = {}
}