# variables.tf
variable "region" {
  description = "AWS region for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC (used in tags and naming)"
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

variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
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

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cost-optimized) instead of one per AZ"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}

variable "default_tags" {
  description = "Additional default tags"
  type        = map(string)
  default     = {}
}

variable "create_igw" {
  description = "Create Internet Gateway"
  type        = bool
  default     = true
}