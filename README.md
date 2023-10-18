<!-- BEGIN_TF_DOCS -->
# AWS Organization terraform module

## Usage

In this example we create 2 SCP policies: _dev_control_access_ and _deny_all_, use json policy from folder: `policies/scps/`

```terraform
module "aws_organization" {
  source  = "cyberlabrs/aws-organization/aws"
  version = "1.0.0"

  feature_set                   = "ALL"
  aws_service_access_principals = ["sso.amazonaws.com"]
  enabled_policy_types          = ["SERVICE_CONTROL_POLICY"]

  policies = [
    {
      name : "dev_control_access",
      template_file : "./policies/scps/dev_control_access.json",
    },
    {
      name : "deny_all",
      template_file : "./policies/scps/deny_all.json",
    }
  ]

  organizational_units = [
    {
      name : "CoreOU",
      policies : [],
      children : [
        {
          name : "DevelopmentOU",
          policies : ["dev_control_access"],
          children : []
        },
        {
          name : "StageOU",
          policies : [],
          children : []
        },
        {
          name : "ProductionOU",
          policies : [],
          children : []
        }
      ]
    },
    {
      name : "SandboxOU",
      policies : [],
      children : []
    }
  ]

  accounts = [
    {
      name : "AccountInRootOU",
      email : "test+root@test.com",
      parent_id : "",
      policies : ["deny_all"]
    },
    {
      name : "Development",
      email : "test+dev@test.com",
      parent_path : "CoreOU/DevelopmentOU"
    },
    {
      name : "Stage",
      email : "test+stage@test.com",
      parent_path : "CoreOU/StageOU",
    },
    {
      name : "Pruduction",
      email : "test+shared@test.com",
      parent_path : "CoreOU/ProductionOU"
    }
  ]
}
```

## Examples

- [Complete AWS Organization using yaml config files](examples/complete-with-yaml)
- [Complete AWS Organization using Terraform variables](examples/complete-with-tf-vars)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.60 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.60 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.level_1_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_2_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_3_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_4_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_5_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_policy.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.unit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_organization.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | The list of accounts | <pre>list(object({<br>    name                       = string,<br>    email                      = string,<br>    parent_id                  = optional(string)<br>    parent_path                = optional(string)<br>    role_name                  = optional(string)<br>    close_on_deletion          = optional(string)<br>    create_govcloud            = optional(string)<br>    iam_user_access_to_billing = optional(string)<br>    policies                   = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_aws_service_access_principals"></a> [aws\_service\_access\_principals](#input\_aws\_service\_access\_principals) | A list of AWS service principals for which you want to enable integration with your organization. | `list(string)` | `[]` | no |
| <a name="input_enabled_policy_types"></a> [enabled\_policy\_types](#input\_enabled\_policy\_types) | List of organization policy types to enable in the organization. Organization must have feature\_set set to ALL. Valid policy types: AISERVICES\_OPT\_OUT\_POLICY, BACKUP\_POLICY, SERVICE\_CONTROL\_POLICY, and TAG\_POLICY | `list(string)` | `[]` | no |
| <a name="input_feature_set"></a> [feature\_set](#input\_feature\_set) | The feature set of the organization. One of 'ALL' or 'CONSOLIDATED\_BILLING'. (default: ALL) | `string` | `"ALL"` | no |
| <a name="input_import_mode"></a> [import\_mode](#input\_import\_mode) | Whether import mode is active, if true, resources can be imported smoothly (In that case, it is not possible to create resources safely, because outputs won't have valid outputs and all resources will be created in the root unit) WARNING: use import\_mode only in case when you want to import resources, after importing, set import\_mode to false or remove it | `bool` | `false` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | The tree of organizational units to construct. Defaults to an empty tree. You must take care of the list format, which is explained in the Readme | `any` | `[]` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | The list of policies | <pre>list(object({<br>    name          = string,<br>    template_file = string,<br>    type          = optional(string)<br>    skip_destroy  = optional(bool)<br>    description   = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_root_unit_policies"></a> [root\_unit\_policies](#input\_root\_unit\_policies) | The list of policies for root unit | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_accounts"></a> [accounts](#output\_accounts) | List of accounts |
| <a name="output_configuration"></a> [configuration](#output\_configuration) | Configuration |
| <a name="output_organization_arn"></a> [organization\_arn](#output\_organization\_arn) | ARN of the organization |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | Identifier of the organization |
| <a name="output_organizational_units"></a> [organizational\_units](#output\_organizational\_units) | List of organization units which contain the root unit |
| <a name="output_policies"></a> [policies](#output\_policies) | List of policies |

## Authors

Module is maintained by [Nikola Kolovic](https://github.com/nikolakolovic) with help from [CyberLab Team](https://github.com/cyberlabrs).

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->