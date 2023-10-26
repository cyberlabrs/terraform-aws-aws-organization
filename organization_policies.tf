locals {
  policies = local.config.policies == null ? [] : local.config.policies

  customized_policies = [
    for policy in local.policies : {
      name          = policy.name
      template_file = policy.template_file

      description  = try(policy.description, null)
      skip_destroy = try(policy.skip_destroy, null)
      type         = try(policy.type, null) != null ? policy.type : "SERVICE_CONTROL_POLICY"
    }
  ]
}

resource "aws_organizations_policy" "all" {
  for_each = { for policy in local.customized_policies : policy.name => policy }

  name    = each.value.name
  content = file(each.value.template_file)

  description  = each.value.description
  skip_destroy = each.value.skip_destroy
  type         = each.value.type
}

locals {
  # import_mode on true will set an empty output, because it is not possible to access: aws_organizations_policy.all resource during import 
  policies_outputs = local.config.import_mode ? [] : [
    for policy in local.customized_policies : {
      id   = aws_organizations_policy.all[policy.name].id,
      arn  = aws_organizations_policy.all[policy.name].arn,
      name = policy.name
      type = policy.type
    }
  ]
}
