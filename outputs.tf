################################################################################
# AWS Orgnization Outputs
################################################################################

output "organization_id" {
  description = "Identifier of the organization"
  value       = aws_organizations_organization.organization.id
}

output "organization_arn" {
  description = "ARN of the organization"
  value       = aws_organizations_organization.organization.arn
}

################################################################################
# AWS Organizational Units Outputs
################################################################################

output "organizational_units" {
  description = "List of organization units which contain the root unit"
  value       = local.organizational_unit_outputs
}

################################################################################
# AWS Organization Accounts Outputs
################################################################################

output "accounts" {
  description = "List of accounts"
  value       = local.account_outputs
}

################################################################################
# AWS Organization Policies Outputs
################################################################################

output "policies" {
  description = "List of policies"
  value       = local.policies_outputs
}
