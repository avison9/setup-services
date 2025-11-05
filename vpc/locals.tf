# locals.tf
locals {
  name_prefix = "${var.environment}-${var.vpc_name}"

  subnet_tags = {
    public  = { "kubernetes.io/role/elb" = "1" }
    private = { "kubernetes.io/role/internal-elb" = "1" }
  }
}