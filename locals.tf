locals {
  load_from_yaml = var.config_path != "" && fileexists("${path.module}/${var.config_path}") ? true : false
  config = local.load_from_yaml ? {
    import_mode = yamldecode(file(var.config_path))["import_mode"]
    feature_set = yamldecode(file(var.config_path))["feature_set"]
    enabled_policy_types = tolist(yamldecode(file(var.config_path))["enabled_policy_types"])
    aws_service_access_principals = tolist(yamldecode(file(var.config_path))["aws_service_access_principals"])
    organizational_units = yamldecode(file(var.config_path))["organizational_units"]
    accounts = tolist([ for a in yamldecode(file(var.config_path))["accounts"] : {
      name                       = a.name,
      email                      = a.email,
      parent_id                  = try(a.parent_id, null)
      parent_path                = try(a.parent_path, null)
      role_name                  = try(a.role_name, null)
      close_on_deletion          = try(a.close_on_deletion, null)
      create_govcloud            = try(a.create_govcloud, null)
      iam_user_access_to_billing = try(a.iam_user_access_to_billing, null)
      policies                   = tolist(try(a.policies, null))
    } ])
    policies = tolist(yamldecode(file(var.config_path))["policies"])
    root_unit_policies = tolist(yamldecode(file(var.config_path))["root_unit_policies"])
  } : {
    import_mode = var.import_mode
    feature_set = var.feature_set
    enabled_policy_types = var.enabled_policy_types
    aws_service_access_principals = var.aws_service_access_principals
    organizational_units = var.organizational_units
    accounts = var.accounts
    policies = var.policies
    root_unit_policies = var.root_unit_policies
  }
}