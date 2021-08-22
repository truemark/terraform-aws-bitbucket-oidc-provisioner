output "role_name" {
  value = module.bitbucket_service_provisioner.iam_role_name
}

output "role_arn" {
  value = module.bitbucket_service_provisioner.iam_role_arn
}

output "role_id" {
  value = module.bitbucket_service_provisioner.iam_role_unique_id
}

output "role_path" {
  value = module.bitbucket_service_provisioner.iam_role_path
}

output "terraform_policy_name" {
  value = join("", aws_iam_policy.terraform.*.name)
}

output "terraform_policy_arn" {
  value = join("", aws_iam_policy.terraform.*.arn)
}

output "terraform_policy_id" {
  value = join("", aws_iam_policy.terraform.*.id)
}
