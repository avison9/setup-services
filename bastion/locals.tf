locals {
  name_prefix = "${var.environment}-bastion"

  # Ubuntu 22.04
  ami_id = data.aws_ami.ubuntu.id

  # Flatten bastions with index
  bastion_list = flatten([
    for name, config in var.bastions : {
      name                 = name
      index                = index(keys(var.bastions), name)
      purpose              = config.purpose
      enable_rds_access    = config.enable_rds_access
      enable_github_runner = config.enable_github_runner
      github_repo_url      = config.github_repo_url
      user_data            = config.user_data
    }
  ])
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}