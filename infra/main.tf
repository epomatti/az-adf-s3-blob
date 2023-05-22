terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.57.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_string" "bucket" {
  length    = 6
  min_lower = 6
  special   = false
}

locals {
  affix = "${var.workload}${random_string.bucket.result}"
}

data "azuread_client_config" "current" {}

#########################
########## AWS ##########
#########################

resource "aws_s3_bucket" "main" {
  bucket = "bucket-${local.affix}"

  # For development purposes
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

###########################
########## Azure ##########
###########################

### Group ###

resource "azurerm_resource_group" "default" {
  name     = "rg${local.affix}"
  location = "eastus"
}

### Data Lake ###

resource "azurerm_storage_account" "lake" {
  name                     = "dls${local.affix}"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  // Enable this for Gen2 Hierarchy
  is_hns_enabled = true
}

resource "azurerm_role_assignment" "adlsv2" {
  scope                = azurerm_storage_account.lake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_client_config.current.object_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "default" {
  name               = "data"
  storage_account_id = azurerm_storage_account.lake.id

  depends_on = [
    azurerm_role_assignment.adlsv2
  ]
}

resource "azurerm_data_factory" "default" {
  name                = "adf${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}
