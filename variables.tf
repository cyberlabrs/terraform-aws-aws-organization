################################################################################
# General
################################################################################
variable "import_mode" {
  description = "Whether import mode is active, if true, resources can be imported smoothly (In that case, it is not possible to create resources safely, because outputs won't have valid outputs and all resources will be created in the root unit) WARNING: use import_mode only in case when you want to import resources, after importing, set import_mode to false or remove it "
  type        = bool
  default     = false
}

################################################################################
# AWS Organization
################################################################################

variable "feature_set" {
  description = "The feature set of the organization. One of 'ALL' or 'CONSOLIDATED_BILLING'. (default: ALL)"
  type        = string
  nullable    = false
  validation {
    condition = (
      anytrue([
        var.feature_set == "ALL",
        var.feature_set == "CONSOLIDATED_BILLING"
      ])
    )
    error_message = "Feature set must contain one of the following values: 'ALL' or 'CONSOLIDATED_BILLING'"
  }
  default = "ALL"
}

variable "enabled_policy_types" {
  description = "List of organization policy types to enable in the organization. Organization must have feature_set set to ALL. Valid policy types: AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY, SERVICE_CONTROL_POLICY, and TAG_POLICY"
  type        = list(string)
  nullable    = false
  validation {
    condition = alltrue([
      for policy in var.enabled_policy_types : contains(["AISERVICES_OPT_OUT_POLICY", "BACKUP_POLICY", "SERVICE_CONTROL_POLICY", "TAG_POLICY"], policy)
    ])
    error_message = "List of organization policy types must contain some of the following values: AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY, SERVICE_CONTROL_POLICY, and TAG_POLICY"
  }
  default = []
}

variable "aws_service_access_principals" {
  description = "A list of AWS service principals for which you want to enable integration with your organization."
  type        = list(string)
  nullable    = false
  default     = []
}

################################################################################
# AWS Orgnizational Units
################################################################################

variable "organizational_units" {
  type        = any
  description = "The tree of organizational units to construct. Defaults to an empty tree. You must take care of the list format, which is explained in the Readme"
  validation {
    condition = (
      alltrue(
        [for level_1_ou in var.organizational_units : ( # validate level 1 
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
  default = []
}

################################################################################
# AWS Organization Accounts
################################################################################

variable "accounts" {
  description = "The list of accounts"
  type = list(object({
    name                       = string,
    email                      = string,
    parent_id                  = optional(string)
    parent_path                = optional(string)
    role_name                  = optional(string)
    close_on_deletion          = optional(string)
    create_govcloud            = optional(string)
    iam_user_access_to_billing = optional(string)
    policies                   = optional(list(string))
  }))
  validation {
    condition = (
      alltrue(
        [for account in var.accounts : (
          (account.name != "" && account.name != null && length(account.name) > 2) &&
          (account.email != "" && account.email != null) &&
          (try(account.parent_id, null) != null || try(account.parent_path, null) != null)
      )])
    )
    error_message = "Account must be in format:\n{\n \"name\": string - more than 2 characters\n \"email\": string \n \"parent_id or parent_path\": string\n}\nIf we set parent_id to \"\" or parent_path to \"\" it will place account to root unit"
  }
  default = []
}

################################################################################
# AWS Organization Policies
################################################################################
variable "policies" {
  description = "The list of policies"
  type = list(object({
    name          = string,
    template_file = string,
    type          = optional(string)
    skip_destroy  = optional(bool)
    description   = optional(string)
  }))
  validation {
    condition = (
      alltrue(
        [for policy in var.policies : (
          (policy.name != null && length(policy.name) > 2) &&
          (policy.template_file != "" && policy.template_file != null) &&
          (try(policy.type, null) != null ? contains(["AISERVICES_OPT_OUT_POLICY", "BACKUP_POLICY", "SERVICE_CONTROL_POLICY", "TAG_POLICY"], policy.type) : true)
      )])
    )
    error_message = "Policies must be a list of object: \n{ \n\"name\": string - more than 2 characters,\n\"template_file\": string - not empty and not null\n\"type\": string(default: SERVICE_CONTROL_POLICY) - must be one of the following values: AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY, SERVICE_CONTROL_POLICY, and TAG_POLICY\n}\n\nAnd optionally: skip_destroy and description"
  }
  default = []
}

variable "root_unit_policies" {
  description = "The list of policies for root unit"
  type        = list(string)
  default     = []
}
