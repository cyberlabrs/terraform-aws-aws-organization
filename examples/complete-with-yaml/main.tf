#provider "aws" {}

module "aws_organization" {
  source = "../.."

  # variables are configured via yaml files inside "conf" folder
}
