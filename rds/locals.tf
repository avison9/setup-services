locals {
  name_prefix = "${var.environment}-${var.identifier}"

  # final_password = var.create_random_password ? random_password.this[0].result : var.password

  is_aurora = contains(["aurora-postgresql", "aurora-mysql"], var.engine)

}