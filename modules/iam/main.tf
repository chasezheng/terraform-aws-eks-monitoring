resource "random_string" "name-suffix" {
  length  = 8
  special = false
  upper   = false
}
