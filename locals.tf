locals {
  config_folder = "conf"
  general_path = "${local.config_folder}/general.yaml"
  aws_organization_path = "${local.config_folder}/aws_organization.yaml"
  root_policies_path = "${local.config_folder}/root_policies.yaml"
  policies_path = "${local.config_folder}/policies.yaml"
  organizational_units_path = "${local.config_folder}/organizational_units.yaml"
  accounts_path = "${local.config_folder}/accounts.yaml"

  config = {
    import_mode                   = try(yamldecode(file(local.general_path))["import_mode"], var.import_mode)
    feature_set                   = try(yamldecode(file(local.aws_organization_path))["feature_set"], var.feature_set)
    enabled_policy_types          = tolist(try(yamldecode(file(local.aws_organization_path))["enabled_policy_types"], var.enabled_policy_types))
    aws_service_access_principals = tolist(try(yamldecode(file(local.aws_organization_path))["aws_service_access_principals"], var.aws_service_access_principals))
    organizational_units          = try(yamldecode(file(local.organizational_units_path)["organizational_units"]), var.organizational_units)
    accounts = tolist([for a in try(yamldecode(file(local.accounts_path))["accounts"], var.accounts) : {
      name                       = a.name,
      email                      = a.email,
      parent_id                  = try(a.parent_id, null)
      parent_path                = try(a.parent_path, null)
      role_name                  = try(a.role_name, null)
      close_on_deletion          = try(a.close_on_deletion, null)
      create_govcloud            = try(a.create_govcloud, null)
      iam_user_access_to_billing = try(a.iam_user_access_to_billing, null)
      policies                   = tolist(try(a.policies, null))
    }])
    policies = tolist([for p in try(yamldecode(file(local.policies_path))["policies"], var.policies) : {
      name          = p.name
      template_file = p.template_file
      type          = try(p.type, null)
      skip_destroy  = try(p.skip_destroy, null)
      description   = try(p.description, null)
    }])
    root_unit_policies = tolist(try(yamldecode(file(local.root_policies_path)["root_unit_policies"]), var.root_unit_policies))
  }
}