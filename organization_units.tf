locals {
  organizational_units = local.config.organizational_units == null ? [] : local.config.organizational_units

  level_1_ou_arguments = [
    for ou in local.organizational_units : {
      name : ou.name,
      parent : "",
      key : lower(ou.name),
      policies = try(ou.policies, null) != null ? ou.policies : []
    }
  ]

  level_2_ou_arguments = flatten([
    for level_1_ou in local.organizational_units :
    [for level_2_ou in level_1_ou.children :
      {
        name : level_2_ou.name,
        parent : lower(level_1_ou.name),
        key : join("_", [lower(level_1_ou.name), lower(level_2_ou.name)]),
        policies = try(level_2_ou.policies, null) != null ? level_2_ou.policies : []
      }
    ]
  ])

  level_3_ou_arguments = flatten([
    for level_1_ou in local.organizational_units :
    [for level_2_ou in level_1_ou.children :
      [for level_3_ou in level_2_ou.children :
        {
          name : level_3_ou.name,
          parent : join("_", [lower(level_1_ou.name), lower(level_2_ou.name)]),
          key : join("_", [lower(level_1_ou.name), lower(level_2_ou.name), lower(level_3_ou.name)]),
          policies = try(level_3_ou.policies, null) != null ? level_3_ou.policies : []
        }
      ]
    ]
  ])

  level_4_ou_arguments = flatten([
    for level_1_ou in local.organizational_units :
    [for level_2_ou in level_1_ou.children :
      [for level_3_ou in level_2_ou.children :
        [for level_4_ou in level_3_ou.children :
          {
            name : level_4_ou.name,
            parent : join("_", [lower(level_1_ou.name), lower(level_2_ou.name), lower(level_3_ou.name)]),
            key : join("_", [lower(level_1_ou.name), lower(level_2_ou.name), lower(level_3_ou.name), lower(level_4_ou.name)]),
            policies = try(level_4_ou.policies, null) != null ? level_4_ou.policies : []
          }
        ]
      ]
    ]
  ])

  level_5_ou_arguments = flatten([
    for level_1_ou in local.organizational_units :
    [for level_2_ou in level_1_ou.children :
      [for level_3_ou in level_2_ou.children :
        [for level_4_ou in level_3_ou.children :
          [for level_5_ou in level_4_ou.children :
            {
              name : level_5_ou.name,
              parent : join("_", [lower(level_1_ou.name), lower(level_2_ou.name), lower(level_3_ou.name), lower(level_4_ou.name)]),
              key : join("_", [lower(level_1_ou.name), lower(level_2_ou.name), lower(level_3_ou.name), lower(level_4_ou.name), lower(level_5_ou.name)])
              policies = try(level_5_ou.policies, null) != null ? level_5_ou.policies : []
            }
          ]
        ]
      ]
    ]
  ])

  all_organizational_units_arguments = concat(
    local.level_1_ou_arguments,
    local.level_2_ou_arguments,
    local.level_3_ou_arguments,
    local.level_4_ou_arguments,
    local.level_5_ou_arguments
  )
}

data "aws_organizations_organization" "organization" {}

resource "aws_organizations_organizational_unit" "level_1_ous" {
  for_each = { for ou in local.level_1_ou_arguments : ou.key => ou }

  name      = each.value.name
  parent_id = data.aws_organizations_organization.organization.roots[0].id
}

resource "aws_organizations_organizational_unit" "level_2_ous" {
  for_each = { for ou in local.level_2_ou_arguments : ou.key => ou }

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.level_1_ous[each.value.parent].id
}

resource "aws_organizations_organizational_unit" "level_3_ous" {
  for_each = { for ou in local.level_3_ou_arguments : ou.key => ou }

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.level_2_ous[each.value.parent].id
}

resource "aws_organizations_organizational_unit" "level_4_ous" {
  for_each = { for ou in local.level_4_ou_arguments : ou.key => ou }

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.level_3_ous[each.value.parent].id
}

resource "aws_organizations_organizational_unit" "level_5_ous" {
  for_each = { for ou in local.level_5_ou_arguments : ou.key => ou }

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.level_4_ous[each.value.parent].id
}

locals {
  # import_mode on true will set an empty output, because it is not possible to access: aws_organizations_organizational_unit.level_1_ous resource during import 
  level_1_ou_outputs = local.config.import_mode ? [] : [
    for ou in local.level_1_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_1_ous[ou.key].id,
      arn       = aws_organizations_organizational_unit.level_1_ous[ou.key].arn,
      parent_id = data.aws_organizations_organization.organization.roots[0].id
      name      = ou.name,
      key       = ou.key
    }
  ]

  level_2_ou_outputs = local.config.import_mode ? [] : [
    for ou in local.level_2_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_2_ous[ou.key].id,
      arn       = aws_organizations_organizational_unit.level_2_ous[ou.key].arn,
      parent_id = aws_organizations_organizational_unit.level_1_ous[ou.parent].id,
      name      = ou.name,
      key       = ou.key
    }
  ]

  level_3_ou_outputs = local.config.import_mode ? [] : [
    for ou in local.level_3_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_3_ous[ou.key].id,
      arn       = aws_organizations_organizational_unit.level_3_ous[ou.key].arn,
      parent_id = aws_organizations_organizational_unit.level_2_ous[ou.parent].id,
      name      = ou.name,
      key       = ou.key
    }
  ]

  level_4_ou_outputs = local.config.import_mode ? [] : [
    for ou in local.level_4_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_4_ous[ou.key].id,
      arn       = aws_organizations_organizational_unit.level_4_ous[ou.key].arn,
      parent_id = aws_organizations_organizational_unit.level_3_ous[ou.parent].id,
      name      = ou.name,
      key       = ou.key
    }
  ]

  level_5_ou_outputs = local.config.import_mode ? [] : [
    for ou in local.level_5_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_5_ous[ou.key].id,
      arn       = aws_organizations_organizational_unit.level_5_ous[ou.key].arn,
      parent_id = aws_organizations_organizational_unit.level_4_ous[ou.parent].id,
      name      = ou.name,
      key       = ou.key
    }
  ]

  all_ou_outputs = concat(
    local.level_1_ou_outputs,
    local.level_2_ou_outputs,
    local.level_3_ou_outputs,
    local.level_4_ou_outputs,
    local.level_5_ou_outputs,
    [{
      id        = data.aws_organizations_organization.organization.roots[0].id,
      arn       = data.aws_organizations_organization.organization.roots[0].arn,
      parent_id = "",
      name      = data.aws_organizations_organization.organization.roots[0].name,
      key       = ""
    }]
  )

  organizational_unit_outputs = [
    for ou in local.all_ou_outputs :
    {
      id        = ou.id,
      arn       = ou.arn,
      parent_id = ou.parent_id,
      name      = ou.name
    }
  ]
}
