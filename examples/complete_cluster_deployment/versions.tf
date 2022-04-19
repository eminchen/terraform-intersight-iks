terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "Toronto_DCLAB"
    workspaces {
      name = "terraform-intersight-iks"
    }
  }
  required_providers {
    intersight = {
      source = "CiscoDevNet/intersight"
      # version = "1.0.12"
    }
  }
  # experiments = [module_variable_optional_attrs]
}
