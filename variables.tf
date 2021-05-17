variable "app_name" {
  type = string
  description = "Must be bucket compatible, so A-Za-z0-9-: no underscores!"
  default = "craas"
}

variable "aws_access_key_id" {}
variable "aws_secrey_access_key" {}