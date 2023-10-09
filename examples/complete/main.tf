#provider "aws" {}

module "aws_organization" {
  source = "../.."

  # commented because variables.yaml exists
  # # aws organization
  # feature_set                   = "ALL"
  # aws_service_access_principals = ["sso.amazonaws.com"]
  # enabled_policy_types          = ["SERVICE_CONTROL_POLICY"]

  # # root policies
  # root_unit_policies = ["region_control"]

  # # policies
  # policies = [
  #   {
  #     name : "region_control",
  #     template_file : "./policies/scps/scp_region_lock.json",
  #   },
  #   {
  #     name : "deny_all",
  #     template_file : "./policies/scps/deny_all.json",
  #   }
  # ]

  # # organizational units
  # organizational_units = [
  #   {
  #     name : "CoreOU",
  #     policies : [],
  #     children : [
  #       {
  #         name : "DevelopmentOU",
  #         policies : ["dev_control_access"],
  #         children : []
  #       },
  #       {
  #         name : "StageOU",
  #         policies : [],
  #         children : []
  #       },
  #       {
  #         name : "ProductionOU",
  #         policies : [],
  #         children : []
  #       }
  #     ]
  #   },
  #   {
  #     name : "SandboxOU",
  #     policies : ["deny_all"],
  #     children : []
  #   }
  # ]

  # # accounts
  # // we can define parent unit on two ways
  # // the first one is by exactly parent_id which is unit ID or Root ID for the account
  # // the second way is to define parent_path, this means that we will define a node in the hierarchical structure through path
  # // example1: parent_path="CoreOU/DevelopmentOU" to put account in DevelopmentOU which is placed in CoreOU
  # // example2: parent_path="" or parent_id="" that means in root unit
  # accounts = [
  #   {
  #     name : "ExampleOfAccountInRootOnit",
  #     email : "test+root@test.com",
  #     parent_id : ""
  #   },
  #   # {
  #   #   name : "AccountBYID",
  #   #   email : "test+dev@test.com",
  #   #   parent_id : "B1234323" # specified by concrete id, you need to know the ID of your OU or root account, this value is example only
  #   # },
  #   {
  #     name : "Development",
  #     email : "test+dev@test.com",
  #     parent_path : "CoreOU/DevelopmentOU"
  #   },
  #   {
  #     name : "Stage",
  #     email : "test+stage@test.com",
  #     parent_path : "CoreOU/StageOU",
  #     policies : ["deny_all"]
  #   },
  #   {
  #     name : "Pruduction",
  #     email : "test+shared@test.com",
  #     parent_path : "CoreOU/ProductionOU"
  #   },
  #   {
  #     name : "Shared",
  #     email : "test+shared@test.com",
  #     parent_path : "CoreOU"
  #   },
  #   {
  #     name : "Sandbox01",
  #     email : "test+sandbox01@test.com",
  #     parent_path : "SandboxOU"
  #   },
  #   {
  #     name : "Sandbox02",
  #     email : "test+sandbox01@test.com",
  #     parent_path : "SandboxOU"
  #   },
  #   {
  #     name : "Sandbox03",
  #     email : "test+sandbox01@test.com",
  #     parent_path : "SandboxOU"
  #   }
  # ]
}
