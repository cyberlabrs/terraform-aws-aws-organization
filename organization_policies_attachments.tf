locals {
  accounts_with_policies = [for account in local.accounts_with_parrent_id_and_key : account if length(account.policies) > 0]

  policy_account_attachments = flatten([
    for policy in local.customized_policies :
    [for account in local.accounts_with_policies :
      ({
        key : join("_", [policy.name, account.key]),
        account_key : account.key,
        policy_key : policy.name
      }) if contains(account.policies, policy.name)
    ]
  ])

  organizational_units_with_policies = [for ou in local.all_organizational_units_arguments : ou if length(ou.policies) > 0]

  policy_organizational_unit_attachments = flatten([
    for policy in local.customized_policies :
    [for ou in local.organizational_units_with_policies :
      ({
        key : join("_", [policy.name, ou.key])
        ou_key : ou.key,
        policy_key : policy.name
      }) if contains(ou.policies, policy.name)
    ]
  ])
}

resource "aws_organizations_policy_attachment" "root" {
  for_each = toset(local.config.root_unit_policies)

  policy_id = aws_organizations_policy.all[each.key].id
  target_id = data.aws_organizations_organization.organization.roots[0].id
}

resource "aws_organizations_policy_attachment" "accounts" {
  for_each = { for policy_account in local.policy_account_attachments : policy_account.key => policy_account }

  policy_id = aws_organizations_policy.all[each.value.policy_key].id
  target_id = aws_organizations_account.account[each.value.account_key].id

  depends_on = [
    aws_organizations_account.account
  ]
}

resource "aws_organizations_policy_attachment" "unit" {
  for_each = { for policy_unit in local.policy_organizational_unit_attachments : policy_unit.key => policy_unit }

  policy_id = aws_organizations_policy.all[each.value.policy_key].id
  target_id = [for ou in local.all_ou_outputs : ou.id if lower(ou.key) == each.value.ou_key][0]

  depends_on = [
    aws_organizations_organizational_unit.level_1_ous,
    aws_organizations_organizational_unit.level_2_ous,
    aws_organizations_organizational_unit.level_3_ous,
    aws_organizations_organizational_unit.level_4_ous,
    aws_organizations_organizational_unit.level_5_ous,
  ]
}
