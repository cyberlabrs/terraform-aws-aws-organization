locals {
  feature_set                   = var.feature_set
  enabled_policy_types          = var.enabled_policy_types
  aws_service_access_principals = var.aws_service_access_principals
}

resource "aws_organizations_organization" "organization" {
  feature_set                   = local.feature_set
  enabled_policy_types          = local.enabled_policy_types
  aws_service_access_principals = local.aws_service_access_principals

  lifecycle {
    prevent_destroy = true
  }
}
