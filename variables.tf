variable "create_role" {
  description = "Whether to create role"
  type = bool
  default = true
}

variable "name" {
  description = "Name to use on resources"
  type = string
}

variable "path" {
  description = "Path to use on resources"
  default = "/"
  type = string
}

variable "tags" {
  description = "Tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "provider_urls" {
  description = "URLs for OIDC providers"
  type = list(string)
}

variable "role_policy_arns" {
  description = "List of ARNs of IAM policies to attach to IAM role"
  type = list(string)
  default = []
}

variable "allowed_repository_uuids" {
  description = "List of repository UUIDs allowed to use this role"
  type = list(string)
  default = []
}

variable "create_terraform_policy" {
  description = "Whether to create the policy for terraform access to S3 and Dynamo"
  type = bool
  default = true
}

variable "terraform_s3_bucket" {
  description = "Name of the terraform bucket holding terraform state information. Defaults to <account>-terraform."
  default = null
  type = string
}

variable "terraform_s3_prefix" {
  description = "Optional path prefix inside the terraform S3 bucket to grant access to."
  default = "*"
  type = string
}

variable "terraform_dynamodb_table" {
  description = "Name of the DynamoDB table holding terraform locks. Defaults to <account>-terraform."
  default = null
  type = string
}

variable "terraform_policy_tags" {
  description = "Tags to add to the terraform policy"
  type = map(string)
  default = {}
}

variable "policies" {
  description = "Policies to create and apply to the IAM user."
  default = []
  type = list(string)
}

variable "allow_self_assume_role" {
  description = "Allow the role to assume itself"
  default = true
  type = bool
}
