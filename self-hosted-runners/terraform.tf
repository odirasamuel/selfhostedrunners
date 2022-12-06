terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9"
    }
  }
  backend "s3" {
    bucket         = "core-infra-tf-state"
    encrypt        = true
    key            = "robotics/robot_stack/hosted_runners"
    dynamodb_table = "core_infra_tf_lock"
    profile        = "terraform-state"
    region         = "us-east-2"
  }
}
