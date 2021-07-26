# Shared variables
variable "location" {
  type    = string
  default = "Central US"
}

# Tags
variable "tags" {
  type = map(string)
  default = {
    "env"        = "dev"
    "created_by" = "terraform"
  }
}
