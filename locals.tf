locals {
  # config folder
  config_folder = "conf"

  # config paths
  general_prepath = "${local.config_folder}/general"
  general_path    = fileexists("${local.general_prepath}.yaml") ? "${local.general_prepath}.yaml" : fileexists("${local.general_prepath}.yml") ? "${local.general_prepath}.yml" : ""

  aws_organization_prepath = "${local.config_folder}/aws_organization"
  aws_organization_path    = fileexists("${local.aws_organization_prepath}.yaml") ? "${local.aws_organization_prepath}.yaml" : fileexists("${local.aws_organization_prepath}.yml") ? "${local.aws_organization_prepath}.yml" : ""

  policies_prepath = "${local.config_folder}/policies"
  policies_path    = fileexists("${local.policies_prepath}.yaml") ? "${local.policies_prepath}.yaml" : fileexists("${local.policies_prepath}.yml") ? "${local.policies_prepath}.yml" : ""

  organizational_units_prepath = "${local.config_folder}/organizational_units"
  organizational_units_path    = fileexists("${local.organizational_units_prepath}.yaml") ? "${local.organizational_units_prepath}.yaml" : fileexists("${local.organizational_units_prepath}.yml") ? "${local.organizational_units_prepath}.yml" : ""

  accounts_prepath = "${local.config_folder}/accounts"
  accounts_path    = fileexists("${local.accounts_prepath}.yaml") ? "${local.accounts_prepath}.yaml" : fileexists("${local.accounts_prepath}.yml") ? "${local.accounts_prepath}.yml" : ""

  # import config settings
  config = {
    import_mode = try(
      yamldecode(file(local.general_path))["import_mode"],
      var.import_mode
    )
    feature_set = try(
      yamldecode(file(local.aws_organization_path))["feature_set"],
      var.feature_set
    )
    organizational_units = try(
      yamldecode(file(local.organizational_units_path))["organizational_units"],
      var.organizational_units
    )

    enabled_policy_types = tolist(try(
      yamldecode(file(local.aws_organization_path))["enabled_policy_types"],
      var.enabled_policy_types
    ))
    aws_service_access_principals = tolist(try(
      yamldecode(file(local.aws_organization_path))["aws_service_access_principals"],
      var.aws_service_access_principals
    ))
    root_unit_policies = tolist(try(
      yamldecode(file(local.aws_organization_path))["root_unit_policies"],
      var.root_unit_policies
    ))

    accounts = tolist([for a in try(
      yamldecode(file(local.accounts_path))["accounts"],
      var.accounts
      ) : {
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
    policies = tolist([for p in try(
      yamldecode(file(local.policies_path))["policies"],
      var.policies
      ) : {
      name          = p.name
      template_file = p.template_file
      type          = try(p.type, null)
      skip_destroy  = try(p.skip_destroy, null)
      description   = try(p.description, null)
    }])
  }
}
