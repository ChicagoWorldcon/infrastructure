variable "domain_name" {
  type        = string
  description = "The domain name to create a zone for"
  default     = "chicon.org"
}

variable "project" {
  type    = string
  default = "Chicon8"
}

variable "role" {
  type    = string
  default = "IT"
}
