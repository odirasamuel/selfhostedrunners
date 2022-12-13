provider "aws" {
  alias   = "test"
  region  = "us-east-2"
  profile = "odira"

  default_tags {
    tags = {
      "Environment" = terraform.workspace
    }
  }
}