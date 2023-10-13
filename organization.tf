resource "aws_organizations_organization" "organization" {
  feature_set                   = local.config.feature_set
  enabled_policy_types          = local.config.enabled_policy_types
  aws_service_access_principals = local.config.aws_service_access_principals

  lifecycle {
    prevent_destroy = true
  }
}
