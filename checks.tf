check "feature_set" {
  assert {
    condition = (
      anytrue([
        local.config.feature_set == "ALL",
        local.config.feature_set == "CONSOLIDATED_BILLING"
      ])
    )
    error_message = "Feature set must contain one of the following values: 'ALL' or 'CONSOLIDATED_BILLING'"
  }
}

check "enabled_policy_types" {
  assert {
    condition = alltrue([
      for policy in local.config.enabled_policy_types : contains(["AISERVICES_OPT_OUT_POLICY", "BACKUP_POLICY", "SERVICE_CONTROL_POLICY", "TAG_POLICY"], policy)
    ])
    error_message = "List of organization policy types must contain some of the following values: AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY, SERVICE_CONTROL_POLICY, and TAG_POLICY"
  }
}

check "organizational_units" {
  assert {
    condition = (
      alltrue(
        [for level_1_ou in local.config.organizational_units : ( # validate level 1 
          (length(level_1_ou.name) > 2 && (length(level_1_ou.children) == 0 ||
            length(level_1_ou.children) != 0 &&
            alltrue([
              for level_2_ou in level_1_ou.children : ( # validate level 2
                (length(level_2_ou.name) > 2 && (length(level_2_ou.children) == 0 ||
                  length(level_2_ou.children) != 0 &&
                  alltrue([
                    for level_3_ou in level_2_ou.children : ( # validate level 3 
                      (length(level_3_ou.name) > 2 && (length(level_3_ou.children) == 0 ||
                        length(level_3_ou.children) != 0 &&
                        alltrue([
                          for level_4_ou in level_3_ou.children : ( # validate level 4 
                            (length(level_4_ou.name) > 2) && (length(level_4_ou.children) == 0 ||
                              length(level_4_ou.children) != 0 &&
                              alltrue([
                                for level_5_ou in level_4_ou.children : ( # validate level 5
                                  length(level_5_ou.name) > 2
                                )
                          ])))
                      ])))
                )])))
          )])))
      )])
    )
    error_message = "The tree must be in the following form: \n\nOrganizational_units MUST be array of object \n{\n \"name\": string\n \"policies\": array(string)\n \"children\": array(object) \n}\n\nConstrains: Children optionally can be empty array or an array with the same structure with name, children, and policies\nSo on to level 5 in depth, where children at level 4 can be an empty array or an array of objects that only have a name, and policies, because they musn't have children\nName must be more than 2 characters"
  }
}

check "accounts" {
  assert {
    condition = (
      alltrue(
        [for account in local.config.accounts : (
          (account.name != "" && account.name != null && length(account.name) > 2) &&
          (account.email != "" && account.email != null) &&
          (try(account.parent_id, null) != null || try(account.parent_path, null) != null)
      )])
    )
    error_message = "Account must be in format:\n{\n \"name\": string - more than 2 characters\n \"email\": string \n \"parent_id or parent_path\": string\n}\nIf we set parent_id to \"\" or parent_path to \"\" it will place account to root unit"
  }
}

check "policies" {
  assert {
    condition = (
      alltrue(
        [for policy in local.config.policies : (
          (policy.name != null && length(policy.name) > 2) &&
          (policy.template_file != "" && policy.template_file != null) &&
          (try(policy.type, null) != null ? contains(["AISERVICES_OPT_OUT_POLICY", "BACKUP_POLICY", "SERVICE_CONTROL_POLICY", "TAG_POLICY"], policy.type) : true)
      )])
    )
    error_message = "Policies must be a list of object: \n{ \n\"name\": string - more than 2 characters,\n\"template_file\": string - not empty and not null\n\"type\": string(default: SERVICE_CONTROL_POLICY) - must be one of the following values: AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY, SERVICE_CONTROL_POLICY, and TAG_POLICY\n}\n\nAnd optionally: skip_destroy and description"
  }
}
