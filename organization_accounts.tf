locals {
  accounts = local.config.accounts == null ? [] : local.config.accounts

  customized_accounts = [
    for account in local.accounts : {
      name  = account.name,
      email = account.email,

      parent_id   = try(account.parent_id, null),
      parent_path = try(account.parent_path, null),

      # if parent_key exist and it is not null, then parent_key has a corrent value, if it is "" then parent_key is "" (it is root ou), if not, replace / to undescore to create valid key
      # if parent_key not exist then use parent_id if exist, if not use "" (root ou)
      parent_key = try(account.parent_path, null) != null ? (account.parent_path == "" ? "" : try(lower(replace(account.parent_path, "/", "_")), lower(account.parent_path), "")) : try(account.parent_id, ""),

      role_name                  = try(account.role_name, null),
      close_on_deletion          = try(account.close_on_deletion, null),
      create_govcloud            = try(account.create_govcloud, null),
      iam_user_access_to_billing = try(account.iam_user_access_to_billing, null) != null ? account.iam_user_access_to_billing : "ALLOW",
      policies                   = try(account.policies, null) != null ? account.policies : []
    }
  ]

  accounts_with_parrent_id_and_key = [
    for account in local.customized_accounts : {
      # generate account key by joining internal parent key and account name, it would be unique in hierarchy structure 
      # because of that, we can create two accounts with same name, in two different organization unit
      key                        = account.parent_key != "" ? lower(join("_", [account.parent_key, account.name])) : try(replace(lower(account.name), " ", "_"), lower(account.name)),
      name                       = account.name,
      email                      = account.email,
      parent_id                  = account.parent_id,
      parent_path                = account.parent_path,
      close_on_deletion          = account.close_on_deletion,
      create_govcloud            = account.create_govcloud,
      iam_user_access_to_billing = account.iam_user_access_to_billing,
      role_name                  = account.role_name,
      policies                   = account.policies,
    }
  ]
}

resource "aws_organizations_account" "account" {
  for_each = { for account in local.accounts_with_parrent_id_and_key : account.key => account }

  name  = each.value.name
  email = each.value.email

  # Generating logic for parent_id:
  # if parent_id is defined and isn't "" use parent_id 
  # if parent_id is defined and it is "", search for root: data.aws_organizations_organization.organization.roots[0].id
  # if parent_id is null, search for parent_path in organization units output (parent_path is key of internal key)
  # we use length function to avoid if we don't find any unit, in which case they will set in the root unit (it can happen when the input_mode flag is set to true)
  parent_id = try(each.value.parent_id, null) != null ? (each.value.parent_id == "" ? data.aws_organizations_organization.organization.roots[0].id : each.value.parent_id) : length([for ou in local.all_ou_outputs : ou.id if ou.key == try(lower(replace(each.value.parent_path, "/", "_")))]) != 0 ? [for ou in local.all_ou_outputs : ou.id if ou.key == try(lower(replace(each.value.parent_path, "/", "_")))][0] : data.aws_organizations_organization.organization.roots[0].id

  close_on_deletion          = each.value.close_on_deletion
  create_govcloud            = each.value.create_govcloud
  iam_user_access_to_billing = each.value.iam_user_access_to_billing
  role_name                  = each.value.role_name

  # There is no AWS Organizations API for reading role_name
  # Iam_user_access_to_billing - If the resource is created and this option is changed, it will try to recreate the account.
  lifecycle {
    ignore_changes = [role_name, iam_user_access_to_billing]
  }

  depends_on = [
    aws_organizations_organizational_unit.level_1_ous,
    aws_organizations_organizational_unit.level_2_ous,
    aws_organizations_organizational_unit.level_3_ous,
    aws_organizations_organizational_unit.level_4_ous,
    aws_organizations_organizational_unit.level_5_ous,
  ]
}

locals {
  # import_mode on true will set an empty output, because it is not possible to access: aws_organizations_account.account resource during import 
  account_outputs = local.config.import_mode ? [] : [
    for account in local.accounts_with_parrent_id_and_key :
    {
      id        = aws_organizations_account.account[account.key].id,
      arn       = aws_organizations_account.account[account.key].arn,
      name      = account.name
      email     = account.email
      parent_id = try(account.parent_id, null) != null ? (account.parent_id == "" ? data.aws_organizations_organization.organization.roots[0].id : account.parent_id) : [for ou in local.all_ou_outputs : ou.id if ou.key == try(lower(replace(account.parent_path, "/", "_")), lower(account.parent_path), "")][0]
      policies  = account.policies
    }
  ]
}
