variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "organization" {
  description = "Github username or organization name"
  type        = string
}

variable "repository" {
  description = "Github repository name"
  type        = string
}

variable "organization_id" {
  description = "Github owner ID, for the immutable OIDC subject format"
  type        = string
  default     = ""
}

variable "repository_id" {
  description = "Github repository ID, for the immutable OIDC subject format"
  type        = string
  default     = ""
}
