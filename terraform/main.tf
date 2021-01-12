provider "aws" {
  region = "us-east-1"
}

locals {
  service_name  = "service"
  aws_acc_id    = "094579366022"
  service_stage = terraform.workspace

  context = {
    dev = {
      listener_priority_service = "10"
    }
    staging = {
      listener_priority_service = "10"
    }
    prod = {
      listener_priority_service = "10"
    }
  }

  listener_priority_service = lookup(local.context[terraform.workspace], "listener_priority_service")
}

// terraform {
//   backend "s3" {
//     bucket = "mybucket"
//     region = "us-east-1"
//   }
// }
