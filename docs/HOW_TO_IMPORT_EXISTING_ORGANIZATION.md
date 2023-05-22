## Guide: How to import existing AWS Organization

To start importing, please pay attention on current structure of your AWS Organization. Related to that, create input variables based on your AWS Organiaztion. 

In case of example, we will assume that our AWS organization has 3 units, and 3 accounts in them without policies, and one account in root unit. So, we will create inputs based on it

Example of module inputs (we assume that you have set up the backend and the provider well, and that you have your credentials set):

```terraform
module "aws_organization" {
  source = "https://github.com/cyberlabrs/terraform-aws-organization.git"

  feature_set                   = "ALL"
  aws_service_access_principals = []
  enabled_policy_types          = []

  organizational_units= [
    {
      name : "SharedOU", 
      policies : [],
      children : []
    },
    {
      name : "DevOU",
      policies : [],
      children : []
    },
    {
      name : "ProdOU",
      policies : [],
      children : []
    }
  ]

  accounts = [
    {
      name : "dev",
      email : "example+dev@example.com",
      parent_path : "DevOU"
    },
    {
      name : "prod",
      email : "example+prod@example.com",
      parent_path : "ProdOU",
    },
    {
      name : "shared",
      email : "example+shared@example.com",
      parent_path : "SharedOU"
    },
    {
      name : "management_account",
      email : "example@example.com",
      parent_id : "" # that means, it is in root unit
    }
  ]

  import_mode = true
```

**WARNING:** In order to start importing, you must set the **import_mode** variable to true. After you finish importing, you can clear that variable or set it to false.

**Importing must be in following order**:
- AWS Organization resource 
- AWS Organizational Unit resources 
- AWS Organization Account resources 
- AWS Organization Policy resources
- AWS Organization Policy Attachment resources 

Before start importing, you need to type the following two commands:
```terraform
terraform init - to initialize backend, providers and module
terraform plan - to plan resources you want to create (import)
```

You should get a plan showing 8 resources to add, 0 to modify and 0 to destroy. (For a different AWS organization structure, the number of resources will also be different, but the logic is the same)

First, we need to import AWS Organization with command: 
```terraform
terraform import module.aws_organization.aws_organizations_organization.organization [ORGANIZATION_ID]
```
You should look at the organization id from the AWS Console

After that, you need to import organization units, from the plan it is best to see what the resource is called, for the values from the example above it will be: module.aws_organization.aws_organizations_organizational_unit.level_1_ous[**KEY**]

For example:
```terraform
terraform import module.aws_organization.aws_organizations_organizational_unit.level_1_ous[\"dev\"] [DEV_UNIT_ID] - make sure you escape the string which represent key, in this case \"dev\"

terraform import module.aws_organization.aws_organizations_organizational_unit.level_1_ous[\"shared\"] [SHARED_UNIT_ID]

terraform import module.aws_organization.aws_organizations_organizational_unit.level_1_ous[\"prod\"] [PROD_UNIT_ID]
```

After you have imported the units, next up are the accounts, similar to units, you see the exact name of the resource from the plan

In our example: 
```terraform
terraform import module.aws_organization.aws_organizations_account.account[\"management_account\"] [MANAGEMENT_ACCOUNT_ID]

terraform import module.aws_organization.aws_organizations_account.account[\"shared_shared\"] [SHARED_ACCOUNT_ID]

terraform import module.aws_organization.aws_organizations_account.account[\"dev_dev\"] [DEV_ACCOUNT_ID]

terraform import module.aws_organization.aws_organizations_account.account[\"prod_prod\"] [PROD_ACCOUNT_ID]
```

After we have imported the accounts, we need to change variable **import_mode** to false, or delete them. 

Then you can validate that everything is consistent with your input by running the command:
```terraform
terraform plan
```

If we get message: No changes. Your infrastructure matches the configuration. everything went corretly, if there are certain changes, add or destroying, something was wrong. It might just be some inconsistency with the variables, for example a different email address, or the close_on_deletion flag being set is missing. In that case, modify your input to match the configuration. 

# Warning

Working with organization and accounts can be sensitive, you do everything at your own risk. Until you run the *terraform apply* the state won't be changed, so pay attention to what the planning shows you.