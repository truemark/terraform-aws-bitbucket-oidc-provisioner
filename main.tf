data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------------
# OIDC Assumable Role
#------------------------------------------------------------------------------
locals {
  allowed_repository_uuids = [for uuid in var.allowed_repository_uuids: "{${replace(uuid, "/[{}]/", "")}}:*"]
}

module "bitbucket_service_provisioner" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.5.5"
  create_role = var.create_role
  role_name = var.name
  tags = merge({
    Role = var.name
  }, var.tags)
  provider_urls = var.provider_urls
  role_policy_arns = var.role_policy_arns
  oidc_subjects_with_wildcards = local.allowed_repository_uuids
  role_path = var.path
  allow_self_assume_role = var.allow_self_assume_role
}

#------------------------------------------------------------------------------
# Terraform S3 Access
#------------------------------------------------------------------------------
# This policy grants the provisioner user access to specific paths in the S3
# bucket holding terraform state. This is needed to prevent different
# provisioner users from stepping on one another's changes. Additionally, there
# is sensitive information stored in the state files in these S3 buckets which should be restricted.

locals {
  terraform_s3_bucket = var.terraform_s3_bucket == null ? "${data.aws_caller_identity.current.account_id}-terraform" : var.terraform_s3_bucket
  terraform_dynamodb_table = var.terraform_dynamodb_table == null ?"${data.aws_caller_identity.current.account_id}-terraform" : var.terraform_dynamodb_table
}

data "aws_iam_policy_document" "terraform" {
  statement {
    sid = "AllowBucketList"
    effect = "Allow"
    actions = ["s3:ListAllMyBuckets", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    sid = "AllowListBucket"
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.terraform_s3_bucket}"]
  }
  statement {
    sid = "AllowPath"
    effect = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListObjects"]
    resources = ["arn:aws:s3:::${local.terraform_s3_bucket}/${var.terraform_s3_prefix}/*"]
  }
  statement {
    sid = "AllowWorkspacePath"
    effect = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListObjects"]
    resources = ["arn:aws:s3:::${local.terraform_s3_bucket}/env:/*/${var.terraform_s3_prefix}/*"]
  }
  statement {
    sid = "AllowDynamo"
    effect = "Allow"
    actions = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem"]
    resources = ["arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${local.terraform_dynamodb_table}"]
  }
}

resource "aws_iam_policy" "terraform" {
  count = var.create_role && var.create_terraform_policy ? 1 : 0
  name = "${var.name}-terraform"
  description = "Allows access to terraform state and locks."
  policy = data.aws_iam_policy_document.terraform.json
  tags = merge(var.tags, var.terraform_policy_tags)
  path = var.path
}

resource "aws_iam_role_policy_attachment" "terraform" {
  count = var.create_role && var.create_terraform_policy ? 1 : 0
  policy_arn = aws_iam_policy.terraform[count.index].arn
  role = module.bitbucket_service_provisioner.iam_role_name
}

#------------------------------------------------------------------------------
# Additional Policies
#------------------------------------------------------------------------------
resource "aws_iam_policy" "provisioner_n" {
  count = length(var.policies)
  name = "${var.name}-${count.index}"
  path = var.path
  description = "Access policy for IAM role ${var.name}"
  policy = var.policies[count.index]
}

resource "aws_iam_role_policy_attachment" "provisioner_n" {
  count = length(var.policies)
  policy_arn = aws_iam_policy.provisioner_n[count.index].arn
  role = module.bitbucket_service_provisioner.iam_role_name
}
