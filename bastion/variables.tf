variable "region" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "instance_type" {
  type    = string
  default = "t3.small"
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

variable "rds_sg_id" {
  description = "RDS Security Group ID"
  type        = string
  default     = ""
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub org-level runner registration token"
}

variable "github_organization_name" {
  type        = string
  description = "Your GitHub organization (e.g. mycompany)"
}

variable "rds_endpoint" {
  type    = string
  default = ""
}

variable "rds_secret_arn" {
  type      = string
  default   = ""
  sensitive = true
}