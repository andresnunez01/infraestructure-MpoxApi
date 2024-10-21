terraform {
    
  backend "azurerm" {
    resource_group_name = "IN-Mpox"
    storage_account_name = "mpoxinfra"
    container_name = "mpox-tfstate"
    key = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}



provider "azurerm" {
  features {

  }
}