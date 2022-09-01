terraform {
required_providers {
azurerm = {
source = "hashicorp/azurerm"
version = ">=3.15.0"
}
}



# storage details for backend
backend "azurerm" {
resource_group_name = "tfstateRG02"
storage_account_name = "tfstate0247078855"
container_name = "tfstate"
key = "hubspoke.tfstate"
}
}



provider "azurerm" {
features {}
}