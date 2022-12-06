provider "aws" {
  profile = "robotics_robot_stack_dev-admin"
  alias   = "robotics_robot_stack_dev"

  region = "us-east-1"

  default_tags {
    tags = {
      ou = "robotics"
    }
  }
}
