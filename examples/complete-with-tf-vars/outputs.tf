output "organization_id" {
  description = "Identifier of the organization"
  value       = module.aws_organization.organization_id
}

output "organization_arn" {
  description = "ARN of the organization"
  value       = module.aws_organization.organization_arn
}

output "organizational_units" {
  description = "List of organization units which contain the root unit"
  value       = module.aws_organization.organizational_units
}

output "accounts" {
  description = "List of accounts"
  value       = module.aws_organization.accounts
}

output "policies" {
  description = "List of policies"
  value       = module.aws_organization.policies
}
