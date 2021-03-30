variable "production" {
  description = "Is that a production environment?"
  type        = bool
  default     = false
}

variable "name" {
  default = "myapp"
}

variable "environment" {
  default = "dev"
}

variable "region" {
  default = "us-east-1"
}
