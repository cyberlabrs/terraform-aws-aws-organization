# Guide: How to use yaml config files to set variables

To use multiple yaml config files instead of defining all variables in Terraform:

1. Create a folder named `conf` inside your module directory and relevant config files inside that folder. If you don't define some of the config files, Terraform variables will be used instead.

2. Create `accounts.yaml` or `accounts.yml`:

```yaml
# accounts
# we can define parent unit on two ways
# the first one is by exactly parent_id which is unit ID or Root ID for the account
# the second way is to define parent_path, this means that we will define a node in the hierarchical structure through path
# example1: parent_path="CoreOU/DevelopmentOU" to put account in DevelopmentOU which is placed in CoreOU
# example2: parent_path="" or parent_id="" that means in root unit
accounts:
- name: "ExampleOfAccountInRootOnit"
    email: "test+root@test.com"
    parent_id: ""
```

3. Create `aws_organization.yaml` or `aws_organization.yml`:

```yaml
# aws organization
feature_set: "ALL"
aws_service_access_principals: ["sso.amazonaws.com"]
enabled_policy_types: ["SERVICE_CONTROL_POLICY"]

# root policies
root_unit_policies: ["region_control"]
```

4. Create `general.yaml` or `general.yml`:

```yaml
# general
import_mode: false
```

5. Create `organizational_units.yaml` or `organizational_units.yml`:

```yaml
# organizational units
organizational_units:
- name: "CoreOU"
    policies: []
    children:
    - name: "DevelopmentOU"
        policies: ["dev_control_access"]
        children: []
    - name: "StageOU"
        policies: []
        children: []
    - name: "ProductionOU"
        policies: []
        children: []
- name: "SandboxOU"
    policies: [ "deny_all" ]
    children: []
```

6. Create `policies.yaml` or `policies.yml`:

```yaml
# policies
policies:
- name: "region_control"
    template_file: "./policies/scps/scp_region_lock.json"
- name: "deny_all"
    template_file: "./policies/scps/deny_all.json"
```
